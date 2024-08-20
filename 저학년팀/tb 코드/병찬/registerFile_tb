`timescale 1ns / 1ps
module tb_registerFile;

    // Inputs
    reg clk;
    reg rst_n;
    reg wr_enable_A;
    reg wr_enable_B;
    reg map_en_A;
    reg map_en_B;
    reg [4:0] addrA_0;
    reg [4:0] addrA_1;
    reg [4:0] addrB_0;
    reg [4:0] addrB_1;
    reg [4:0] wraddrA;
    reg [4:0] wraddrB;
    reg [4:0] wraddrA_map;
    reg [4:0] wraddrB_map;
    reg [31:0] writeDataA;
    reg [31:0] writeDataB;
    reg updateEnA;
    reg updateEnB;
    reg [4:0] updateAddrA;
    reg [4:0] updateAddrB;

    // Outputs
    wire [31:0] dataA_0;
    wire dataA_0_ready;
    wire [31:0] dataA_1;
    wire dataA_1_ready;
    wire [31:0] dataB_0;
    wire dataB_0_ready;
    wire [31:0] dataB_1;
    wire dataB_1_ready;
    wire wrA_rrError;
    wire wrB_rrError;

    // Instantiate the Unit Under Test (UUT)
    registerFile uut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_enable_A(wr_enable_A),
        .wr_enable_B(wr_enable_B),
        .map_en_A(map_en_A),
        .map_en_B(map_en_B),
        .addrA_0(addrA_0),
        .addrA_1(addrA_1),
        .addrB_0(addrB_0),
        .addrB_1(addrB_1),
        .wraddrA(wraddrA),
        .wraddrB(wraddrB),
        .wraddrA_map(wraddrA_map),
        .wraddrB_map(wraddrB_map),
        .writeDataA(writeDataA),
        .writeDataB(writeDataB),
        .updateEnA(updateEnA),
        .updateEnB(updateEnB),
        .updateAddrA(updateAddrA),
        .updateAddrB(updateAddrB),
        .dataA_0(dataA_0),
        .dataA_0_ready(dataA_0_ready),
        .dataA_1(dataA_1),
        .dataA_1_ready(dataA_1_ready),
        .dataB_0(dataB_0),
        .dataB_0_ready(dataB_0_ready),
        .dataB_1(dataB_1),
        .dataB_1_ready(dataB_1_ready),
        .wrA_rrError(wrA_rrError),
        .wrB_rrError(wrB_rrError)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Test procedure
    initial begin
        // Initialize Inputs
        rst_n = 0;
        wr_enable_A = 0;
        wr_enable_B = 0;
        map_en_A = 0;
        map_en_B = 0;
        addrA_0 = 0;
        addrA_1 = 0;
        addrB_0 = 0;
        addrB_1 = 0;
        wraddrA = 0;
        wraddrB = 0;
        wraddrA_map = 0;
        wraddrB_map = 0;
        writeDataA = 0;
        writeDataB = 0;
        updateEnA = 0;
        updateEnB = 0;
        updateAddrA = 0;
        updateAddrB = 0;

        // Apply reset
        #10;
        rst_n = 1;
        #10;

        // Test case 1: Map and write to register A
        map_en_A = 1;
        wraddrA_map = 5'd3;
        #10;
        map_en_A = 0;

        wr_enable_A = 1;
        wraddrA = 5'd3;
        writeDataA = 32'hA5A5A5A5;
        #10;
        wr_enable_A = 0;

        // Test case 2: Read from register A
        addrA_0 = 5'd3;
        #10;

        // Test case 3: Map and write to register B
        map_en_B = 1;
        wraddrB_map = 5'd7;
        #10;
        map_en_B = 0;

        wr_enable_B = 1;
        wraddrB = 5'd7;
        writeDataB = 32'h5A5A5A5A;
        #10;
        wr_enable_B = 0;

        // Test case 4: Read from register B
        addrB_0 = 5'd7;
        #10;

        // Test case 5: Update ARF from RRF for register A
        updateEnA = 1;
        updateAddrA = 5'd3;
        #10;
        updateEnA = 0;

        // Test case 6: Update ARF from RRF for register B
        updateEnB = 1;
        updateAddrB = 5'd7;
        #10;
        updateEnB = 0;

        // Test case 7: Check for register rename errors
        map_en_A = 1;
        map_en_B = 1;
        wraddrA_map = 5'd3; // Trying to map to the same address
        wraddrB_map = 5'd3;
        #10;
        map_en_A = 0;
        map_en_B = 0;

        // Finish simulation
        #20;
        $stop;
    end

endmodule
