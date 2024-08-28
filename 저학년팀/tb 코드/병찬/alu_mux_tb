`timescale 1ns/1ps
module alu_mux_tb;

  // Inputs
  reg [1:0] mux1;
  reg [1:0] mux2;
  reg [31:0] rs1;
  reg [31:0] rs2;
  reg [31:0] pc;
  reg [11:0] imm;
  reg [4:0] shamt;
  reg [19:0] imm_20;

  // Outputs
  wire [31:0] aluin1;
  wire [31:0] aluin2;

  // Instantiate the ALU MUX
  alu_mux uut (
    .mux1(mux1), 
    .mux2(mux2), 
    .rs1(rs1), 
    .rs2(rs2), 
    .pc(pc), 
    .imm(imm), 
    .shamt(shamt), 
    .imm_20(imm_20), 
    .aluin1(aluin1), 
    .aluin2(aluin2)
  );

  initial begin

    // Test all combinations of mux1 and mux2 with minimum values
    rs1 = 32'h00000000;
    rs2 = 32'h00000000;
    pc = 32'h00000000;
    imm = 12'h000;
    shamt = 5'h00;
    imm_20 = 20'h00000;
    
    // Test case 1: mux1 = 00, mux2 = 00
    mux1 = 2'b00;
    mux2 = 2'b00;
    #10;

    // Test case 2: mux1 = 00, mux2 = 01
    mux1 = 2'b00;
    mux2 = 2'b01;
    #10;

    // Test case 3: mux1 = 00, mux2 = 10
    mux1 = 2'b00;
    mux2 = 2'b10;
    #10;

    // Test case 4: mux1 = 00, mux2 = 11
    mux1 = 2'b00;
    mux2 = 2'b11;
    #10;

    // Test case 5: mux1 = 01, mux2 = 00
    mux1 = 2'b01;
    mux2 = 2'b00;
    #10;

    // Test case 6: mux1 = 01, mux2 = 01
    mux1 = 2'b01;
    mux2 = 2'b01;
    #10;

    // Test case 7: mux1 = 01, mux2 = 10
    mux1 = 2'b01;
    mux2 = 2'b10;
    #10;

    // Test case 8: mux1 = 01, mux2 = 11
    mux1 = 2'b01;
    mux2 = 2'b11;
    #10;

    // Test case 9: mux1 = 10, mux2 = 00
    mux1 = 2'b10;
    mux2 = 2'b00;
    #10;

    // Test case 10: mux1 = 10, mux2 = 01
    mux1 = 2'b10;
    mux2 = 2'b01;
    #10;

    // Test case 11: mux1 = 10, mux2 = 10
    mux1 = 2'b10;
    mux2 = 2'b10;
    #10;

    // Test case 12: mux1 = 10, mux2 = 11
    mux1 = 2'b10;
    mux2 = 2'b11;
    #10;

    // Repeat all tests with maximum values
    rs1 = 32'hFFFFFFFF;
    rs2 = 32'hFFFFFFFF;
    pc = 32'hFFFFFFFF;
    imm = 12'hFFF;
    shamt = 5'h1F;
    imm_20 = 20'hFFFFF;
    
    // Test case 1: mux1 = 00, mux2 = 00
    mux1 = 2'b00;
    mux2 = 2'b00;
    #10;

    // Test case 2: mux1 = 00, mux2 = 01
    mux1 = 2'b00;
    mux2 = 2'b01;
    #10;

    // Test case 3: mux1 = 00, mux2 = 10
    mux1 = 2'b00;
    mux2 = 2'b10;
    #10;

    // Test case 4: mux1 = 00, mux2 = 11
    mux1 = 2'b00;
    mux2 = 2'b11;
    #10;

    // Test case 5: mux1 = 01, mux2 = 00
    mux1 = 2'b01;
    mux2 = 2'b00;
    #10;

    // Test case 6: mux1 = 01, mux2 = 01
    mux1 = 2'b01;
    mux2 = 2'b01;
    #10;

    // Test case 7: mux1 = 01, mux2 = 10
    mux1 = 2'b01;
    mux2 = 2'b10;
    #10;

    // Test case 8: mux1 = 01, mux2 = 11
    mux1 = 2'b01;
    mux2 = 2'b11;
    #10;

    // Test case 9: mux1 = 10, mux2 = 00
    mux1 = 2'b10;
    mux2 = 2'b00;
    #10;

    // Test case 10: mux1 = 10, mux2 = 01
    mux1 = 2'b10;
    mux2 = 2'b01;
    #10;

    // Test case 11: mux1 = 10, mux2 = 10
    mux1 = 2'b10;
    mux2 = 2'b10;
    #10;

    // Test case 12: mux1 = 10, mux2 = 11
    mux1 = 2'b10;
    mux2 = 2'b11;
    #10;

    // End of simulation
    $finish;
  end

endmodule
