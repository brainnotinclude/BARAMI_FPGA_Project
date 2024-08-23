`timescale 1ns/1ps
module floating(
    input [31:0] a, // 입력
    input [31:0] b, 
    input [4:0] aluop,     // aluop
    input [2:0] mode,
    output reg [31:0] result // 결과
);

// 부호 비트, 가수, 지수 정의     32비트 중 제일 앞 1비트는 부호 비트, 그 다음 8비트는 지수 비트, 마지막 23비트는 가수 비트
// 1.xxxx * 2^(yy) x가 가수, y가 지수
wire sign_a;
wire sign_b;
assign sign_a = a[31];
assign sign_b = b[31];


wire [7:0] exp_a;                         //E = exp - bias 
wire [7:0] exp_b;                         // 15213 = 1110111011101101 --> 1.1101101101101 * 2^13
assign exp_a = a[30:23];                  // E = 13, bias = 127 (2^(8-1)-1) so exp = 140이 되는
assign exp_b = b[30:23];                  // 즉 지수는 우리가 계산한 값에서 127을 더해서 비트 계산

wire [22:0] mant_a;
wire [22:0] mant_b;
assign mant_a = a[22:0];
assign mant_b = b[22:0];

wire [23:0] norm_mant_a;    // 0.xxxx를 1.xxx로 바꾸는 
wire [23:0] norm_mant_b;    // 이래야 지수 작은 수를 쉬프트했을 때 정상적으로 됨
assign norm_mant_a = {1'b1, mant_a};
assign norm_mant_b = {1'b1, mant_b}; 

wire [7:0] exp_diff;               // 지수 낮은걸 지수 높이며 가수 자리수 낮추기
wire [7:0] exp_big;                // big은 덧셈에서 최종 지수 구하는데에 사용
wire [47:0] mant_48bit_a;
wire [47:0] mant_48bit_b;
wire [47:0] mant_round_a;
wire [47:0] mant_round_b;
wire [23:0] shifted_mant_a;
wire [23:0] shifted_mant_b;
assign exp_diff = (exp_a > exp_b) ? (exp_a - exp_b) : (exp_b - exp_a);                 // 두 수간 지수 차이를 저장
assign exp_big = (exp_a > exp_b) ? exp_a : exp_b;                                      // 더 큰 지수를 저장 같으면 그냥 b 지수 저장
assign mant_48bit_a = {norm_mant_a, 24'b0};
assign mant_48bit_b = {norm_mant_b, 24'b0};
assign mant_round_a = (exp_a > exp_b) ? mant_48bit_a : (mant_48bit_a >> exp_diff);     // 지수 작은 수는 가수를 차이만큼 shift
assign mant_round_b = (exp_b > exp_a) ? mant_48bit_b : (mant_48bit_b >> exp_diff);
// round를 위해 만들어둔 mant를 round 모듈에 넣어서 다시 24비트로 돌려받음     
floating_round u_floating_round_a(
.mant_in(mant_round_a),
.mode(mode),
.sign_bit(sign_a),
.mant_out(shifted_mant_a));

floating_round u_floating_round_b(
.mant_in(mant_round_b),
.mode(mode),
.sign_bit(sign_b),
.mant_out(shifted_mant_b));

wire [23:0] sign_mant_a;                                                       
wire [23:0] sign_mant_b;
assign sign_mant_a = sign_a ? ~shifted_mant_a +1 : shifted_mant_a;           // 만약 들어온 수가 음수인 경우 shift된 가수를 2의 보수 취함
assign sign_mant_b = sign_b ? ~shifted_mant_b+1: shifted_mant_b;

// 덧셈은 결과에 대한 round가 필요하지 않음 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// add
wire [23:0] mant_sum;
wire mant_cout;
// 가수에 대한 덧셈 
ripple_carry_adder_floating u_adder(
.a(sign_mant_a),               
.b(sign_mant_b),
.cin(0),
.sum(mant_sum),
.cout(mant_cout));

wire [1:0] sign_bit;
assign sign_bit = {sign_a, sign_b};          // 덧셈에서 양양, 양음, 음양, 음음 모두 식이 다름

// 덧셈을 위한 변수들
reg [22:0] mant_final_add;                 // 덧셈에서 가수 최종 값
reg [7:0] exp_final_add;                   // 덧셈에서 지수 최종값
reg [4:0] exp_shift_count_add;             // 음양, 양음 인 경우 지수를 얼마나 변화시켜야 하는지 가수 결과값을 통해 얻음
reg [23:0] mant_sum_comple_add;            // 결과가 음수인지 양수인지 판단 후 저장할 변수
reg sign_result_add;                       // 결과가 음수인지 양수인지 부호비트

always @(*) begin
case(sign_bit)
2'b00: begin                                // 00은 양양임, 가수는 mant_cout에 따라 덧셈 결과에서 어느 비트를 쓸지 달라짐
mant_final_add = mant_cout ? mant_sum[23:1]:mant_sum[22:0];           // 24번째 비트가 1이라는건 1.xxx 이 아닌 1x.xxxx라는 뜻
exp_final_add = (exp_big == 8'b11111111) ? 8'b11111111:mant_cout ? exp_big +1 : exp_big;    // 그러므로 가수도, 지수도 한 자리씩
sign_result_add = 0;
end 

2'b01: begin         // a가 양, b가 음  지수 같으면 가수 비교, 가수 같으면 그대로, 양수의 가수나 지수가 더 크면 그대로, 음수의 가수나 지수가 더 크면 2의 보수 
    mant_sum_comple_add = (exp_a == exp_b) ? (mant_a == mant_b ? mant_sum : 
                                             (mant_a > mant_b ? mant_sum : ~mant_sum + 1)) : (exp_a > exp_b) ? mant_sum :~mant_sum+1;          // b가 더 크면 결과도 음수, 결과 보수 취한 뒤 연산 진행
    exp_shift_count_add = (mant_sum_comple_add[23] ? 5'd0 : 
                         (mant_sum_comple_add[22] ? 5'd1 :  
                         (mant_sum_comple_add[21] ? 5'd2 :
                         (mant_sum_comple_add[20] ? 5'd3:
                         (mant_sum_comple_add[19] ? 5'd4 :
                         (mant_sum_comple_add[18] ? 5'd5 :
                         (mant_sum_comple_add[17] ? 5'd6 :
                         (mant_sum_comple_add[16] ? 5'd7 :
                         (mant_sum_comple_add[15] ? 5'd8 :
                         (mant_sum_comple_add[14] ? 5'd9 :
                         (mant_sum_comple_add[13] ? 5'd10:
                         (mant_sum_comple_add[12] ? 5'd11:
                         (mant_sum_comple_add[11] ? 5'd12:
                         (mant_sum_comple_add[10] ? 5'd13:
                         (mant_sum_comple_add[9] ? 5'd14:
                         (mant_sum_comple_add[8] ? 5'd15:
                         (mant_sum_comple_add[7] ? 5'd16:
                         (mant_sum_comple_add[6] ? 5'd17:
                         (mant_sum_comple_add[5] ? 5'd18:
                         (mant_sum_comple_add[4] ? 5'd19:
                         (mant_sum_comple_add[3] ? 5'd20:
                         (mant_sum_comple_add[2] ? 5'd21:
                         (mant_sum_comple_add[1] ? 5'd22:
                         (mant_sum_comple_add[0] ? 5'd23: 5'd24))))))))))))))))))))))));   // 처음 1이 나타나는 위치에 따라 지수가 얼마나 변해야 하는지 알 수 있음 


    mant_final_add = mant_sum_comple_add[22:0] << exp_shift_count_add; 
    exp_final_add = (exp_big < exp_shift_count_add) ? 8'b00000000: exp_big - exp_shift_count_add;
    sign_result_add = (exp_a == exp_b) ? (mant_a == mant_b ? 0 : 
                                          (mant_a > mant_b ? 0 : 1)) : (exp_a > exp_b) ? 0 : 1; // 결과값이 양인지 음인지 판단, 판단 자체는 위에서 한 것과 동일
end

2'b10: begin
    mant_sum_comple_add = (exp_a == exp_b) ? (mant_a == mant_b ? mant_sum : 
                                             (mant_a < mant_b ? mant_sum : ~mant_sum + 1)) : (exp_a < exp_b) ? mant_sum :~mant_sum+1;
    exp_shift_count_add = (mant_sum_comple_add[23] ? 5'd0 : 
                         (mant_sum_comple_add[22] ? 5'd1 :  
                         (mant_sum_comple_add[21] ? 5'd2 :
                         (mant_sum_comple_add[20] ? 5'd3:
                         (mant_sum_comple_add[19] ? 5'd4 :
                         (mant_sum_comple_add[18] ? 5'd5 :
                         (mant_sum_comple_add[17] ? 5'd6 :
                         (mant_sum_comple_add[16] ? 5'd7 :
                         (mant_sum_comple_add[15] ? 5'd8 :
                         (mant_sum_comple_add[14] ? 5'd9 :
                         (mant_sum_comple_add[13] ? 5'd10:
                         (mant_sum_comple_add[12] ? 5'd11:
                         (mant_sum_comple_add[11] ? 5'd12:
                         (mant_sum_comple_add[10] ? 5'd13:
                         (mant_sum_comple_add[9] ? 5'd14:
                         (mant_sum_comple_add[8] ? 5'd15:
                         (mant_sum_comple_add[7] ? 5'd16:
                         (mant_sum_comple_add[6] ? 5'd17:
                         (mant_sum_comple_add[5] ? 5'd18:
                         (mant_sum_comple_add[4] ? 5'd19:
                         (mant_sum_comple_add[3] ? 5'd20:
                         (mant_sum_comple_add[2] ? 5'd21:
                         (mant_sum_comple_add[1] ? 5'd22:
                         (mant_sum_comple_add[0] ? 5'd23: 5'd24))))))))))))))))))))))));

     mant_final_add = mant_sum_comple_add[22:0] << exp_shift_count_add; 
     exp_final_add = (exp_big < exp_shift_count_add) ? 8'b00000000: exp_big - exp_shift_count_add;
     sign_result_add =  (exp_a == exp_b) ? (mant_a == mant_b ? 0 : 
                                          (mant_a < mant_b ? 0 : 1)) : (exp_a < exp_b) ? 0 : 1;                                      
end

2'b11: begin
    mant_sum_comple_add = ~mant_sum + 1;
    mant_final_add = mant_cout ? mant_sum_comple_add[23:1] : mant_sum_comple_add[22:0];
    exp_final_add = (exp_big == 8'b11111111) ? 8'b11111111: mant_cout ? exp_big + 1 : exp_big;   
    sign_result_add = 1;                   
end 
default:begin
    mant_sum_comple_add = 0; 
    mant_final_add = 0;
    exp_final_add = 0;
    sign_result_add =0;
    end
endcase
end

wire [31:0] add_result;
assign add_result = {sign_result_add, exp_final_add, mant_final_add};


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// sub
// sub는 add에서 쓴 방식 그대로 이용가능해보임 양수 - 양수는 양수 + 음수와 같음
// sgin_bit = 00 이면 01과 같은 연산, 01 이면 00, 10이면 11, 11이면 10과 같은 연산임
reg [22:0] mant_final_sub;
reg [7:0] exp_final_sub;
reg [4:0] exp_shift_count_sub;
reg [23:0] mant_sum_comple_sub;
reg sign_result_sub;

always @(*) begin
case(sign_bit)
2'b01: begin                      // 덧셈에서 00일 때 사용한 식 즉 뺄셈에서는 01일때 사용하면 됨
mant_final_sub = mant_cout ? mant_sum[23:1]:mant_sum[22:0];           // 24번째 비트가 1이라는건 1.xxx 이 아닌 1x.xxxx라는 뜻
exp_final_sub = (exp_big ==8'b11111111) ? 8'b11111111: mant_cout ? exp_big +1 : exp_big;
sign_result_sub = 1;
end 

2'b00: begin              //마찬가지 덧셈에서 01일때 사용한 식, 뺄셈에서는 00일때 사용        
    mant_sum_comple_sub = (exp_a == exp_b) ? (mant_a == mant_b ? mant_sum : 
                                             (mant_a > mant_b ? mant_sum : ~mant_sum + 1)) : (exp_a > exp_b) ? mant_sum :~mant_sum+1;     
    exp_shift_count_sub = (mant_sum_comple_sub[23] ? 5'd0 : 
                         (mant_sum_comple_sub[22] ? 5'd1 :  
                         (mant_sum_comple_sub[21] ? 5'd2 :
                         (mant_sum_comple_sub[20] ? 5'd3:
                         (mant_sum_comple_sub[19] ? 5'd4 :
                         (mant_sum_comple_sub[18] ? 5'd5 :
                         (mant_sum_comple_sub[17] ? 5'd6 :
                         (mant_sum_comple_sub[16] ? 5'd7 :
                         (mant_sum_comple_sub[15] ? 5'd8 :
                         (mant_sum_comple_sub[14] ? 5'd9 :
                         (mant_sum_comple_sub[13] ? 5'd10:
                         (mant_sum_comple_sub[12] ? 5'd11:
                         (mant_sum_comple_sub[11] ? 5'd12:
                         (mant_sum_comple_sub[10] ? 5'd13:
                         (mant_sum_comple_sub[9] ? 5'd14:
                         (mant_sum_comple_sub[8] ? 5'd15:
                         (mant_sum_comple_sub[7] ? 5'd16:
                         (mant_sum_comple_sub[6] ? 5'd17:
                         (mant_sum_comple_sub[5] ? 5'd18:
                         (mant_sum_comple_sub[4] ? 5'd19:
                         (mant_sum_comple_sub[3] ? 5'd20:
                         (mant_sum_comple_sub[2] ? 5'd21:
                         (mant_sum_comple_sub[1] ? 5'd22:
                         (mant_sum_comple_sub[0] ? 5'd23: 5'd24))))))))))))))))))))))));

    mant_final_sub = mant_sum_comple_sub[22:0] << exp_shift_count_sub; 
    exp_final_sub = (exp_big < exp_shift_count_sub) ? 8'b00000000: exp_big - exp_shift_count_sub;
    sign_result_sub =  (exp_a == exp_b) ? (mant_a == mant_b ? 0 : 
                                          (mant_a > mant_b ? 0 : 1)) : (exp_a > exp_b) ? 0 : 1;
    
end

2'b11: begin                // 덧셈 10일 때 사용한 식, 즉 뺄셈 11ㅇ에서 사용하면 됨
    mant_sum_comple_sub = (exp_a == exp_b) ? (mant_a == mant_b ? mant_sum : 
                                             (mant_a < mant_b ? mant_sum : ~mant_sum + 1)) : (exp_a < exp_b) ? mant_sum :~mant_sum+1;
    exp_shift_count_sub = (mant_sum_comple_sub[23] ? 5'd0 : 
                         (mant_sum_comple_sub[22] ? 5'd1 :  
                         (mant_sum_comple_sub[21] ? 5'd2 :
                         (mant_sum_comple_sub[20] ? 5'd3:
                         (mant_sum_comple_sub[19] ? 5'd4 :
                         (mant_sum_comple_sub[18] ? 5'd5 :
                         (mant_sum_comple_sub[17] ? 5'd6 :
                         (mant_sum_comple_sub[16] ? 5'd7 :
                         (mant_sum_comple_sub[15] ? 5'd8 :
                         (mant_sum_comple_sub[14] ? 5'd9 :
                         (mant_sum_comple_sub[13] ? 5'd10:
                         (mant_sum_comple_sub[12] ? 5'd11:
                         (mant_sum_comple_sub[11] ? 5'd12:
                         (mant_sum_comple_sub[10] ? 5'd13:
                         (mant_sum_comple_sub[9] ? 5'd14:
                         (mant_sum_comple_sub[8] ? 5'd15:
                         (mant_sum_comple_sub[7] ? 5'd16:
                         (mant_sum_comple_sub[6] ? 5'd17:
                         (mant_sum_comple_sub[5] ? 5'd18:
                         (mant_sum_comple_sub[4] ? 5'd19:
                         (mant_sum_comple_sub[3] ? 5'd20:
                         (mant_sum_comple_sub[2] ? 5'd21:
                         (mant_sum_comple_sub[1] ? 5'd22:
                         (mant_sum_comple_sub[0] ? 5'd23: 5'd31))))))))))))))))))))))));
     
     mant_final_sub = mant_sum_comple_sub[22:0] << exp_shift_count_sub; 
     exp_final_sub = (exp_big < exp_shift_count_sub) ? 8'b00000000: exp_big - exp_shift_count_sub;
     sign_result_sub =  (exp_a == exp_b) ? (mant_a == mant_b ? 0 : 
                                          (mant_a < mant_b ? 0 : 1)) : (exp_a < exp_b) ? 0 : 1;                                        
end

2'b10: begin              // 덧셈 11일 때 사용한 식, 뺄셈 10일 때 사용하면 됨
    mant_sum_comple_sub = ~mant_sum + 1;
    mant_final_sub = mant_cout ? mant_sum_comple_sub[23:1] : mant_sum_comple_sub[22:0];
    exp_final_sub = (exp_big == 8'b11111111) ? 8'b11111111: mant_cout ? exp_big + 1 : exp_big;    
    sign_result_sub = 1;                  
end 
default: begin
    mant_final_sub = 0;
    exp_final_sub = 0;
    sign_result_sub =0;
    end
endcase
end

wire [31:0] sub_result;
assign sub_result = {sign_result_sub, exp_final_sub, mant_final_sub};


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//곱셈 
//가수는 곱하고, 지수는 더함
wire [47:0] mant_mult_out;
multiplier_floating u_multiplier(
.a(shifted_mant_a),
.b(shifted_mant_b),
.out(mant_mult_out));

wire [8:0] exp_mult;
assign exp_mult = exp_a + exp_b - 8'd127;             // 지수는 127을 더하며 완성됨 두 지수를 더하면 127이 중복이므로 한 번은 빼줌

wire [7:0] check_over;
assign check_over = exp_mult[8] ? 8'b11111111 : exp_mult[7:0];
wire [5:0] mant_count; 
wire [22:0] mant_final_mult;       // 가수는 1이 나온 자리 그 다음 자리부터 쭉 23비트 받아주기
assign mant_count = (mant_mult_out[47] ? 6'd0 :
                   (mant_mult_out[46] ? 6'd1 :
                   (mant_mult_out[45] ? 6'd2 :
                   (mant_mult_out[44] ? 6'd3 :
                   (mant_mult_out[43] ? 6'd4 :
                   (mant_mult_out[42] ? 6'd5 :
                   (mant_mult_out[41] ? 6'd6 :
                   (mant_mult_out[40] ? 6'd7 :
                   (mant_mult_out[39] ? 6'd8 :
                   (mant_mult_out[38] ? 6'd9 :
                   (mant_mult_out[37] ? 6'd10 :
                   (mant_mult_out[36] ? 6'd11 :
                   (mant_mult_out[35] ? 6'd12 :
                   (mant_mult_out[34] ? 6'd13 :
                   (mant_mult_out[33] ? 6'd14 :
                   (mant_mult_out[32] ? 6'd15 :
                   (mant_mult_out[31] ? 6'd16 :
                   (mant_mult_out[30] ? 6'd17 :
                   (mant_mult_out[29] ? 6'd18 :
                   (mant_mult_out[28] ? 6'd19 :
                   (mant_mult_out[27] ? 6'd20 :
                   (mant_mult_out[26] ? 6'd21 :
                   (mant_mult_out[25] ? 6'd22 :
                   (mant_mult_out[24] ? 6'd23 :
                   (mant_mult_out[23] ? 6'd24 : 
                   (mant_mult_out[22] ? 6'd25 :
                   (mant_mult_out[21] ? 6'd26 :
                   (mant_mult_out[20] ? 6'd27 :
                   (mant_mult_out[19] ? 6'd28 :
                   (mant_mult_out[18] ? 6'd29 :
                   (mant_mult_out[17] ? 6'd30 :
                   (mant_mult_out[16] ? 6'd31 :
                   (mant_mult_out[15] ? 6'd32 :
                   (mant_mult_out[14] ? 6'd33 :
                   (mant_mult_out[13] ? 6'd34 :
                   (mant_mult_out[12] ? 6'd35 :
                   (mant_mult_out[11] ? 6'd36 :
                   (mant_mult_out[10] ? 6'd37 :
                   (mant_mult_out[9] ? 6'd38 :
                   (mant_mult_out[8] ? 6'd39 :
                   (mant_mult_out[7] ? 6'd40 :
                   (mant_mult_out[6] ? 6'd41 :
                   (mant_mult_out[5] ? 6'd42 :
                   (mant_mult_out[4] ? 6'd43 :
                   (mant_mult_out[3] ? 6'd44 :
                   (mant_mult_out[2] ? 6'd45 :
                   (mant_mult_out[1] ? 6'd46 : 6'd47)))))))))))))))))))))))))))))))))))))))))))))));

floating_round_mult u_floating_round_mult(
.mant_in(mant_mult_out),
.mode(mode),
.sign_bit(sign_a^sign_b),
.count(mant_count),
.mant_out(mant_final_mult));         

wire [7:0] exp_final_mult;
assign exp_final_mult = exp_mult[8] ? 8'b11111111 : (check_over == 8'b11111111) ? 8'b11111111: mant_mult_out[47] ? check_over +1 : check_over;       // 곱셈 결과 최상위 비트가 1이면 지수도 1 늘어남 

wire [31:0] mult_result;
assign mult_result = {sign_a ^ sign_b, exp_final_mult, mant_final_mult};



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  나눗셈
// b가 나눠지는 수, a가 나누는 수
// b 지수에서 a지수 빼고 127 더하기
// 가수는 b 가수 나누기 a 가수
wire [23:0] mant_divide;
reg [7:0] exp_divide;

divide_floating u_divide_floating(
.dividend(shifted_mant_b),
.divisor(shifted_mant_a),
.error(),
.quotient(mant_divide),
.remainder()
);
reg [8:0] exp_temp;

always @(*) begin                 // 지수 부분 계산시 한 비트 늘려 여유 공간 만들어 주고 오버인지 언더인지 처리 
        exp_temp = exp_b - exp_a + 9'd127;
        if (exp_temp > 9'd255)
            exp_divide = 8'd255; // 지수 오버플로우 처리
        else if (exp_temp < 9'd0)
            exp_divide = 8'd0;   // 지수 언더플로우 처리
        else
            exp_divide = exp_temp;
    end
wire [22:0] mant_final_divide;
assign mant_final_divide = (mant_divide[23] ? mant_divide[22:0] :
                           (mant_divide[22] ? {mant_divide[21:0], 1'b0} :
                           (mant_divide[21] ? {mant_divide[20:0], 2*{1'b0}} :
                           (mant_divide[20] ? {mant_divide[19:0], 3*{1'b0}} :
                           (mant_divide[19] ? {mant_divide[18:0], 4*{1'b0}} :
                           (mant_divide[18] ? {mant_divide[17:0], 5*{1'b0}} :
                           (mant_divide[17] ? {mant_divide[16:0], 6*{1'b0}} :
                           (mant_divide[16] ? {mant_divide[15:0], 7*{1'b0}} :
                           (mant_divide[15] ? {mant_divide[14:0], 8*{1'b0}} :
                           (mant_divide[14] ? {mant_divide[13:0], 9*{1'b0}} :
                           (mant_divide[13] ? {mant_divide[12:0], 10*{1'b0}} :
                           (mant_divide[12] ? {mant_divide[11:0], 11*{1'b0}} :
                           (mant_divide[11] ? {mant_divide[10:0], 12*{1'b0}} :
                           (mant_divide[10] ? {mant_divide[9:0], 13*{1'b0}} :
                           (mant_divide[9] ? {mant_divide[8:0], 14*{1'b0}} :
                           (mant_divide[8] ? {mant_divide[7:0], 15*{1'b0}} :
                           (mant_divide[7] ? {mant_divide[6:0], 16*{1'b0}} :
                           (mant_divide[6] ? {mant_divide[5:0], 17*{1'b0}} :
                           (mant_divide[5] ? {mant_divide[4:0], 18*{1'b0}} :
                           (mant_divide[4] ? {mant_divide[3:0], 19*{1'b0}} :
                           (mant_divide[3] ? {mant_divide[2:0], 20*{1'b0}} :
                           (mant_divide[2] ? {mant_divide[1:0], 21*{1'b0}} :
                           (mant_divide[1] ? {mant_divide[0], 22*{1'b0}} : 23'b0)))))))))))))))))))))));
                           

wire [7:0] exp_final_divide;
assign exp_final_divide = (exp_divide == 8'b0) ? exp_divide :mant_divide[23] ? exp_divide - 1 : exp_divide ;

wire [31:0] divide_result;
assign divide_result = {sign_a^sign_b, exp_final_divide, mant_final_divide};
               
               
///////////////////////////////////////////////////////////////////////////////////////               
////// max min
reg [31:0] min_result;
reg [31:0] max_result;

always @(*) begin
case(sign_bit)
2'b00: begin              
max_result = (exp_a == exp_b) ? (mant_a == mant_b ? a : 
                                (mant_a > mant_b ? a : b)) : (exp_a > exp_b) ? a :b;
min_result = (exp_a == exp_b) ? (mant_a == mant_b ? a : 
                                (mant_a > mant_b ? b : a)) : (exp_a > exp_b) ? b :a;        
end
2'b01: begin 
max_result = a;
min_result = b;
end

2'b10:  begin
max_result = b;
min_result = a;
end

2'b11: begin
max_result = (exp_a == exp_b) ? (mant_a == mant_b ? a : 
                                (mant_a > mant_b ? b : a)) : (exp_a > exp_b) ? b :a; 
min_result = (exp_a == exp_b) ? (mant_a == mant_b ? a : 
                                (mant_a > mant_b ? a : b)) : (exp_a > exp_b) ? a :b;    
end
endcase
end                                 


    
always@(*) begin
case(aluop)
5'b00000: result = add_result;
5'b00001: result = sub_result;
5'b00010: result = mult_result;
5'b00011: result = divide_result;
5'b00100: result = min_result;
5'b00101: result = max_result;
5'b00110: result = a;
5'b00111: result = a;
default : result = 32'b0;
endcase
end         



endmodule





