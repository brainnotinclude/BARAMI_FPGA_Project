`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/28 03:23:37
// Design Name: 
// Module Name: tb_instruction_decompose
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


module tb_instruction_decompose(

    );
    reg [31:0] inst;
    reg [31:0] s1;
    reg [31:0] s2;
    reg rs1_valid;
    reg rs2_valid;
    reg [31:0] pc;
    reg [31:0] rs1_ex_forwarding;
    reg [31:0] rs2_ex_forwarding;
    reg [31:0] rs1_mem_forwarding;
    reg [31:0] rs2_mem_forwarding;
    reg [1:0] rs1_forwarding_bit;
    reg [1:0] rs2_forwarding_bit;           // for forwarding, 00 -> rs1 , 01 -> ex forwarding, 10 -> mem forwarding
    
    wire map_en;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [82:0] decomposed_inst;
    
    reg rst_n;
    
        
    always@(*)
    begin
    if(!rst_n) begin
    inst = 32'd0;
    s1 = 32'd0;
    s2 = 32'd0;
    rs1_valid = 1'd0;
    rs2_valid = 1'd0;
    pc = 32'd0;
    rs1_ex_forwarding = 32'd0;
    rs2_ex_forwarding = 32'd0;
    rs1_mem_forwarding = 32'd0;
    rs2_mem_forwarding = 32'd0;
    rs1_forwarding_bit = 2'd0;
    rs2_forwarding_bit = 2'd0;
        end
    end
    
    initial
    begin
    rst_n = 0; //basic reset - decode signal initial reset testing
    #2 //add test from register data. funct7:0000000 / rs2: 00010 / rs1:00001 / funct3 : 000 / rd:00011 / opcode: 0110011
    rst_n = 1;
    
    inst = 32'b0000000_00010_00001_00011_0110011;
    //inst = 32'b1100110_11000_10000_01000_0000000;
    s1 = 32'd2;
    s2 = 32'd1;
    rs1_valid = 1'd1;
    rs2_valid = 1'd1;
    pc = 32'd0;
    rs1_ex_forwarding = 32'd0;
    rs2_ex_forwarding = 32'd0;
    rs1_mem_forwarding = 32'd0;
    rs2_mem_forwarding = 32'd0;
    rs1_forwarding_bit = 2'd0;
    rs2_forwarding_bit = 2'd0;
    #2
    $finish;
    end
    
    
    
    instruction_decompose uut(
    .inst(inst),
    .s1(s1),
    .s2(s2),
    .rs1_valid(rs1_valid),
    .rs2_valid(rs2_valid),
    .pc(pc),
    .rs1_ex_forwarding(rs1_ex_forwarding),
    .rs2_ex_forwarding(rs2_ex_forwarding),
    .rs1_mem_forwarding(rs1_mem_forwarding),
    .rs2_mem_forwarding(rs2_mem_forwarding),
    .rs1_forwarding_bit(rs1_forwarding_bit),
    .rs2_forwarding_bit(rs2_forwarding_bit),           // for forwarding, 00 -> rs1 , 01 -> ex forwarding, 10 -> mem forwarding

    .map_en(map_en),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .decomposed_inst(decomposed_inst)
    );

    
endmodule
