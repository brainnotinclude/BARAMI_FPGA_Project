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
    
    output reg map_en,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output [70:0] decomposed_inst
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
    
    wire [4:0] ctrl_signal;                   //Caution! It's design is not completed!
    
    assign opcode = inst[6:0];
    assign rd = inst[11:7];
    assign rs1 = inst[19:15];
    assign rs2 = inst[24:20];
    assign imm_for_i = inst[31:20];
    assign imm_for_ui = inst[31:12];            //use for lui and auipc
    assign function3 = inst[14:12];
    assign function7 = inst[31:25];
    
    assign ctrl_signal = 5'b00000;
    
    assign decomposed_inst = {rs2_vt, s2_valid, rs1_vt, s1_valid, rd, ctrl_signal};
    
    
    //
    always@(*) begin
        if(opcode == 7'b0110011) begin                     //For R-types and M-types
            map_en = 1'b1;                                //because we are handing first instruction, we use map_en_A
            
            if(rs1_valid) begin
                rs1_vt = s1;
            end
            else begin
                rs1_vt = {27'b0, rs1}; 
            end
            
            if(rs2_valid) begin
                rs2_vt = s2;
            end
            else begin
                rs2_vt = {27'b0, rs2};
            end
            
            s1_valid = rs1_valid;
            s2_valid = rs2_valid;
        end
        else if(opcode == 7'b0010011) begin                         //For I-types
            map_en = 1'b1;
            
            if(function3 == 3'b001 || function3 == 3'b101) begin      //For shift
                rs2_vt = rs2;                                      //In this case, it is not rs2A: it is shamt
            end
            else begin
                rs2_vt = imm_for_i;                     //Other I-type instructions have imm field
            end
            
            if(rs1_valid) begin
                rs1_vt = s1;
            end
            else begin
                rs1_vt = {27'b0, rs1}; 
            end
            s1_valid = rs1_valid;
            s2_valid = 1'b1;
        end
        else if(opcode == 7'b0110111) begin                      //lui
            map_en = 1'b1;
            rs1_vt = {12'b0, imm_for_ui};
            s2_valid = 1'b1;                        //In fact, lui doesn't have any source reg: so it is always valid
            s1_valid = 1'b1;
        end
        else if(opcode == 7'b0010111) begin                     //auipc: it is similar to lui
            map_en = 1'b1;
            rs1_vt = {12'b0, imm_for_ui};
            s2_valid = 1'b1;                        
            s1_valid = 1'b1;
        end
        else begin                                  //illegal instruction: Mainly, control siganl logic will handle this, but we need instruction decomposing because abort is performed in ROB. Note that there can be illegal instructions even if opcode is legal(==illegal funct field), but even in that case, instruction is decomposed, so it is OK.
            map_en = 1'b0;
            s2_valid = 1'b1;
            s1_valid = 1'b1;
            rs1_vt = 32'b0;
            rs2_vt = 32'b0;
        end
             
    end
endmodule
