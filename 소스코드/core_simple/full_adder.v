`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/15 10:42:25
// Design Name: 
// Module Name: full_adder
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


module full_adder (
  input   a,
  input   b,
  input   c_in,
  output  sum,
  output  c_out
);
  
  assign sum  = a ^ b ^ c_in;
  assign c_out = (a & b) | (c_in & (a ^ b));
  
endmodule
