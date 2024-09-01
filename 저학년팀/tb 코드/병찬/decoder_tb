`timescale 1ns / 1ps

module decoder_tb;

    // Inputs
    reg clk;
    reg rst_n;
    reg [31:0] instA;
    reg [31:0] instB;
    reg [31:0] pcA;
    reg [31:0] pcB;
    
    reg [31:0] forwarding;
    reg [4:0] forwarding_addr;
    
    reg [31:0] s1A;
    reg [31:0] s2A;
    reg [31:0] s1B;
    reg [31:0] s2B;
    reg rs1A_valid;
    reg rs2A_valid;
    reg rs1B_valid;
    reg rs2B_valid;
    
    // Outputs
    wire [82:0] decoded_instA;
    wire [82:0] decoded_instB;
    wire error_A;
    wire error_B;
    
    // Instantiate the Unit Under Test (UUT)
    decoder u_decoder (
        .clk(clk),
        .rst_n(rst_n),
        .instA(instA),
        .instB(instB),
        .pcA(pcA),
        .pcB(pcB),
        .forwarding(forwarding),
        .forwarding_addr(forwarding_addr),
        .s1A(s1A),
        .s2A(s2A),
        .s1B(s1B),
        .s2B(s2B),
        .rs1A_valid(rs1A_valid),
        .rs2A_valid(rs2A_valid),
        .rs1B_valid(rs1B_valid),
        .rs2B_valid(rs2B_valid),
        .decoded_instA(decoded_instA),
        .decoded_instB(decoded_instB),
        .map_en_A(map_en_A),
        .map_en_B(map_en_B),
        .rs1A(rs1A),
        .rs2A(rs2A),
        .rs1B(rs1B),
        .rs2B(rs2B),
        .rdA(rdA),
        .rdB(rdB),
        .error_A(error_A),
        .error_B(error_B)
    );

    // Clock generation
    always begin
        #5 clk = ~clk; // 10ns clock period
    end

    // Initial block for stimulus
    initial begin
        // Initialize Inputs
        clk = 0;
        rst_n = 0;
        instA = 32'b0;
        instB = 32'b0;
        pcA = 32'b0;
        pcB = 32'b0;
        forwarding = 32'b0;
        forwarding_addr = 5'b0;

        s1A = 32'b0;
        s2A = 32'b0;
        s1B = 32'b0;
        s2B = 32'b0;
        rs1A_valid = 0;
        rs2A_valid = 0;
        rs1B_valid = 0;
        rs2B_valid = 0;
        
        // Apply reset
        #10 rst_n = 1;
        #5 rst_n = 0;
        #5 rst_n = 1;

        // Test Case 1: Basic Instruction Test
        #10
        instA = 32'b00010010001100000000000010010011; // Example instruction A
        instB = 32'b00000000001100000011000010010011; // Example instruction B
        pcA = 32'h0001_0000;
        pcB = 32'h0001_0004;
        forwarding = 32'h12345678;
        forwarding_addr = 5'b00001;
        s1A = 32'h00000001;
        s2A = 32'h00000002;
        s1B = 32'h00000003;
        s2B = 32'h00000004;
        rs1A_valid = 1;
        rs2A_valid = 1;
        rs1B_valid = 1;
        rs2B_valid = 1;

        #10
        // Check if decoded instructions match expected results

        // Test Case 2: Forwarding Values
        #10
        instA = 32'b00000000011000000000000010010011; // Example instruction A with forwarding
        instB = 32'b00000000001000001000000110110011; // Example instruction B with forwarding
        pcA = 32'h0001_0008;
        pcB = 32'h0001_000C;
        forwarding = 32'h9ABCDEF0;
        forwarding_addr = 5'b00010;
        s1A = 32'h00000005;
        s2A = 32'h00000006;
        s1B = 32'h00000007;
        s2B = 32'h00000008;
        rs1A_valid = 1;
        rs2A_valid = 1;
        rs1B_valid = 1;
        rs2B_valid = 1;

        #10
        // Check if decoded instructions and forwarding are processed correctly

        // Test Case 3: Error Conditions
        #10
        instA = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; // Invalid instruction A
        instB = 32'b00000000001000001000000110110011; // Valid instruction B
        pcA = 32'h0001_0010;
        pcB = 32'h0001_0014;
        forwarding = 32'h00000000;
        forwarding_addr = 5'b00000;
        s1A = 32'h00000000;
        s2A = 32'h00000000;
        s1B = 32'h00000000;
        s2B = 32'h00000000;
        rs1A_valid = 0;
        rs2A_valid = 0;
        rs1B_valid = 0;
        rs2B_valid = 0;

        #10
        // Check if error signals are asserted correctly

        // Test Case 4: Multiple Instructions and Register Writes
        #10
        instA = 32'b01000000001000011010001010110011; // Example instruction A
        instB = 32'b00000000001000001001000010110011; // Example instruction B
        pcA = 32'h0001_0018;
        pcB = 32'h0001_001C;
        forwarding = 32'hFFFFFFFF;
        forwarding_addr = 5'b00101;
        s1A = 32'h0000000A;
        s2A = 32'h0000000B;
        s1B = 32'h0000000C;
        s2B = 32'h0000000D;
        rs1A_valid = 1;
        rs2A_valid = 1;
        rs1B_valid = 1;
        rs2B_valid = 1;

        #10
        // Check if multiple instructions are decoded correctly and register writes are handled

        // End of simulation
        #20
        $finish;
    end

endmodule
