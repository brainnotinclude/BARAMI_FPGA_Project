`timescale 1ns/1ps
module alu(
    input clk,
    input rst_n,
    input [3:0] aluop,
    input [31:0] aluin1,     // pc�� aluin1���� �ް���
    input [31:0] aluin2,     // imm, shamt�� aluin2���� �ް���
    output reg [31:0] aluout,
    output reg [31:0] slt,
    output reg [31:0] sltu
    );

    // add sub lui auipc part
    wire [31:0] sum;
    wire [31:0] bar_aluin2;
    assign bar_aluin2 = (aluop[0] ? ~aluin2 :aluin2);    // ������ aluin2 �״��, ������ aluin2 �� ��Ʈ�� inverse�� ������ ���
    
    ripple_carry_adder add_ripple_carry_adder(
    .a(aluin1),                       
    .b(bar_aluin2),
    .cin(aluop[0]),
    .sum(sum),
    .cout()
    );            // aluop[0]���� ������ ���� ����, ������ cin���� 1�� ���� ��
   
    // slt sltu part  slt, sltu�� sub���� �� ���� aluout���� �̰� �;����� �׷����� �̸� ������ �� �ִ� ��Ʈ�� �ʿ����� ���� 
    // ��Ʈ�� �߰��ϰų� output�� �߰��ϴ� �� �� output�� �߰��� �̴� ���� ��Ʈ�� �߰��ϴ� ������ �ٲ� �� ����
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
    
    
    // output part
    always @(posedge clk or negedge rst_n) begin
        case(aluop)
            4'h0: begin 
                  aluout <= sum;
                  slt <= 0;
                  sltu <= 0; 
                  end
            4'h1: begin 
                  aluout <= sum;
                  slt <= slt_alu;
                  sltu <= sltu_alu; 
                  end
            4'h2: begin
                  aluout <= sll;
                  slt <= 0;
                  sltu <= 0; 
                  end
            4'h3: begin
                  aluout <= xor_alu;
                  slt <= 0;
                  sltu <= 0; 
                  end
            4'h4: begin
                  aluout <= srl;
                  slt <= 0;
                  sltu <= 0; 
                  end
            4'h5: begin
                  aluout <= sra;
                  slt <= 0;
                  sltu <= 0; 
                  end
            4'h6: begin
                  aluout <= or_alu;
                  slt <= 0;
                  sltu <= 0; 
                  end
            4'h7: begin
                  aluout <= and_alu;
                  slt <= 0;
                  sltu <= 0; 
                  end
            //4'h8:
    
    endcase
end   
endmodule