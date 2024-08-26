`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/26 21:06:36
// Design Name: 
// Module Name: tb_control
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


module tb_control(

    );
    //reg clk,
    reg rst_n;
    reg [6:0]opcode_A;
    reg [2:0]funct3_A;
    reg [6:0]funct7_A;
    /*reg [6:0]opcode_B,
    reg [2:0]funct3_B,
    reg [6:0]funct7_B,
    */
    wire [4:0]aluop_A;
    wire [1:0]aluin1_mux;          //mux 00 -> rs1, 01 -> pc, 10 -> 0 for lui
    //wire [4:0]aluop_B,
    wire [1:0]aluin2_mux;           //mux 00 -> rs2, 01 -> shamt 10-> imm_12 11->imm_20
    wire map_en;
    wire [1:0] dispatch_control;     //11: Both simple/complex, 01: Complex only, 10:FP only
    wire memwrite;
    wire memread;
    wire memtoreg;
    wire branch;
    wire regwrite;
    
    always@(*)
    begin
    if(!rst_n) begin
    opcode_A = 7'd0;
    funct3_A = 3'd0;
    funct7_A = 7'd0;
        end
    end
    control uut(
    .opcode_A(opcode_A),
    .funct3_A(funct3_A),
    .funct7_A(funct7_A),
    /*input [6:0]opcode_B,
    input [2:0]funct3_B,
    input [6:0]funct7_B,
    //input clk,
    //input rst_n,
    */
    .aluop_A(aluop_A),
    .aluin1_mux(aluin1_mux),          //mux 00 -> rs1, 01 -> pc, 10 -> 0 for lui
    //output reg [4:0]aluop_B,
    .aluin2_mux(aluin2_mux),           //mux 00 -> rs2, 01 -> shamt 10-> imm_12 11->imm_20
    .map_en(map_en),
    .dispatch_control(dispatch_control),     //11: Both simple/complex, 01: Complex only, 10:FP only
    .memwrite(memwrite),
    .memread(memread),
    .memtoreg(memtoreg),
    .branch(branch),
    .regwrite(regwrite)
    );
    initial
    begin
    rst_n = 0; //basic reset
    #2 //decode signal initial reset testing
    rst_n = 1;
    opcode_A = 7'b0000001;
    #2// basic function test - add
    opcode_A = 7'b0110011;
    funct3_A = 3'b000;
    funct7_A = 7'b0000000;
        #2 //addi
    opcode_A = 7'b0010011;
    funct3_A = 3'b000;
    funct7_A = 7'b0000000;
        #2 //remu
    opcode_A = 7'b0110011;
    funct3_A = 3'b111;
    funct7_A = 7'b0000001;
    #2 //slli with wrong funct7
    opcode_A = 7'b0010011;
    funct3_A = 3'b001;
    funct7_A = 7'b0000001;
    #2
    $finish;
    end
    
    
    
endmodule
