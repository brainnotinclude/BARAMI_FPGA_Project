`timescale 1ns/1ps
module floating(
    input [31:0] a, // �Է�
    input [31:0] b, 
    input [2:0] mode,     // Mode: ���� ���� floating ����� opcode���� ����� �뵵
    output reg error,    // �����÷ο� �����ο� �� ǥ�� ���� �� ����� ������ ����
    output [31:0] result // ���
);

// ��ȣ ��Ʈ, ����, ���� ����     32��Ʈ �� ���� �� 1��Ʈ�� ��ȣ ��Ʈ, �� ���� 8��Ʈ�� ���� ��Ʈ, ������ 23��Ʈ�� ���� ��Ʈ
// 1.xxxx * 2^(yy) x�� ����, y�� ����
wire sign_a;
wire sign_b;
assign sign_a = a[31];
assign sign_b = b[31];



wire [7:0] exp_a;                         //E = exp - bias 
wire [7:0] exp_b;                         // 15213 = 1110111011101101 --> 1.1101101101101 * 2^13
assign exp_a = a[30:23];                  // E = 13, bias = 127 (2^(8-1)-1) so exp = 140�� �Ǵ�
assign exp_b = b[30:23];                  // �� ������ �츮�� ����� ������ 127�� ���ؼ� ��Ʈ ���

wire [22:0] mant_a;
wire [22:0] mant_b;
assign mant_a = a[22:0];
assign mant_b = b[22:0];

wire [23:0] norm_mant_a;    // 0.xxxx�� 1.xxx�� �ٲٴ� 
wire [23:0] norm_mant_b;    // �̷��� ���� ���� ���� ����Ʈ���� �� ���������� ��
assign norm_mant_a = {1'b1, mant_a};
assign norm_mant_b = {1'b1, mant_b}; 

wire [7:0] exp_diff;               // ���� ������ ���� ���̸� ���� �ڸ��� ���߱�
wire [7:0] exp_big;                // big�� �������� ���� ���� ���ϴµ��� ���
wire [23:0] shifted_mant_a;
wire [23:0] shifted_mant_b;
assign exp_diff = (exp_a > exp_b) ? (exp_a - exp_b) : (exp_b - exp_a);                 // �� ���� ���� ���̸� ����
assign exp_big = (exp_a > exp_b) ? exp_a : exp_b;                                      // �� ū ������ ���� ������ �׳� b ���� ����
assign shifted_mant_a = (exp_a > exp_b) ? norm_mant_a : (norm_mant_a >> exp_diff);     // ���� ���� ���� ������ ���̸�ŭ shift
assign shifted_mant_b = (exp_b > exp_a) ? norm_mant_b : (norm_mant_b >> exp_diff);     

wire [23:0] sign_mant_a;                                                       
wire [23:0] sign_mant_b;
assign sign_mant_a = sign_a ? ~shifted_mant_a +1 : shifted_mant_a;           // ���� ���� ���� ������ ��� shift�� ������ 2�� ���� ����
assign sign_mant_b = sign_b ? ~shifted_mant_b+1: shifted_mant_b;




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// add
wire [23:0] mant_sum;
wire mant_cout;
// ������ ���� ���� 
ripple_carry_adder_floating u_adder(
.a(sign_mant_a),               
.b(sign_mant_b),
.cin(0),
.sum(mant_sum),
.cout(mant_cout));

wire [1:0] sign_bit;
assign sign_bit = {sign_a, sign_b};          // �������� ���, ����, ����, ���� ��� ���� �ٸ�

// ������ ���� ������
reg [22:0] mant_final_add;                 // �������� ���� ���� ��
reg [7:0] exp_final_add;                   // �������� ���� ������
reg [4:0] exp_shift_count_add;             // ����, ���� �� ��� ������ �󸶳� ��ȭ���Ѿ� �ϴ��� ���� ������� ���� ����
reg [23:0] mant_sum_comple_add;            // ����� �������� ������� �Ǵ� �� ������ ����
reg sign_result_add;                       // ����� �������� ������� ��ȣ��Ʈ

always @(*) begin
case(sign_bit)
2'b00: begin                                // 00�� �����, ������ mant_cout�� ���� ���� ������� ��� ��Ʈ�� ���� �޶���
mant_final_add = mant_cout ? mant_sum[23:1]:mant_sum[22:0];           // 24��° ��Ʈ�� 1�̶�°� 1.xxx �� �ƴ� 1x.xxxx��� ��
exp_final_add = mant_cout ? exp_big +1 : exp_big;                     // �׷��Ƿ� ������, ������ �� �ڸ���
sign_result_add = 0;
end 

2'b01: begin         // a�� ��, b�� ��       // ���� ������ ���� ��, ���� ������ �״��, ����� ������ ������ �� ũ�� �״��, ������ ������ ������ �� ũ�� 2�� ���� 
    mant_sum_comple_add = (exp_a == exp_b) ? (mant_a == mant_b ? mant_sum : 
                                             (mant_a > mant_b ? mant_sum : ~mant_sum + 1)) : (exp_a > exp_b) ? mant_sum :~mant_sum+1;     // b�� �� ũ�� ����� ����, ��� ���� ���� �� ���� ����
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
                         (mant_sum_comple_add[0] ? 5'd23: 5'd31))))))))))))))))))))))));   // ó�� 1�� ��Ÿ���� ��ġ�� ���� ������ �󸶳� ���ؾ� �ϴ��� �� �� ���� 
if (exp_shift_count_add == 5'd31)   
    error = 1;
else begin
    error = 0;
    mant_final_add = mant_sum_comple_add[22:0] << exp_shift_count_add; 
    exp_final_add = exp_big - exp_shift_count_add;
    sign_result_add =  (exp_a == exp_b) ? (mant_a == mant_b ? 0 : 
                                          (mant_a > mant_b ? 0 : 1)) : (exp_a > exp_b) ? 0 : 1; // ������� ������ ������ �Ǵ�, �Ǵ� ��ü�� ������ �� �Ͱ� ����
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
// sub�� add���� �� ��� �״�� �̿밡���غ��� ��� - ����� ��� + ������ ����
// sgin_bit = 00 �̸� 01�� ���� ����, 01 �̸� 00, 10�̸� 11, 11�̸� 10�� ���� ������
reg [22:0] mant_final_sub;
reg [7:0] exp_final_sub;
reg [4:0] exp_shift_count_sub;
reg [23:0] mant_sum_comple_sub;
reg sign_result_sub;

always @(*) begin
case(sign_bit)
2'b01: begin                      // �������� 00�� �� ����� �� �� ���������� 01�϶� ����ϸ� ��
mant_final_sub = mant_cout ? mant_sum[23:1]:mant_sum[22:0];           // 24��° ��Ʈ�� 1�̶�°� 1.xxx �� �ƴ� 1x.xxxx��� ��
exp_final_sub = mant_cout ? exp_big +1 : exp_big;
sign_result_sub = 1;
end 

2'b00: begin              //�������� �������� 01�϶� ����� ��, ���������� 00�϶� ���        
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

2'b11: begin                // ���� 10�� �� ����� ��, �� ���� 11������ ����ϸ� ��
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

2'b10: begin              // ���� 11�� �� ����� ��, ���� 10�� �� ����ϸ� ��
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
//���� 
//������ ���ϰ�, ������ ����
wire [47:0] mant_mult_out;
multiplier_floating u_multiplier(
.a(shifted_mant_a),
.b(shifted_mant_b),
.out(mant_mult_out));

wire [7:0] exp_mult;
assign exp_mult = exp_a + exp_b - 8'd127;             // ������ 127�� ���ϸ� �ϼ��� �� ������ ���ϸ� 127�� �ߺ��̹Ƿ� �� ���� ����



wire [22:0] mant_final_mult;       // ������ 1�� ���� �ڸ� �� ���� �ڸ����� �� 23��Ʈ �޾��ֱ�
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
assign exp_final_mult = mant_mult_out[47] ? exp_mult +1 : exp_mult;       // ���� ��� �ֻ��� ��Ʈ�� 1�̸� ������ 1 �þ 

wire [31:0] mult_result;
assign mult_result = {sign_a ^ sign_b, exp_final_mult, mant_final_mult};



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  ������
// b�� �������� ��, a�� ������ ��
// b �������� a���� ���� 127 ���ϱ�
// ������ b ���� ������ a ����
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





