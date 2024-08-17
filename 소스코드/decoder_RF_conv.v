`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/09 10:15:07
// Design Name: 
// Module Name: decoder_RF_conv
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

//Decoded instruction structure
//Rs2 value or tag(32bit) + Rs2 valid bit(1bit) + Rs1 value or tag(32bit) + Rs1 valid bit(1bit) + Rd address(5bit) + ctrl_signal(?bit)
//Control signal: ALU_ctrl(5bit)+Dispatch_ctrl(2bit)+...
module decoder_RF_conv(
    input clk,
    input rst_n,
    input [31:0] instA,                 //1st instruction
    input [31:0] instB,                 //2nd instruction
    input [31:0] pc,
    
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
    
    output [82:0] decoded_instA,               //Decoded instructions: need to be vectorized!!
    output [82:0] decoded_instB,
    output errorA,                      //Connected to Fetch/Decode FF and Decode/Dispatch FF. If error, then value of (corresponding) Fetch/Decode FF should be preserved. Insert bubble to Decode/Dispatch. 
    output errorB,
    
    //For test: these variables model the signals from ex-decoder stages.
    input [4:0] wraddrA,
    input [4:0] wraddrB,
    input [31:0] writeDataA,
    input [31:0] writeDataB,
    input updateEnA,
    input updateEnB,
    input [4:0] updateAddrA,
    input [4:0] updateAddrB,
    input wr_enable_A,
    input wr_enable_B
    );
    
    //Connect to RF
    wire map_en_A;
    wire map_en_B;
    wire [31:0] s1A;
    wire [31:0] s2A;
    wire [31:0] s1B;
    wire [31:0] s2B;
    
    
    
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
    
    //Option 1) RegisterFile connected to Decoder and Complete/Retire, so ultimately registerFile should not be a submodule of decoder; Option 2)Maybe put RF as submoudle and give more input to decoder is more clear
    //However, for decoder funtionality check, I designed circuit as option 1. It is OK to shift to design that follows option 2.
    registerFile RF_integer(
        .clk(clk),
        .rst_n(rst_n),
        .wr_enable_A(wr_enable_A),              //write enable
        .wr_enable_B(wr_enable_B),
        .map_en_A(map_en_A),                 //RRF mapping enable: this means that there is a GPR write instruction in decode stage, so we need destination allocation in this cycle
        .map_en_B(map_en_B),
        .addrA_0(rs1A),            //read addresses
        .addrA_1(rs2A),
        .addrB_0(rs1B),
        .addrB_1(rs2B),
        .wraddrA(wraddrA),            //write addresses for real write -> happens when finishes execution  //
        .wraddrB(wraddrB),
        .wraddrA_map(rdA),        //write addresses for destination allocation
        .wraddrB_map(rdB),
        .writeDataA(writeDataA),        //write data        ->happens when finishes execution
        .writeDataB(writeDataB),
        .updateEnA(updateEnA),          //happens when instruction retired
        .updateEnB(updateEnB),          
        .updateAddrA(updateAddrA),
        .updateAddrB(updateAddrB),
        .dataA_0(s1A),         //read data for A
        .dataA_0_ready(rs1A_valid),          //check if data is valid. If not, decoder should not use the data and pass register tag to next stage
        .dataA_1(s2A),
        .dataA_1_ready(rs2A_valid),
        .dataB_0(s1B),
        .dataB_0_ready(rs1B_valid),
        .dataB_1(s2B),
        .dataB_1_ready(rs2B_valid),
        .wrA_rrError(errorA),             //If RRF is full then we can't use register renaming
        .wrB_rrError(errorB)
    );
    
    /*registerFile RF_fp(
        .clk(clk),
        .rst_n(rst_n),
        .wr_enable_A(wr_enable_A),              //write enable
        .wr_enable_B(wr_enable_B),
        .map_en_A(map_en_A),                 //RRF mapping enable: this means that there is a GPR write instruction in decode stage, so we need destination allocation in this cycle
        .map_en_B(map_en_B),
        .addrA_0(rs1A),            //read addresses
        .addrA_1(rs2A),
        .addrB_0(rs1B),
        .addrB_1(rs2B),
        .wraddrA(wraddrA),            //write addresses for real write -> happens when finishes execution  //
        .wraddrB(wraddrB),
        .wraddrA_map(rdA),        //write addresses for destination allocation
        .wraddrB_map(rdB),
        .writeDataA(writeDataA),        //write data        ->happens when finishes execution
        .writeDataB(writeDataB),
        .updateEnA(updateEnA),          //happens when instruction retired
        .updateEnB(updateEnB),          
        .updateAddrA(updateAddrA),
        .updateAddrB(updateAddrB),
        .dataA_0(s1A),         //read data for A
        .dataA_0_ready(rs1A_valid),          //check if data is valid. If not, decoder should not use the data and pass register tag to next stage
        .dataA_1(s2A),
        .dataA_1_ready(rs2A_valid),
        .dataB_0(s1B),
        .dataB_0_ready(rs1B_valid),
        .dataB_1(s2B),
        .dataB_1_ready(rs2B_valid),
        .wrA_rrError(errorA),             //If RRF is full then we can't use register renaming
        .wrB_rrError(errorB)
    );*/
endmodule
