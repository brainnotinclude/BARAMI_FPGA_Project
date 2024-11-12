`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/15 10:24:15
// Design Name: 
// Module Name: next_pc_logic
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


module next_pc_logic(
    input clk,
    input rst_n,

    input [11:0] imm_A,
    input [19:0] imm_jal_A,
    input [31:0] imm_jalr_A,   //for jalr 11
    input [1:0] PCSrc_A,
    
    input [11:0] imm_B,
    input [19:0] imm_jal_B,
    input [31:0] imm_jalr_B,   //for jalr 11
    input [1:0] PCSrc_B,
    
    input errorA, 
    input rs_full_A,
    input errorB,
    input rs_full_B,
    input error_decode_A,
    input error_decode_B,
    
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

reg errorA_reg; 
reg rs_full_A_reg;
reg errorB_reg;
reg rs_full_B_reg;
reg error_decode_A_reg;
reg error_decode_B_reg;

assign imm_shift = (PCSrc_A==2'b01) ? {18'b0, imm_A, 2'b0} : (PCSrc_B==2'b01) ? {18'b0, imm_B,2'b0} : 32'b0 ;  // for  branch  01
assign imm_jal_shift = (PCSrc_A==2'b01) ? {10'b0, imm_jal_A, 2'b0} : (PCSrc_B==2'b01) ? {10'b0, imm_jal_B, 2'b0} : 32'b0;   // for jal  10

ripple_carry_adder u_pc_plus_4(
.a  (pcF2),
.b  (32'h4),
.cin(1'b0),
.sum(PCPlus4F),
.cout()
);

assign PCNext1 = PCPlus4F;

ripple_carry_adder u_pc_target(
.a(PCPlus4F),
.b(imm_shift),
.cin(1'b0),
.sum(PCBranch),
.cout()
);

/*always @(*)
begin 
if (PCSrc_A == 2'b00 & PCSrc_B == 2'b00)   begin
    PCNext1 = PCPlus4F;
    PCNext2 = PCNext1_4add;
    end
else if (PCSrc_A == 2'b00 & PCSrc_B == 2'b01) begin
    PCNext1 = PCPlus4F;
    PCNext2 = PCBranch;
    end
else if (PCSrc_A == 2'b00 & PCsrc_B == 2'b10) begin
    PCNext1 = PCPlus4F;
    PCNext2 = imm_jal_shift;
    end
else if (PCSrc_A == 2'b00 & PCSrc_B == 2'b11) begin
    PCNext1 = PCPlus4F;
    PCNext2 = imm_jalr_B;
    end
else if (PCSrc_A == 2'b01) begin
    PCNext1 = PCBranch;
    PCNext2 = PCNext1_4add;
    end
 else if (PCSrc_A == 2'b10) begin
    PCNext1 = imm_jal_shift;
    PCNext2 = PCNext1_4add;
    end
 else if (PCSrc_A == 2'b11) begin
    PCNext1 = imm_jalr_A;
    PCNext2 = PCNext1_4add;
    end
 end
*/

ripple_carry_adder second_inst(
.a  (PCNext1),
.b  (32'h4),
.cin(1'b0),
.sum(PCNext2),
.cout()
);

always@(*)
begin
if(!rst_n)
begin 
errorA_reg= 0;
rs_full_A_reg =0;
errorB_reg = 0;
rs_full_B_reg = 0;
error_decode_A_reg = 0;
error_decode_B_reg = 0;
end
else 
begin 
errorA_reg= errorA;
rs_full_A_reg =rs_full_A;
errorB_reg = errorB;
rs_full_B_reg = rs_full_B;
error_decode_A_reg = error_decode_A;
error_decode_B_reg = error_decode_B;
end
end

always @(posedge clk, negedge rst_n)
begin
if (!rst_n) begin
    pcF1 <= RESET_PC;
    pcF2 <= RESET_PC;
end else if(errorA_reg | rs_full_A_reg | error_decode_A_reg) begin    
    pcF1 <= pcF1;
    pcF2 <= pcF2;
end else if(errorB_reg | rs_full_B_reg | error_decode_B_reg) begin
    pcF1 <= pcF2;
    pcF2 <= PCNext1;
end
else begin
    pcF1 <= PCNext1;
    pcF2 <= PCNext2;
end
end



endmodule
