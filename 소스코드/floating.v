`timescale 1ns/1ps
module floating(
    input [31:0] a, // 입력
    input [31:0] b, 
    input [2:0] mode,     // Mode: 추후 통합 floating 만들면 opcode마냥 사용할 용도
    output reg error,    // 오버플로우 언더블로우 등 표현 범위 외 결과가 나오면 에러
    output [31:0] result // 결과
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
wire [23:0] shifted_mant_a;
wire [23:0] shifted_mant_b;
assign exp_diff = (exp_a > exp_b) ? (exp_a - exp_b) : (exp_b - exp_a);                 // 두 수간 지수 차이를 저장
assign exp_big = (exp_a > exp_b) ? exp_a : exp_b;                                      // 더 큰 지수를 저장 같으면 그냥 b 지수 저장
assign shifted_mant_a = (exp_a > exp_b) ? norm_mant_a : (norm_mant_a >> exp_diff);     // 지수 작은 수는 가수를 차이만큼 shift
assign shifted_mant_b = (exp_b > exp_a) ? norm_mant_b : (norm_mant_b >> exp_diff);     

wire [23:0] sign_mant_a;                                                       
wire [23:0] sign_mant_b;
assign sign_mant_a = sign_a ? ~shifted_mant_a +1 : shifted_mant_a;           // 만약 들어온 수가 음수인 경우 shift된 가수를 2의 보수 취함
assign sign_mant_b = sign_b ? ~shifted_mant_b+1: shifted_mant_b;




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
exp_final_add = mant_cout ? exp_big +1 : exp_big;                     // 그러므로 가수도, 지수도 한 자리씩
sign_result_add = 0;
end 

2'b01: begin         // a가 양, b가 음       // 지수 같으면 가수 비교, 가수 같으면 그대로, 양수의 가수나 지수가 더 크면 그대로, 음수의 가수나 지수가 더 크면 2의 보수 
    mant_sum_comple_add = (exp_a == exp_b) ? (mant_a == mant_b ? mant_sum : 
                                             (mant_a > mant_b ? mant_sum : ~mant_sum + 1)) : (exp_a > exp_b) ? mant_sum :~mant_sum+1;     // b가 더 크면 결과도 음수, 결과 보수 취한 뒤 연산 진행
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
                         (mant_sum_comple_add[0] ? 5'd23: 5'd31))))))))))))))))))))))));   // 처음 1이 나타나는 위치에 따라 지수가 얼마나 변해야 하는지 알 수 있음 
if (exp_shift_count_add == 5'd31)   
    error = 1;
else begin
    error = 0;
    mant_final_add = mant_sum_comple_add[22:0] << exp_shift_count_add; 
    exp_final_add = exp_big - exp_shift_count_add;
    sign_result_add =  (exp_a == exp_b) ? (mant_a == mant_b ? 0 : 
                                          (mant_a > mant_b ? 0 : 1)) : (exp_a > exp_b) ? 0 : 1; // 결과값이 양인지 음인지 판단, 판단 자체는 위에서 한 것과 동일
    end
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
                         (mant_sum_comple_add[0] ? 5'd23: 5'd31))))))))))))))))))))))));
if (exp_shift_count_add == 5'd31)
     error = 1;
else begin
     error = 0;
     mant_final_add = mant_sum_comple_add[22:0] << exp_shift_count_add; 
     exp_final_add = exp_big - exp_shift_count_add;
     sign_result_add =  (exp_a == exp_b) ? (mant_a == mant_b ? 0 : 
                                          (mant_a < mant_b ? 0 : 1)) : (exp_a < exp_b) ? 0 : 1; 
    end                                          
end

2'b11: begin
    mant_sum_comple_add = ~mant_sum + 1;
    mant_final_add = mant_cout ? mant_sum_comple_add[23:1] : mant_sum_comple_add[22:0];
    exp_final_add = mant_cout ? exp_big + 1 : exp_big;   
    sign_result_add = 1;                   
end 
endcase
end

wire [31:0] add_result;
assign add_result = {sign_result_add, exp_final_add, mant_final_add};
assign result = add_result;

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
exp_final_sub = mant_cout ? exp_big +1 : exp_big;
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
                         (mant_sum_comple_sub[0] ? 5'd23: 5'd31))))))))))))))))))))))));
if (exp_shift_count_sub == 5'd31)
    error = 1;
else begin
    error = 0;
    mant_final_sub = mant_sum_comple_sub[22:0] << exp_shift_count_sub; 
    exp_final_sub = exp_big - exp_shift_count_sub;
    sign_result_sub =  (exp_a == exp_b) ? (mant_a == mant_b ? 0 : 
                                          (mant_a > mant_b ? 0 : 1)) : (exp_a > exp_b) ? 0 : 1;
    end
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
if (exp_shift_count_sub == 5'd31)
     error = 1;
else begin
     error = 0;
     mant_final_sub = mant_sum_comple_sub[22:0] << exp_shift_count_sub; 
     exp_final_sub = exp_big - exp_shift_count_sub;
     sign_result_sub =  (exp_a == exp_b) ? (mant_a == mant_b ? 0 : 
                                          (mant_a < mant_b ? 0 : 1)) : (exp_a < exp_b) ? 0 : 1;
    end                                          
end

2'b10: begin              // 덧셈 11일 때 사용한 식, 뺄셈 10일 때 사용하면 됨
    mant_sum_comple_sub = ~mant_sum + 1;
    mant_final_sub = mant_cout ? mant_sum_comple_sub[23:1] : mant_sum_comple_sub[22:0];
    exp_final_sub = mant_cout ? exp_big + 1 : exp_big;    
    sign_result_sub = 1;                  
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

wire [7:0] exp_mult;
assign exp_mult = exp_a + exp_b - 8'd127;             // 지수는 127을 더하며 완성됨 두 지수를 더하면 127이 중복이므로 한 번은 빼줌



wire [22:0] mant_final_mult;       // 가수는 1이 나온 자리 그 다음 자리부터 쭉 23비트 받아주기
assign mant_final_mult = (mant_mult_out[47] ? mant_mult_out[46:24] :
                   (mant_mult_out[46] ? mant_mult_out[45:23] :
                   (mant_mult_out[45] ? mant_mult_out[44:22] :
                   (mant_mult_out[44] ? mant_mult_out[43:21] :
                   (mant_mult_out[43] ? mant_mult_out[42:20] :
                   (mant_mult_out[42] ? mant_mult_out[41:19] :
                   (mant_mult_out[41] ? mant_mult_out[40:18] :
                   (mant_mult_out[40] ? mant_mult_out[39:17] :
                   (mant_mult_out[39] ? mant_mult_out[38:16] :
                   (mant_mult_out[38] ? mant_mult_out[37:15] :
                   (mant_mult_out[37] ? mant_mult_out[36:14] :
                   (mant_mult_out[36] ? mant_mult_out[35:13] :
                   (mant_mult_out[35] ? mant_mult_out[34:12] :
                   (mant_mult_out[34] ? mant_mult_out[33:11] :
                   (mant_mult_out[33] ? mant_mult_out[32:10] :
                   (mant_mult_out[32] ? mant_mult_out[31:9] :
                   (mant_mult_out[31] ? mant_mult_out[30:8] :
                   (mant_mult_out[30] ? mant_mult_out[29:7] :
                   (mant_mult_out[29] ? mant_mult_out[28:6] :
                   (mant_mult_out[28] ? mant_mult_out[27:5] :
                   (mant_mult_out[27] ? mant_mult_out[26:4] :
                   (mant_mult_out[26] ? mant_mult_out[25:3] :
                   (mant_mult_out[25] ? mant_mult_out[24:2] :
                   (mant_mult_out[24] ? mant_mult_out[23:1] :
                   (mant_mult_out[23] ? mant_mult_out[22:0] : 
                   (mant_mult_out[22] ? {mant_mult_out[21:0],1'b0} :
                   (mant_mult_out[21] ? {mant_mult_out[20:0],2*{1'b0}} :
                   (mant_mult_out[20] ? {mant_mult_out[19:0],3*{1'b0}} :
                   (mant_mult_out[19] ? {mant_mult_out[18:0],4*{1'b0}} :
                   (mant_mult_out[18] ? {mant_mult_out[17:0],5*{1'b0}} :
                   (mant_mult_out[17] ? {mant_mult_out[16:0],6*{1'b0}} :
                   (mant_mult_out[16] ? {mant_mult_out[15:0],7*{1'b0}} :
                   (mant_mult_out[15] ? {mant_mult_out[14:0],8*{1'b0}} :
                   (mant_mult_out[14] ? {mant_mult_out[13:0],9*{1'b0}} :
                   (mant_mult_out[13] ? {mant_mult_out[12:0],10*{1'b0}} :
                   (mant_mult_out[12] ? {mant_mult_out[11:0],11*{1'b0}} :
                   (mant_mult_out[11] ? {mant_mult_out[10:0],12*{1'b0}} :
                   (mant_mult_out[10] ? {mant_mult_out[9:0],13*{1'b0}} :
                   (mant_mult_out[9] ? {mant_mult_out[8:0],14*{1'b0}} :
                   (mant_mult_out[8] ? {mant_mult_out[7:0],15*{1'b0}} :
                   (mant_mult_out[7] ? {mant_mult_out[6:0],16*{1'b0}} :
                   (mant_mult_out[6] ? {mant_mult_out[5:0],17*{1'b0}} :
                   (mant_mult_out[5] ? {mant_mult_out[4:0],18*{1'b0}} :
                   (mant_mult_out[4] ? {mant_mult_out[3:0],19*{1'b0}} :
                   (mant_mult_out[3] ? {mant_mult_out[2:0],20*{1'b0}} :
                   (mant_mult_out[2] ? {mant_mult_out[1:0],21*{1'b0}} :
                   (mant_mult_out[1] ? {mant_mult_out[0],22*{1'b0}} : 23'b0)))))))))))))))))))))))))))))))))))))))))))))));
                   

wire [7:0] exp_final_mult;
assign exp_final_mult = mant_mult_out[47] ? exp_mult +1 : exp_mult;       // 곱셈 결과 최상위 비트가 1이면 지수도 1 늘어남 

wire [31:0] mult_result;
assign mult_result = {sign_a ^ sign_b, exp_final_mult, mant_final_mult};



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  나눗셈
// b가 나눠지는 수, a가 나누는 수
// b 지수에서 a지수 빼고 127 더하기
// 가수는 b 가수 나누기 a 가수
wire [23:0] mant_divide;
wire [7:0] exp_divide;

divide_floating u_divide_floating(
.dividend(shifted_mant_b),
.divisor(shifted_mant_a),
.error(error),
.quotient(mant_divide),
.remainder());

assign exp_divide = exp_b - exp_a + 8'd127;

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
assign exp_final_divide = mant_divide[23] ? exp_divide + 1 : exp_divide ;

wire [31:0] divide_result;
assign divide_result = {sign_a^sign_b, exp_final_divide, mant_final_divide};
                           
endmodule





