`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/07 22:25:12
// Design Name: 
// Module Name: tb_registerFile_skeleton
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


module tb_registerFile_skeleton(

    );
    
    reg clk;
    reg rst_n;
    reg wr_enable_A;              //write enable
    reg wr_enable_B;
    reg map_en_A;                 //RRF mapping enable: this means that there is a GPR write instruction in decode stage, so we need destination allocation in this cycle
    reg map_en_B;
    reg [4:0] addrA_0;            //read addresses
    reg [4:0] addrA_1;
    reg [4:0] addrB_0;
    reg [4:0] addrB_1;
    reg [4:0] wraddrA;            //write addresses for real write -> happens when finishes execution
    reg [4:0] wraddrB;
    reg [4:0] wraddrA_map;        //write addresses for destination allocation
    reg [4:0] wraddrB_map;
    reg [31:0] writeDataA;        //write data
    reg [31:0] writeDataB;
    reg updateEnA;
    reg updateEnB;
    reg [4:0] updateAddrA;
    reg [4:0] updateAddrB;
    wire[31:0] dataA_0;         //read data for A
    wire dataA_0_ready;          //check if data is valid. If not, decoder should not use the data and pass register tag to next stage
    wire [31:0] dataA_1;
    wire dataA_1_ready;
    wire [31:0] dataB_0;
    wire dataB_0_ready;
    wire [31:0] dataB_1;
    wire dataB_1_ready;
    wire wrA_rrError;             //If RRF is full then we can't use register renaming
    wire wrB_rrError;
    
    
    always #5 clk = ~clk;
    initial begin
        clk=0;
        rst_n=1;
        
        #3;
        rst_n = 0;
        #7
        rst_n = 1;
        //give input signals
        #5
        addrA_0 = 5'd0;
        addrB_0 = 5'd1;
        //...
    end
    
    registerFile uut(
    .clk(clk),
    .rst_n(rst_n),
    .wr_enable_A(wr_enable_A),
    .wr_enable_B(wr_enable_B),
    .map_en_A(map_en_A),
    .map_en_B(map_en_B),
    .addrA_0(addrA_0),
    .addrA_1(addrA_1),
    .addrB_0(addrB_0),
    .addrB_1(addrB_1),
    .wraddrA(wraddrA),
    .wraddrB(wraddrB),
    .wraddrA_map(wraddrA_map),
    .wraddrB_map(wraddrB_map),
    .writeDataA(writeDataA),
    .writeDataB(writeDataB),
    .updateEnA(updateEnA),
    .updateEnB(updateEnB),
    .updateAddrA(updateAddrA),
    .updateAddrB(updateAddrB),
    .dataA_0(dataA_0),
    .dataA_0_ready(dataA_0_ready),
    .dataA_1(dataA_1),
    .dataA_1_ready(dataA_1_ready),
    .dataB_0(dataB_0),
    .dataB_0_ready(dataB_0_ready),
    .dataB_1(dataB_1),
    .dataB_1_ready(dataB_1_ready),
    .wrA_rrError(wrA_rrError),
    .wrB_rrError(wrB_rrError)
    );
endmodule
