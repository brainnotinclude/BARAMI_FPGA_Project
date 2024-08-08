`timescale 1ns/1ps
module alu(
    input clk,
    input rst_n,
    input [4:0] aluop,
    input [31:0] aluin1,     // pc�� aluin1���� �ް���
    input [31:0] aluin2,     // imm, shamt�� aluin2���� �ް���
    output reg [31:0] aluout
    );

    // add sub lui auipc part
    wire [31:0] sum;
    wire [31:0] bar_aluin2;
    assign bar_aluin2 = (aluop[0]|aluop[4] ? ~aluin2 :aluin2);    // ������ aluin2 �״��, ������ aluin2 �� ��Ʈ�� inverse�� ������ ���
    
    ripple_carry_adder add_ripple_carry_adder(
    .a(aluin1),                       
    .b(bar_aluin2),
    .cin(aluop[0]|aluop[4]),
    .sum(sum),
    .cout()
    );            // aluop[0]|aluop[4]���� ������ ���� ����, ������ cin���� 1�� ���� �� sub�� 00001, slt�� 01000���� �ֱ� ������ ���� or�� ��
   
    // slt sltu part  
    wire overflow;
    wire [31:0] slt_alu;    //slt ���� ���
    wire [31:0] sltu_alu;    // sltu ���� ���
    
    assign overflow = (aluin1[31] != aluin2[31]) && (sum[31] != aluin1[31]);
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
    
    
    // output part
    always @(posedge clk or negedge rst_n) begin
        case(aluop)
            5'h0: aluout <= sum;
            5'h1: aluout <= sum;
            5'h2: aluout <= sll;
            5'h3: aluout <= xor_alu;
            5'h4: aluout <= srl;
            5'h5: aluout <= sra;
            5'h6: aluout <= or_alu;
            5'h7: aluout <= and_alu;
            5'h8: aluout <= slt_alu|sltu_alu;
            5'h16: aluout <= mulh_out;
            5'h17: aluout <= mulh_out;
            5'h18: aluout <= mulh_out;
            5'h22: aluout <= mul_out;
                  
                  
                  
    endcase
end   
endmodule