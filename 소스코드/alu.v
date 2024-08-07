`timescale 1ns/1ps
module alu(
    input clk,
    input rst_n,
    input [3:0] aluop,
    input [31:0] aluin1,     // pc는 aluin1으로 받겠음
    input [31:0] aluin2,     // imm, shamt는 aluin2으로 받겠음
    output reg [31:0] aluout,
    output reg [31:0] slt,
    output reg [31:0] sltu
    );

    // add sub lui auipc part
    wire [31:0] sum;
    wire [31:0] bar_aluin2;
    assign bar_aluin2 = (aluop[0] ? ~aluin2 :aluin2);    // 덧셈은 aluin2 그대로, 뺄셈은 aluin2 각 비트를 inverse한 값으로 계산
    
    ripple_carry_adder add_ripple_carry_adder(
    .a(aluin1),                       
    .b(bar_aluin2),
    .cin(aluop[0]),
    .sum(sum),
    .cout()
    );            // aluop[0]으로 덧셈과 뺄셈 구분, 뺄셈은 cin으로 1이 들어가야 함
   
    // slt sltu part  slt, sltu를 sub에서 한 번에 aluout으로 뽑고 싶었으나 그러려면 이를 구분할 수 있는 비트가 필요함을 느낌 
    // 비트를 추가하거나 output을 추가하는 것 중 output을 추가함 이는 추후 비트를 추가하는 것으로 바꿀 수 있음
    wire overflow;
    wire [31:0] slt_alu;    //slt 연산 결과
    wire [31:0] sltu_alu;    // sltu 연산 결과
    
    assign overflow = (aluin1[31] != aluin2[31]) && (sum[31] != aluin1[31]);
    assign slt_alu = {31'b0, (sum[31]^overflow)};             
    assign sltu_alu = ((aluin1 < aluin2) ? 32'b1 :32'b0); // unsigned를 위한 단순 비교
   
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