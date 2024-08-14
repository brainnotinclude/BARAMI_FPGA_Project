`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/12 23:32:01
// Design Name: 
// Module Name: dispatch
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


//Caution: This file is not completed. Synthesis. simulation is needed. Also, comments should be written
//Assume input instA/B is rs2_vt(32bit) + valid bit(1bit) + rs1_vt(32bit) + valid bit(1bit) + rd(5bit) + ALU_ctrl(5bit) + dispatch_ctrl(2bit) = 78bit
//Dispatch control sigal -> 11: Both simple/complex, 01: Complex only, 10:FP only
//Control signal 00 will mean bubble.
module dispatch(
    input [77:0] instA,             //Caution!!!: Bit width should be match with decoder output
    input [77:0] instB,
    input complex_empty_0,          //Distributed RS: Empty bit for each RS entry
    input complex_empty_1,
    input simple_empty_0,
    input simple_empty_1,
    input fp_empty_0,
    input fp_empty_1,
    
    //Dispatch module makes an output for an instruction to one of RS entries. We need data port and valid bit(So the entry knows that it should save given data) 
    output reg [75:0] complex_0_data,          
    output reg complex_0_valid,
    output reg [75:0] complex_1_data,
    output reg complex_1_valid,
    output reg [75:0] simple_0_data,
    output reg simple_0_valid,
    output reg [75:0] simple_1_data,
    output reg simple_1_valid,
    output reg [75:0] fp_0_data,
    output reg fp_0_valid,
    output reg [75:0] fp_1_data,
    output reg fp_1_valid,
    output reg rs_full_A,               //For stall: It means that RS corresponding to type of instruction A is full. It doesn't mean all RS is full.
    output reg rs_full_B
    );
    
    wire [5:0] rs_valid;
    reg [5:0] rs_valid_B;
    
    wire [1:0] dispatch_control_A;
    wire [1:0] dispatch_control_B;
    reg [2:0] selected_RS_A;
    reg [2:0] selected_RS_B;
    
    
    assign rs_valid = {complex_empty_0, complex_empty_1, simple_empty_0, simple_empty_1, fp_empty_0, fp_empty_1};                           //Concat the valid bits for each entries
    assign dispatch_control_A = instA[1:0];                 //Lower 2 bits are control bits for dispatch module 
    assign dispatch_control_B = instB[1:0];
    
    
    //Select RS position
    always@(*) begin
        //Except valid output port, all outputs should be marked as invalid.
        complex_0_data = 0;
        complex_0_valid = 0;
        complex_1_data = 0;
        complex_1_valid = 0;
        simple_0_data = 0;
        simple_0_valid = 0;
        simple_1_data = 0;
        simple_1_valid = 0;
        fp_0_data = 0;
        fp_0_valid = 0;
        fp_1_data = 0;
        fp_1_valid = 0;
        rs_valid_B = rs_valid;
        rs_full_A = 0;                          
        rs_full_B = 0;
        
        if(dispatch_control_A == 2'b11) begin
            casex(rs_valid[5:2])                //"Simple"type can goes into complex0/1, simple0/1
                4'bxxx1: begin
                    simple_1_data = instA[77:2];
                    simple_1_valid = 1'b1;
                    rs_valid_B[2] = 1'b0;
                end
                4'bxx10: begin
                    simple_0_data = instA[77:2];
                    simple_0_valid = 1'b1;
                    rs_valid_B[3] = 1'b0;
                end
                4'bx100: begin
                    complex_1_data = instA[77:2];
                    complex_1_valid = 1'b1;
                    rs_valid_B[4] = 1'b0;
                end
                4'b1000: begin
                    complex_0_data = instA[77:2];
                    complex_0_valid = 1'b1;
                    rs_valid_B[5] = 1'b0;
                end
                default:                    //error case: RS full
                    rs_full_A = 1'b1;
            endcase
        end
        else if(dispatch_control_A == 2'b01) begin
            casex(rs_valid[5:4])                //"Complex" type can goes into complex 0/1
                2'bx1: begin
                    complex_1_data = instA[77:2];
                    complex_1_valid = 1'b1;
                    rs_valid_B[4] = 1'b0;
                end
                2'b10: begin
                    complex_0_data = instA[77:2];
                    complex_0_valid = 1'b1;
                    rs_valid_B[5] = 1'b0;
                end
                default:                    //error case: RS full
                    rs_full_A = 1'b1;
            endcase
        end
        else if(dispatch_control_A == 2'b10) begin
            casex(rs_valid[1:0])                //"FP" type can goes into FP 0/1
                2'bx1: begin
                    fp_1_data = instA[77:2];
                    fp_1_valid = 1'b1;
                    rs_valid_B[0] = 1'b0;
                end
                2'b10: begin
                    fp_0_data = instA[77:2];
                    fp_0_valid = 1'b1;
                    rs_valid_B[1] = 1'b0;
                end
                default:                    //error case: RS full
                    rs_full_A = 1'b1;
            endcase
        end
        else if(dispatch_control_A == 2'b00)begin
            //Do nothing;
        end
        
        //rs_valid_B = rs_valid | (6'b000001 << selected_RS_A);           //Index 번호 주의할것!!!!!!!
        
        //Handle same as instruction A, but should not select port that is using by A: So use rs_valid_B 
        if(dispatch_control_B == 2'b11) begin
            casex(rs_valid_B[5:2])
                4'bxxx1: begin
                    simple_1_data = instA[77:2];
                    simple_1_valid = 1'b1;
                end
                4'bxx10: begin
                    simple_0_data = instA[77:2];
                    simple_0_valid = 1'b1;
                end
                4'bx100: begin
                    complex_1_data = instA[77:2];
                    complex_1_valid = 1'b1;
                end
                4'b1000: begin
                    complex_0_data = instA[77:2];
                    complex_0_valid = 1'b1;
                end
                default:                    //error case: RS full
                    rs_full_B = 1'b1;
            endcase
        end
        else if(dispatch_control_B == 2'b01) begin
            casex(rs_valid_B[5:4])
                2'bx1: begin
                    complex_1_data = instA[77:2];
                    complex_1_valid = 1'b1;
                end
                2'b10: begin
                    complex_0_data = instA[77:2];
                    complex_0_valid = 1'b1;
                end
                default:                    //error case: RS full
                    rs_full_B = 1'b1;
            endcase
        end
        else if(dispatch_control_B == 2'b10) begin
            casex(rs_valid_B[1:0])
                2'bx1: begin
                    fp_1_data = instA[77:2];
                    fp_1_valid = 1'b1;
                end
                2'b10: begin
                    fp_0_data = instA[77:2];
                    fp_0_valid = 1'b1;
                end
                default:                    //error case: RS full
                    rs_full_B = 1'b1;
            endcase
        end
        else if(dispatch_control_B == 2'b00) begin
            //Do nothing
        end
    end
    
endmodule
