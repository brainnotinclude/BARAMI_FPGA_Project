`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/15 10:43:33
// Design Name: 
// Module Name: multiplier
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


module multiplier(
    input [31:0] a,
    input [31:0] b,
    output reg [63:0] out
    );
    
    integer i;
    
    reg [63:0] temp [31:0];
    always@(*)begin
        out = 0;
        for(i = 0; i<32; i=i+1) begin
            if(b[i] == 1'b1) begin
                temp[i] = a << i;
            end
            else begin
                temp[i] = 0;
            end
        end
 
        for(i = 0; i<32; i=i+1) begin
            out = out + temp[i];
        end
    end
endmodule
