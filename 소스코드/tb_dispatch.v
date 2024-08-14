`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/14 10:38:50
// Design Name: 
// Module Name: tb_dispatch
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

//Note: It tests few cases, so please test more case.
module tb_dispatch(
    
    );
    
    reg [77:0] instA;             //Caution!!!: Bit width should be match with decoder output
    reg [77:0] instB;
    reg complex_empty_0;          //Distributed RS
    reg complex_empty_1;
    reg simple_empty_0;
    reg simple_empty_1;
    reg fp_empty_0;
    reg fp_empty_1;
    
    wire [75:0] complex_0_data;
    wire complex_0_valid;
    wire [75:0] complex_1_data;
    wire complex_1_valid;
    wire [75:0] simple_0_data;
    wire simple_0_valid;
    wire [75:0] simple_1_data;
    wire simple_1_valid;
    wire [75:0] fp_0_data;
    wire fp_0_valid;
    wire [75:0] fp_1_data;
    wire fp_1_valid;
    wire rs_full_A;               //For stall: It means that RS corresponding to type of instruction A is full. It doesn't mean all RS is full.
    wire rs_full_B;
    
    initial begin
        //Both simple, all entry empty
        instA = {76'b0, 2'b11};
        instB = {76'b0, 2'b11};
        complex_empty_0 = 1'b1;
        complex_empty_1 = 1'b1;
        simple_empty_0 = 1'b1;
        simple_empty_1 = 1'b1;
        fp_empty_0 = 1'b1;
        fp_empty_1 = 1'b1;
        
        #10
        //Both bubble
        instA = {76'b0, 2'b00};
        instB = {76'b0, 2'b00};
        complex_empty_0 = 1'b1;
        complex_empty_1 = 1'b1;
        simple_empty_0 = 1'b1;
        simple_empty_1 = 1'b1;
        fp_empty_0 = 1'b1;
        fp_empty_1 = 1'b1;
        
        #10
        //Both simple, simple entries full
        instA = {76'b0, 2'b11};
        instB = {76'b0, 2'b11};
        complex_empty_0 = 1'b1;
        complex_empty_1 = 1'b1;
        simple_empty_0 = 1'b0;
        simple_empty_1 = 1'b0;
        fp_empty_0 = 1'b1;
        fp_empty_1 = 1'b1;
        
        #10
        //Both complex, all entry empty
        instA = {76'b0, 2'b01};
        instB = {76'b0, 2'b01};
        complex_empty_0 = 1'b1;
        complex_empty_1 = 1'b1;
        simple_empty_0 = 1'b1;
        simple_empty_1 = 1'b1;
        fp_empty_0 = 1'b1;
        fp_empty_1 = 1'b1;
        
        #10
        //Both simple, complex/simple entries all full
        instA = {76'b0, 2'b11};
        instB = {76'b0, 2'b11};
        complex_empty_0 = 1'b0;
        complex_empty_1 = 1'b0;
        simple_empty_0 = 1'b0;
        simple_empty_1 = 1'b0;
        fp_empty_0 = 1'b1;
        fp_empty_1 = 1'b1;
        
    end
    
    
    dispatch uut(
    .instA(instA),             //Caution!!!: Bit width should be match with decoder output
    .instB(instB),
    .complex_empty_0(complex_empty_0),          //Distributed RS
    .complex_empty_1(complex_empty_1),
    .simple_empty_0(simple_empty_0),
    .simple_empty_1(simple_empty_1),
    .fp_empty_0(fp_empty_0),
    .fp_empty_1(fp_empty_1),
    
    .complex_0_data(complex_0_data),
    .complex_0_valid(complex_0_valid),
    .complex_1_data(complex_1_data),
    .complex_1_valid(complex_1_valid),
    .simple_0_data(simple_0_data),
    .simple_0_valid(simple_0_valid),
    .simple_1_data(simple_1_data),
    .simple_1_valid(simple_1_valid),
    .fp_0_data(fp_0_data),
    .fp_0_valid(fp_0_valid),
    .fp_1_data(fp_1_data),
    .fp_1_valid(fp_1_valid),
    .rs_full_A(rs_full_A),               //For stall: It means that RS corresponding to type of instruction A is full. It doesn't mean all RS is full.
    .rs_full_B(rs_full_B)
    );
endmodule
