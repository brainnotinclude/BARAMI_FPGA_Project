`timescale 1ns/ 1ps


module next_pc_logic(
    input clk,
    input rst_n,
    //input EN,
    input [11:0] imm,
    input [19:0] imm_jal,
    input [31:0] imm_jalr,   //for jalr 11
    input [1:0] PCSrc,
    
    input errorA, 
    input rs_full_A,
    input errorB,
    input rs_full_B,
    
  //  output [31:0] PCPlus4F,
    output reg [31:0] pcF1,
    output reg [31:0] pcF2
    );
    
parameter RESET_PC = 32'h0001_0000;
wire [31:0] PCNext1;
wire [31:0] PCBranch;
wire [31:0] PCNext2;
wire [31:0] imm_shift;
wire [31:0] imm_jal_shift;
wire [31:0] PCPlus4F;

assign imm_shift = {18'b0, imm << 2};  // for  branch  01
assign imm_jal_shift = {10'b0, imm_jal<<2};   // for jal  10

ripple_carry_adder u_pc_plus_4(
.a  (pcF1),
.b  (32'h8),
.cin(1'b0),
.sum(PCPlus4F),
.cout()
);

ripple_carry_adder u_pc_target(
.a(PCPlus4F),
.b(imm_shift),
.cin(1'b0),
.sum(PCBranch),
.cout()
);

assign PCNext1 =((PCSrc == 2'b00) ? PCPlus4F : ((PCSrc == 2'b01) ? PCBranch :((PCSrc == 2'b10) ? imm_jal_shift :imm_jalr)));

ripple_carry_adder second_inst(
.a  (PCNext1),
.b  (32'h4),
.cin(1'b0),
.sum(PCNext2),
.cout()
);


always @(posedge clk, negedge rst_n)
begin
if (!rst_n) begin
    pcF1 <= RESET_PC;
    pcF2 <= RESET_PC + 4;
end else if(errorA | rs_full_A) begin    
    pcF1 <= pcF1;
    pcF2 <= pcF2;
end else if(errorB | rs_full_B) begin
    pcF1 <= pcF2;
    pcF2 <= PCNext1;
end
else begin
    pcF1 <= PCNext1;
    pcF2 <= PCNext2;
end
end



endmodule

