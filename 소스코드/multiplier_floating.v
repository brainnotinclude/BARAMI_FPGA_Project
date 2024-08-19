`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/08 10:12:42
// Design Name: 
// Module Name: mutiplier
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


module multiplier_floating(
    input [23:0] a,
    input [23:0] b,
    output reg [47:0] out
    );
    
    integer i;
    
    reg [47:0] temp [23:0];
    always@(*)begin
        out = 0;
        for(i = 0; i<24; i=i+1) begin
            if(b[i] == 1'b1) begin
                temp[i] = a << i;
            end
            else begin
                temp[i] = 0;
            end
        end
 
        for(i = 0; i<24; i=i+1) begin
            out = out + temp[i];
        end
    end
endmodule
