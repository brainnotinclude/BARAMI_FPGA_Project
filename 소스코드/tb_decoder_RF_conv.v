`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/12 20:48:09
// Design Name: 
// Module Name: tb_decoder_RF_conv
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


module tb_decoder_RF_conv(
    );
    
    reg [31:0] instA;                 //1st instruction
    reg [31:0] instB;                 //2nd instruction
    wire [70:0] decoded_instA;               //Decoded instructions: need to be vectorized!!
    wire [70:0] decoded_instB;
    wire errorA;                      //Connected to Fetch/Decode FF and Decode/Dispatch FF. If error, then value of (corresponding) Fetch/Decode FF should be preserved. Insert bubble to Decode/Dispatch. 
    wire errorB;
    
    //For test: this variables model the ex-decoder stages.
    reg [4:0] wraddrA;
    reg [4:0] wraddrB;
    reg [31:0] writeDataA;
    reg [31:0] writeDataB;
    reg updateEnA;
    reg updateEnB;
    reg [4:0] updateAddrA;
    reg [4:0] updateAddrB;
    reg wr_enable_A;
    reg wr_enable_B;
    
    reg clk;
    reg rst_n;
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        rst_n = 1;
        wraddrA = 0;
        wraddrB = 0;
        writeDataA = 0;
        writeDataB = 0;
        updateEnA = 0;
        updateEnB = 0;
        updateAddrA = 0;
        updateAddrB = 0;
        wr_enable_A = 0;
        wr_enable_B = 0;
        
        //add
        instA = 32'b0000000_00000_00001_000_00010_0110011;
        instB = 32'b0000000_00000_00001_000_00011_0110011;

        #10;
        rst_n=0;
        #3;
        rst_n=1;
        #7;
        //slli& addi
        instA = 32'b0000000_00111_00001_001_00100_0010011;
        instB = 32'b000000011111_00001_000_00101_0010011;
        
        #10;
        //lui&auipc
        instA = 32'b00000000000000001000_00110_0110111;
        instB = 32'b00000000000000001000_00111_0010111;
        
        #10;
        //mul
        instA = 32'b0000001_00000_00001_000_01000_0110011;
        instB = 32'b0000001_00000_00001_000_01001_0110011;
        
    end
    
    decoder_RF_conv uut(
    .clk(clk),
    .rst_n(rst_n),
    .instA(instA),                 //1st instruction
    .instB(instB),                 //2nd instruction
    .decoded_instA(decoded_instA),               //Decoded instructions: need to be vectorized!!
    .decoded_instB(decoded_instB),
    .errorA(errorA),                      //Connected to Fetch/Decode FF and Decode/Dispatch FF. If error, then value of (corresponding) Fetch/Decode FF should be preserved. Insert bubble to Decode/Dispatch. 
    .errorB(errorB)
    );
endmodule
