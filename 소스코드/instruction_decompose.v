`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/11 10:53:41
// Design Name: 
// Module Name: instruction_decompose
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

//Need for decoder_RF_conv
module instruction_decompose(
    input [31:0] inst,
    input [31:0] s1,
    input [31:0] s2,
    input rs1_valid,
    input rs2_valid,
    input [31:0] pc,
    input [31:0] rs1_ex_forwarding,
    input [31:0] rs2_ex_forwarding,
    input [31:0] rs1_mem_forwarding,
    input [31:0] rs2_mem_forwarding,
    input [1:0] rs1_forwarding_bit,
    input [1:0] rs2_forwarding_bit,           // for forwarding, 00 -> rs1 , 01 -> ex forwarding, 10 -> mem forwarding
    
    
    output reg map_en,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output reg [82:0] decomposed_inst
    );
    
    //Disassemble instruction
    wire [6:0] opcode;
    wire [11:0] imm_for_i;
    wire [2:0] function3;
    wire [6:0] function7;
    wire [19:0] imm_for_ui;
    
    
    //internally using varibles : make output by concatenate these variables 
    reg [31:0] rs1_vt;                     //vt means value or tag
    reg [31:0] rs2_vt;
    reg s1_valid;                        //If source1 is register, than it will be same as rs1_valid
    reg s2_valid;                        //If source2 is register, than it will be same as rs2_valid
    wire [31:0] rs1_value;
    wire [31:0] rs2_value;
    wire [11:0] ctrl_signal;                   //Caution! It's design is not completed!
    
    assign opcode = inst[6:0];
    assign rd = inst[11:7];
    assign rs1 = inst[19:15];
    assign rs2 = inst[24:20];
    assign imm_for_i = inst[31:20];
    assign imm_for_ui = inst[31:12];            //use for lui and auipc
    assign function3 = inst[14:12];
    assign function7 = inst[31:25];
    
    
    wire [4:0] aluop;
    wire [1:0] alu_mux1;
    wire [1:0] alu_mux2;
    wire [1:0] dispatch_control;
    wire memwrite;
    wire memread;
    wire regwrite;
    wire branch;
    wire memtoreg;
    wire map_enable;
    
    control u_control(
    .opcode_A(opcode),
    .funct3_A(function3),
    .funct7_A(function7),
    
    .aluop_A(aluop),
    .aluin1_mux(alu_mux1),
    .aluin2_mux(alu_mux2),
    .map_en(map_enable),
    .dispatch_control(dispatch_control),
    .memwrite(memwrite), 
    .memread(memread),
    .memtoreg(memtoreg),
    .branch(branch),
    .regwrite(regwrite)
    );
    
    wire [3:0] forwarding_bit;                                         // for forwarding, 00 -> rs1 , 01 -> ex forwarding, 10 -> mem forwarding
    assign forwarding_bit = {rs1_forwarding_bit, rs2_forwarding_bit};
       
       
     alu_mux u_alu_mux(
    .mux1(alu_mux1),
    .mux2(alu_mux2),
    .rs1(s1),
    .rs2(s2),
    .pc(pc),
    .imm(imm_for_i),
    .imm_20(imm_for_ui),
    .shamt(rs2),
    .aluin1(rs1_value),
    .aluin2(rs2_value)
    );
    
    
    assign crtl_signal = {aluop, memwrite, memread, memtoreg, branch, regwrite, dispatch_control}; //5+1+1+1+1+1+2 =12
    
    always@(*) begin   
    map_en = map_enable;                           // 추후 forwarding을 위한 부분 
    rs1_vt = rs1_value;
    rs2_vt = rs2_value;
    if (rs1_forwarding_bit != 2'b00)
    s1_valid = 1;
    else 
    s1_valid = rs1_valid;
    
    if (rs2_forwarding_bit != 2'b00)
    s2_valid = 1;
    else 
    s2_valid = rs2_valid;
    
    case(forwarding_bit)
        4'b0000: decomposed_inst = {rs2_vt, s2_valid, rs1_vt, s1_valid, rd, ctrl_signal};                      //32+1+32+1+5+12 =83
        4'b0001: decomposed_inst = {rs2_ex_forwarding, s2_valid, rs1_vt, s1_valid, rd, crtl_signal};
        4'b0100: decomposed_inst = {rs2_vt, s2_valid, rs1_ex_forwarding, s1_valid, rd, crtl_signal};
        4'b0010: decomposed_inst = {rs2_mem_forwarding, s2_valid, rs1_vt, s1_valid, rd, crtl_signal};
        4'b1000: decomposed_inst = {rs2_vt, s2_valid, rs1_mem_forwarding, s1_valid, rd, crtl_signal};
        4'b0101: decomposed_inst = {rs2_ex_forwarding, s2_valid, rs1_ex_forwarding, s1_valid, rd, crtl_signal};
        4'b0110: decomposed_inst = {rs2_mem_forwarding, s2_valid, rs1_ex_forwarding, s1_valid, rd, crtl_signal};
        4'b1001: decomposed_inst = {rs2_ex_forwarding, s2_valid, rs1_mem_forwarding, s1_valid, rd, crtl_signal};
        4'b1010: decomposed_inst = {rs2_mem_forwarding, s2_valid, rs1_mem_forwarding, s1_valid, rd, crtl_signal};
    endcase
    end
   


    
    
endmodule
