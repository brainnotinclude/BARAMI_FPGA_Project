`timescale 1ns / 1ps
module dispatch_tb;

    // Inputs
    reg [77:0] instA;
    reg [77:0] instB;
    reg complex_empty_0;
    reg complex_empty_1;
    reg simple_empty_0;
    reg simple_empty_1;
    reg fp_empty_0;
    reg fp_empty_1;

    // Outputs
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
    wire rs_full_A;
    wire rs_full_B;

    // Instantiate the Unit Under Test (UUT)
    dispatch uut (
        .instA(instA), 
        .instB(instB), 
        .complex_empty_0(complex_empty_0), 
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
        .rs_full_A(rs_full_A), 
        .rs_full_B(rs_full_B)
    );

    initial begin
        // Initialize Inputs
        instA = {76'b0, 2'b11};
        instB = {76'b0, 2'b11};
        complex_empty_0 = 1'b1;
        complex_empty_1 = 1'b1;
        simple_empty_0 = 1'b1;
        simple_empty_1 = 1'b1;
        fp_empty_0 = 1'b1;
        fp_empty_1 = 1'b1;

        #10
        // Test Case 1: Both instA and instB are FP instructions, and all FP entries are empty. 
        // Both should be successfully dispatched to FP reservation stations.
        instA = {76'b0, 2'b10};  // FP instruction
        instB = {76'b0, 2'b10};  // FP instruction
        fp_empty_0 = 1'b1;
        fp_empty_1 = 1'b1;
        
        #10
        // Test Case 2: Both instA and instB are FP instructions, but both FP entries are full.
        // Neither instruction should be dispatched, and rs_full_A and rs_full_B should be asserted.
        instA = {76'b0, 2'b10};  // FP instruction
        instB = {76'b0, 2'b10};  // FP instruction
        fp_empty_0 = 1'b0;
        fp_empty_1 = 1'b0;
        
        #10
        // Test Case 3: instA is an FP instruction, while instB is a bubble. 
        // The FP instruction should be dispatched, and no dispatch should happen for instB.
        instA = {76'b0, 2'b10};  // FP instruction
        instB = {76'b0, 2'b00};  // Bubble instruction
        fp_empty_0 = 1'b1;
        fp_empty_1 = 1'b1;
        
        #10
        // Test Case 4: instA is an FP instruction, and instB is a simple instruction. 
        // Both should be dispatched to their respective reservation stations.
        instA = {76'b0, 2'b10};  // FP instruction
        instB = {76'b0, 2'b11};  // Simple instruction
        simple_empty_0 = 1'b1;
        simple_empty_1 = 1'b1;
        fp_empty_0 = 1'b1;
        fp_empty_1 = 1'b1;
        
        #10
        // Test Case 5: Both instA and instB are FP instructions, but only fp_empty_1 is available. 
        // Only one instruction should be dispatched, and rs_full_A or rs_full_B should be asserted.
        instA = {76'b0, 2'b10};  // FP instruction
        instB = {76'b0, 2'b10};  // FP instruction
        fp_empty_0 = 1'b0;
        fp_empty_1 = 1'b1;
        
        // End simulation
        $finish;
    end
      
endmodule
