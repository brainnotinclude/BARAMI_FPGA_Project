`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/22 21:09:25
// Design Name: 
// Module Name: decoder
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

//Decoded instruction bits: modified 2024-08-22 By jeyun park
//What do we need?
//32bit for source1, 32bit for source2, valid bit for source1(1bit), valid bit for source2(1bit), 5 bit for Rd
//Also we need control bits: aluop(5bit), dispatch control(2bit), memread/memwrite/memtoreg(3bit), regWrite(1bit), branch(1bit) => 12bit
//We don't have regWrite signal at present: we need to modify decoder logic)
//Arrange it as {aluop, memwrite, memread, memtoreg, branch, regwrite, dispatch_control, s2, s2_valid, s1, s1_valid, rd} => For the ease of modification: aluop signal will change with the expansion of pipeline(complex signal & fp signal added)
//You can modify the design to share map_en and regWrite signal
//core-simple code assumes that decoder decomposes instruction like this: Need to change the arrange in instruction_decompose.v
//To decoder designer: PLEASE READ THIS!!!!
module decoder(
    input clk,
    input rst_n,
    input [31:0] instA,                 //1st instruction
    input [31:0] instB,                 //2nd instruction
    input [31:0] pc,
    
    //From forwarding path
    input [31:0] rs1_ex_forwarding_A,
    input [31:0] rs2_ex_forwarding_A,
    input [31:0] rs1_mem_forwarding_A,
    input [31:0] rs2_mem_forwarding_A,
    input [1:0] rs1_forwarding_bit_A,
    input [1:0] rs2_forwarding_bit_A,
    
    input [31:0] rs1_ex_forwarding_B,
    input [31:0] rs2_ex_forwarding_B,
    input [31:0] rs1_mem_forwarding_B,
    input [31:0] rs2_mem_forwarding_B,
    input [1:0] rs1_forwarding_bit_B,
    input [1:0] rs2_forwarding_bit_B,
    
    //From RF
    input [31:0] s1A,
    input [31:0] s2A,
    input [31:0] s1B,
    input [31:0] s2B,
    input rs1A_valid,
    input rs2A_valid,
    input rs1B_valid,
    input rs2B_valid,
    
    output [82:0] decoded_instA,               //Decoded instructions: need to be vectorized!!
    output [82:0] decoded_instB,
    
    //To RF
    output map_en_A,
    output map_en_B,
    output [4:0] rs1A,
    output [4:0] rs2A,
    output [4:0] rs1B,
    output [4:0] rs2B,
    output [4:0] rdA,
    output [4:0] rdB
    );

    //Decode an instruction. We need two instance(decomposeA, decomposeB) because we should decode 2 inst/cycle.
    instruction_decompose decomposeA(
        .inst(instA),
        .s1(s1A),
        .s2(s2A),
        .rs1_valid(rs1A_valid),
        .rs2_valid(rs2A_valid),
        .pc(pc),
        .rs1_ex_forwarding(rs1_ex_forwarding_A),
        .rs2_ex_forwarding(rs2_ex_forwarding_A),
        .rs1_mem_forwarding(rs1_mem_forwarding_A),
        .rs2_mem_forwarding(rs2_mem_forwarding_A),
        .rs1_forwarding_bit(rs1_forwarding_bit_A),
        .rs2_forwarding_bit(rs2_forwarding_bit_A),
        
        .map_en(map_en_A),
        .rs1(rs1A),
        .rs2(rs2A),
        .rd(rdA),
        .decomposed_inst(decoded_instA)
    );
    
    instruction_decompose decomposeB(
        .inst(instB),
        .s1(s1B),
        .s2(s2B),
        .rs1_valid(rs1B_valid),
        .rs2_valid(rs2B_valid),
        .pc(pc),
        .rs1_ex_forwarding(rs1_ex_forwarding_B),
        .rs2_ex_forwarding(rs2_ex_forwarding_B),
        .rs1_mem_forwarding(rs1_mem_forwarding_B),
        .rs2_mem_forwarding(rs2_mem_forwarding_B),
        .rs1_forwarding_bit(rs1_forwarding_bit_B),
        .rs2_forwarding_bit(rs2_forwarding_bit_B),
        
        .map_en(map_en_B),
        .rs1(rs1B),
        .rs2(rs2B),
        .rd(rdB),
        .decomposed_inst(decoded_instB)
    );
    
endmodule
