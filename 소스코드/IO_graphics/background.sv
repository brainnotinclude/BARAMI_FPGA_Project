`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/06 23:36:51
// Design Name: 
// Module Name: background
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


module background(
    input wire [11:0] i_x,
    input wire [11:0] i_y,
    output logic [7:0] red,
    output logic [7:0] green,
    output logic [7:0] blue
    );
    
    always_comb begin
    if (i_y >600 && i_y < 610) begin  // colour square in top-left 256x256 pixels
        red <= 8'b0;
        green <= 8'b0;
        blue <= 8'b11111111;
    end else begin  // background colour
        red <= i_x[7:0];
        green <= i_y[7:0];
        blue <= {i_x[11:8], i_y[11:8]};
    end
end

    
    
endmodule
