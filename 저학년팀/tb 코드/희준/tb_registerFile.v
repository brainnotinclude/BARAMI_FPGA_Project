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
    
    
    always #1 clk = ~clk;

    initial begin
        clk=0;
        rst_n=1;
        #2;
        rst_n = 0;
        #2;
        rst_n = 1;
        //give input signals
        #2;

        //...
        wr_enable_A = 1'b0;              //write enable >> complete
        wr_enable_B = 1'b0;
        map_en_A = 1'b0;                 // decode >> RRF mapping enable: this means that there is a GPR write instruction in decode stage, so we need destination allocation in this cycle
        map_en_B = 1'b0;
        addrA_0 = 5'b10000;            //read addresses
        addrA_1 = 5'b00000;
        addrB_0 = 5'b00000;
        addrB_1 = 5'b00000;
        wraddrA = 5'b00000;            //write addresses for real write -> happens when finishes execution
        wraddrB = 5'b00000;
        wraddrA_map = 5'b00001;        //write addresses for destination allocation
        wraddrB_map = 5'b00000;
        writeDataA = 32'h00000000;        //write data
        writeDataB = 32'h00000000;
        updateEnA = 1'b0;               //retire
        updateEnB = 1'b0;
        updateAddrA = 5'b00000;
        updateAddrB = 5'b00000;
        #2
        //logic for empty rrf entry search
        map_en_A = 1'b1;
        wraddrA_map = 5'b00001;
        #2
        wraddrA_map = 5'b00010;
        #2
        wraddrA_map = 5'b00011;
        #2
        wraddrA_map = 5'd4;
        #2
        wraddrA_map = 5'd5;
        #2
        wraddrA_map = 5'd6;
        #2
        wraddrA_map = 5'd7;
        #2
        wraddrA_map = 5'd8;
        #2
        wraddrA_map = 5'd9;
        #2;
        //decode a3
        addrA_0 = 5'b00001; 
        #2;
        addrA_0 = 5'b00000; 
        //check complete basic function
        map_en_A = 1'b0;
        wr_enable_A = 1'b1;
        wraddrA = 5'b00001;
        writeDataA = 32'd2024;
        #2;
        //check retire basic function
        wr_enable_A = 1'b0;
        updateEnA = 1'b1;
        wraddrA = 5'b00000;
        writeDataA = 32'd0;
        updateAddrA = 5'b00001;
        #2;
        //check each cycle(decode-complete-retire) for B
        //clear arf 2 for B & experiment of A which input complete and retire in same time.> only complete applyed. 
        //complete
        updateEnA = 1'b0;
        wr_enable_A = 1'b1;
        wraddrA = 5'b00010;
        writeDataA = 32'd2021;
        #2;
        //retire
        wr_enable_A = 1'b0;
        updateEnA = 1'b1;
        wraddrA = 5'b00000;
        writeDataA = 32'd0;
        updateAddrA = 5'b00010;
        #2;
        updateEnA = 1'b0;
        //B decode
        map_en_B = 1'b1;
        wraddrB_map = 5'b00001;
        #2
        //B complete
        addrB_0 = 5'b00000; 
        map_en_B = 1'b0;
        wr_enable_B = 1'b1;
        wraddrB = 5'b00001;
        writeDataB = 32'd2023;
        #2;
        //B retire
        wr_enable_B = 1'b0;
        updateEnB = 1'b1;
        wraddrB = 5'b00000;
        writeDataB = 32'd0;
        updateAddrB = 5'b00001;
        #2
        //retire non-valid case
        updateEnA = 1'b1;
        updateAddrA = 5'b00010;
        #2;
        //complete empty arf-rrf case
        wr_enable_A = 1'b1;
        wraddrA = 5'b00000;
        #2;
        //check for decode data input
        //decode a1
        addrA_0 = 5'd1;
        #2;
        //decode a2
        //make arfbusy=1&rrf valid=1
        wr_enable_A = 1'b1;
        wraddrA = 5'b00011;
        writeDataA = 32'd2020;
        #2;
        //check
        addrA_0 = 5'd3;
        #2;
        //decode a4
        addrA_0 = 5'd0;
        addrB_0 = 5'd3;
        #2;
        //decode a5
        wraddrA_map = 5'b00011;
        #2;
        $finish;
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
