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
    input [31:0] pcA,                   // 명령어 두개니까 각자 pc 필요
    input [31:0] pcB,
    input [31:0] forwarding,         // 연산 결과
  //  input [31:0] forwarding_B,
    input [4:0] forwarding_addr,     // rd가 무엇인지
  //  input [4:0] forwarding_addr_B,
    
    //From RF
    input [31:0] s1A,
    input [31:0] s2A,
    input [31:0] s1B,
    input [31:0] s2B,
    input rs1A_valid,
    input rs2A_valid,
    input rs1B_valid,
    input rs2B_valid,
    
    output [115:0] decoded_instA,               //Decoded instructions: need to be vectorized!!
    output [115:0] decoded_instB,
    
    //To RF
    output map_en_A,
    output map_en_B,
    output [4:0] rs1A,
    output [4:0] rs2A,
    output [4:0] rs1B,
    output [4:0] rs2B,
    output [4:0] rdA,
    output [4:0] rdB,
    output error_A,               //decompose에서 받은 에러 그대로 밖으로 보냄
    output error_B,
    
    output jump_A,
    output fp_A,
    output fence_A,
    output ebreak_A,
    output ecall_A,
    output jump_B,
    output fp_B,
    output fence_B,
    output ebreak_B,
    output ecall_B
    );
  
    //Decode an instruction. We need two instance(decomposeA, decomposeB) because we should decode 2 inst/cycle.
    instruction_decompose decomposeA(
        .inst(instA),
        .s1(s1A),
        .s2(s2A),
        .rs1_valid(rs1A_valid),
        .rs2_valid(rs2A_valid),
        .pc(pcA),
        .forwarding(forwarding),
        .forwarding_addr(forwarding_addr),
        
        .map_en(map_en_A),
        .rs1(rs1A),
        .rs2(rs2A),
        .rd(rdA),
        .decomposed_inst(decoded_instA),
        .error(error_A),
        .jump(jump_A),
        .fp(fp_A),
        .fence(fence_A),
        .ebreak(ebreak_A),
        .ecall(ecall_A)
    );
    
    instruction_decompose decomposeB(
        .inst(instB),
        .s1(s1B),
        .s2(s2B),
        .rs1_valid(rs1B_valid),
        .rs2_valid(rs2B_valid),
        .pc(pcB),
        .forwarding(forwarding),
        .forwarding_addr(forwarding_addr),
        
        .map_en(map_en_B),
        .rs1(rs1B),
        .rs2(rs2B),
        .rd(rdB),
        .decomposed_inst(decoded_instB),
        .error(error_B),
        .jump(jump_B),
        .fp(fp_B),
        .fence(fence_B),
        .ebreak(ebreak_B),
        .ecall(ecall_B)
    );
    
endmodule
