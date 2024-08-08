`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/08 09:13:11
// Design Name: 
// Module Name: multiplier_all
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

//Module for multiplying unsigned*unsigned, unsigned*signed, signed*signed
//Caution: testbench not performed!!!
module multiplier_all(
    input [1:0] mode,
    input [31:0] a,
    input [31:0] b,
    output reg [63:0] out
    );
    
    reg [31:0] a_temp;
    reg [31:0] b_temp;
    reg [63:0] out_temp;
    
    //mode 00: unsigned*unsigned, mode 01: signed*unsigned, mode 10:signed*signed
    
    multiplier mult(
        .a(a_temp),
        .b(b_temp),
        .out(out-temp)
    );
    
    //Convert negative values into corresponding positive values(2's complement)
    always@(a) begin
        if(mode != 2'b00 && a[31] == 1'b1) begin            //if a=negative
            a_temp = ~a+1'b1;
        end
        else begin
            a_temp = a;
        end 
    end
    
    always@(b) begin
        if(mode == 2'b10 && b[31] == 1'b1) begin            //if b=negative
           b_temp = ~b+1'b1;
        end
        else begin
            b_temp = b;
        end 
    end
    
    //Check the sign of result and match it(2's complement)
    always@(*) begin
        if(mode == 2'b01 && a[31] == 1'b1) begin                //result is negative
            out = ~out_temp+1'b1;
        end
        else if ((mode == 2'b10 && a[31] == 1'b1 && b[31] == 1'b0) || (mode == 2'b10 && a[31] == 1'b0 && b[31] == 1'b1))begin           //result is negative
            out = ~out_temp+1'b1;
        end
        else begin
            out = out_temp;
        end
    end
    
endmodule
