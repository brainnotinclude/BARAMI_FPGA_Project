`timescale 1ns / 1ps

module decoder_tb;

    // Inputs
    reg clk;
    reg rst_n;
    reg [31:0] instA;
    reg [31:0] instB;
    reg [31:32] pcA;
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
    wire map_en_A;
    wire map_en_B;
    wire [4:0] rs1A;
    wire [4:0] rs2A;
    wire [4:0] rs1B;
    wire [4:0] rs2B;
    wire [4:0] rdA;
    wire [4:0] rdB;
    wire error_A;
    wire error_B;

    // Instantiate the Unit Under Test (UUT)
    decoder uut (
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
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns clock period
    end

    // Stimulus process
    initial begin
        // Initialize Inputs
        rst_n = 0;
        instA = 32'h00000000;
        instB = 32'h00000000;
        pcA = 32'h00000000;
        pcB = 32'h00000000;
        forwarding = 32'h00000000;
        forwarding_addr = 5'd0;
        s1A = 32'h00000000;
        s2A = 32'h00000000;
        s1B = 32'h00000000;
        s2B = 32'h00000000;
        rs1A_valid = 0;
        rs2A_valid = 0;
        rs1B_valid = 0;
        rs2B_valid = 0;

        // Apply reset
        #10;
        rst_n = 1;

        // Test Case 1: Simple Instruction Decoding
        instA = 32'h00000013; // NOP-like instruction for A
        instB = 32'h00000013; // NOP-like instruction for B
        pcA = 32'h00000010;   // Program counter for A
        pcB = 32'h00000014;   // Program counter for B
        s1A = 32'h12345678;   // Source 1 data for A
        s2A = 32'h9ABCDEF0;   // Source 2 data for A
        s1B = 32'h11111111;   // Source 1 data for B
        s2B = 32'h22222222;   // Source 2 data for B
        rs1A_valid = 1;
        rs2A_valid = 1;
        rs1B_valid = 1;
        rs2B_valid = 1;
        forwarding = 32'h55555555;
        forwarding_addr = 5'd1;

        #20;

        // Test Case 2: Instruction with Valid Forwarding
        instA = 32'hABCD1234; // Test instruction with valid forwarding for A
        instB = 32'h56789ABC; // Test instruction with valid forwarding for B
        pcA = 32'h00000020;
        pcB = 32'h00000024;
        s1A = 32'h33333333;
        s2A = 32'h44444444;
        s1B = 32'h55555555;
        s2B = 32'h66666666;
        rs1A_valid = 1;
        rs2A_valid = 1;
        rs1B_valid = 1;
        rs2B_valid = 1;
        forwarding = 32'h77777777; // Forwarding data simulates ALU result
        forwarding_addr = 5'd2;

        #20;

        // Test Case 3: Instruction with Invalid Forwarding (Mismatch)
        instA = 32'hDEADBEEF; // Invalid instruction for forwarding for A
        instB = 32'hCAFEBABE; // Invalid instruction for forwarding for B
        pcA = 32'h00000030;
        pcB = 32'h00000034;
        s1A = 32'hAAAAAAAA;
        s2A = 32'hBBBBBBBB;
        s1B = 32'hCCCCCCCC;
        s2B = 32'hDDDDDDDD;
        rs1A_valid = 0;  // Invalid source registers for A
        rs2A_valid = 0;
        rs1B_valid = 0;  // Invalid source registers for B
        rs2B_valid = 0;
        forwarding = 32'hFFFFFFFF; // Forwarding data is not relevant here
        forwarding_addr = 5'd3;

        #20;

        // Test Case 4: Complex Instructions with Different Data
        instA = 32'h13579BDF; // Complex instruction for A
        instB = 32'h2468ACE0; // Complex instruction for B
        pcA = 32'h00000040;
        pcB = 32'h00000044;
        s1A = 32'h12341234;   // New source 1 data for A
        s2A = 32'h56785678;   // New source 2 data for A
        s1B = 32'h9ABC9ABC;   // New source 1 data for B
        s2B = 32'hDEFDEF12;   // New source 2 data for B
        rs1A_valid = 1;
        rs2A_valid = 1;
        rs1B_valid = 1;
        rs2B_valid = 1;
        forwarding = 32'h12345678; // Different forwarding data
        forwarding_addr = 5'd4;

        #20;

        // Test Case 5: Reset During Operation
        rst_n = 0; // Apply reset in the middle of operation
        #10;
        rst_n = 1; // Release reset

        instA = 32'h13579BDF; // Reapply previous complex instruction for A
        instB = 32'h2468ACE0; // Reapply previous complex instruction for B
        pcA = 32'h00000050;
        pcB = 32'h00000054;
        s1A = 32'h1A2B3C4D;   // New source 1 data for A
        s2A = 32'h5E6F7A8B;   // New source 2 data for A
        s1B = 32'h9ABCCDEE;   // New source 1 data for B
        s2B = 32'hFEDCBA98;   // New source 2 data for B
        rs1A_valid = 1;
        rs2A_valid = 1;
        rs1B_valid = 1;
        rs2B_valid = 1;
        forwarding = 32'h87654321; // Different forwarding data
        forwarding_addr = 5'd5;

        #20;

        // Test Case 6: All Zero Instruction and Invalid PC
        instA = 32'h00000000; // No operation or zero instruction for A
        instB = 32'h00000000; // No operation or zero instruction for B
        pcA = 32'hFFFFFFFF;   // Invalid PC value
        pcB = 32'hFFFFFFFF;   // Invalid PC value
        s1A = 32'h00000000;   // Zero source 1 data for A
        s2A = 32'h00000000;   // Zero source 2 data for A
        
        $finish;
    end

endmodule
