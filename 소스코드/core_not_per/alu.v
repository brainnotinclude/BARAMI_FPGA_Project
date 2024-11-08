`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/15 10:24:51
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu(
    input rst_n,
    input [5:0] aluop,
    input [31:0] aluin1,     // pc�� aluin1���� �ް���
    input [31:0] aluin2,     // imm, shamt�� aluin2���� �ް���
    output reg [31:0] aluout
    );

    // add sub lui auipc part
    wire [31:0] sum;
    wire [31:0] bar_aluin2;
    assign bar_aluin2 = (aluop[0]|aluop[3] ? ~aluin2 :aluin2);    // ������ aluin2 �״��, ������ aluin2 �� ��Ʈ�� inverse�� ������ ���
    
    ripple_carry_adder add_ripple_carry_adder(
    .a(aluin1),                       
    .b(bar_aluin2),
    .cin(aluop[0]|aluop[3]),
    .sum(sum),
    .cout()
    );            // aluop[0]|aluop[3]���� ������ ���� ����, ������ cin���� 1�� ���� �� sub�� 00001, slt�� 01000���� �ֱ� ������ ���� or�� ��
   
    // slt sltu part  
    wire overflow;
    wire [31:0] slt_alu;    //slt ���� ���
    wire [31:0] sltu_alu;    // sltu ���� ���
    
    assign overflow = (!((aluop[0]|aluop[3])^aluin1[31]^aluin2[31]))&(aluin1[31]^sum[31])&(!aluop[0]|aluop[3]);
    assign slt_alu = {31'b0, (sum[31]^overflow)};             
    assign sltu_alu = ((aluin1 < aluin2) ? 32'b1 :32'b0); // unsigned�� ���� �ܼ� ��
    
    // sll part
    wire [31:0] sll;
    assign sll = aluin1 << aluin2;
    
    // xor part 
    wire [31:0] xor_alu;
    assign xor_alu = aluin1 ^ aluin2;
    
    // srl part
    wire [31:0] srl;
    assign srl = aluin1 >> aluin2;
    
    // sra part
    wire [31:0] sra;
    assign sra = aluin1 >>> aluin2;
    
    // or part 
    wire [31:0] or_alu;
    assign or_alu = aluin1 | aluin2;
    
    // and part 
    wire [31:0] and_alu;
    assign and_alu = aluin1 & aluin2;
    
    // mul part
    wire [1:0] mode;
    wire [63:0] mult_out;
    assign mode = aluop[1:0];
    
    multiplier_all u_multiplier_all(
    .mode(mode),
    .a(aluin1),
    .b(aluin2),
    .out(mult_out)               // ���� ��� ���
    );
    
    wire [31:0] mul_out;
    wire [31:0] mulh_out;
    assign mul_out = mult_out[31:0];       // ���� 32��Ʈ
    assign mulh_out = mult_out[63:32];     // ���� 32��Ʈ

    // divide part                  // div = 11000 divu = 11010 rem = 11100 remu = 11110
    wire [31:0] aluin1_unsigned;         // ������ ������ �⺻������ ���밪�� ���� ���� ����
    wire [31:0] aluin2_unsigned;         // �׷��� ���ؼ��� ��ɾ unsign���� �ƴ��� ���� �ʿ�
    wire [31:0] quotient;                // aluop[1]�� div�� rem ����(0), divu, remu(1)���� ����
    wire [31:0] remainder;               // �̸� �̿��� ������ ��⿡ ���� �Է��� ������
    assign aluin1_unsigned = (aluop[1] ? aluin1 : (aluin1[31] ? ~aluin1+1 : aluin1));       // ���� div�ε� �����ΰ�� 2�� ������ ����� ����
    assign aluin2_unsigned = (aluop[1] ? aluin2 : (aluin2[31] ? ~aluin2+1 : aluin2));
    
    divide u_divide(                    
    .dividend(aluin1_unsigned),
    .divisor(aluin2_unsigned),
    .quotient(quotient),
    .remainder(remainder));
    // ������ ����� div, divu, rem, remu�� ��� �ùٸ� ������ ���� �ʿ�
    // �̸� ���� ó�� ���� �� �Է��� �ֻ��� ��Ʈ�� �ٿ� 2��Ʈ ¥�� mod_div��� ������ ����
    // �� ������ �̿��� ������ ��� �������� ����� ������ �ϴ��� ������ ������ �ϴ��� ����
    // divu, remu�� ���� �� �� ������� �����̹Ƿ� ������ ��� �������� �״�� ����
    wire [31:0] div;
    wire [31:0] divu;
    wire [31:0] rem;
    wire [31:0] remu;
    wire [1:0] mod_div;
    assign mod_div = {aluin1[31],aluin2[31]};    
    assign div = ((mod_div == 2'b00 | mod_div == 2'b11) ? quotient : ~quotient +1);
    assign rem = ((mod_div == 2'b00 | mod_div == 2'b11) ? remainder : ~remainder +1);
    assign divu = quotient;
    assign remu = remainder;
    
    // output part
    always @(*) begin
        if (!rst_n) 
        aluout <= 32'b0;
        else begin
        case(aluop)
            6'd0: aluout <= sum;
            6'd1: aluout <= sum;
            6'd2: aluout <= sll;
            6'd3: aluout <= xor_alu;
            6'd4: aluout <= srl;
            6'd5: aluout <= sra;
            6'd6: aluout <= or_alu;
            6'd7: aluout <= and_alu;
            6'd8: aluout <= slt_alu;
            6'd9: aluout <= sltu_alu;
            6'd16: aluout <= mulh_out;
            6'd17: aluout <= mulh_out;
            6'd18: aluout <= mulh_out;
            6'd22: aluout <= mul_out;
            6'd24: aluout <= div;
            6'd26: aluout <= divu;
            6'd28: aluout <= rem;
            6'd30: aluout <= remu;
                 
                 
    endcase
    end
end   
endmodule
