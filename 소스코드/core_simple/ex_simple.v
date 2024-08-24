`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/16 00:29:57
// Design Name: 
// Module Name: ex_simple
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

//ALU wrapper for FU "simple"
//Assume RS entry is compriesed of rs2_vt(32bit) + valid bit(1bit) + rs1_vt(32bit) + valid bit(1bit) + rd(5bit) + ALU_ctrl(5bit) = 76bit
//Added: RFwrite bit at rs_simple[76]
//Output: excuted instruction: Rd value(32bit) + Rd addr(5bit) = 37bit
//Not modified from original
module ex_simple(
    //From RS
    input [76:0] rs_simple_0,
    input [76:0] rs_simple_1,
    input selector,
    
    //To RS: I think I shuld remove this
    output simple_0_issue,
    output simple_1_issue,
    //To ROB
    output [36:0] excuted_inst,
    output reg valid,
    //To RF
    output [31:0] writeData,
    output [4:0] writeAddr,
    output writeEn
    );
    wire valid0;
    wire valid1;
    reg RFwrite;
    wire [31:0] aluout;
    reg [31:0] aluin1;
    reg [31:0] aluin2;
    reg [4:0] aluop;
    reg [4:0] wrAddr;
    
    //Check if rs1, rs2 are both ready
    assign valid0 = rs_simple_0[10] & rs_simple_0[43];
    assign valid1 = rs_simple_1[10] & rs_simple_1[43];
    
    always@(*) begin
        if((valid0==1'b1) && (valid1==1'b0)) begin
            aluin1 = rs_simple_0[42:11];
            aluin2 = rs_simple_0[75:44];
            aluop = rs_simple_0[4:0];
            wrAddr = rs_simple_0[9:5];
            valid = 1'b1;
            RFwrite = rs_simple_0[76];
        end
        else if((valid0==1'b0) && (valid1==1'b1)) begin
            aluin1 = rs_simple_1[42:11];
            aluin2 = rs_simple_1[75:44];
            aluop = rs_simple_1[4:0];
            wrAddr = rs_simple_1[9:5];
            valid = 1'b1;
            RFwrite = rs_simple_1[76];
        end
        else if((valid0==1'b0) && (valid1==1'b1)) begin
            if(selector == 1'b0) begin
                aluin1 = rs_simple_1[42:11];
                aluin2 = rs_simple_1[75:44];
                aluop = rs_simple_1[4:0];
                wrAddr = rs_simple_1[9:5];
                RFwrite = rs_simple_1[76];
            end
            else begin
                aluin1 = rs_simple_0[42:11];
                aluin2 = rs_simple_0[75:44];
                aluop = rs_simple_0[4:0];
                wrAddr = rs_simple_0[9:5];
                RFwrite = rs_simple_0[76];
            end
            valid = 1'b1;
        end
        else begin
                aluin1 = 32'b0;
                aluin2 = 32'b0;
                aluop = 5'b0;
                wrAddr = 5'b0;
                valid = 1'b0;
        end
    end
    
    alu alu(
        .aluop(aluop),
        .aluin1(aluin1),     // pc는 aluin1으로 받겠음
        .aluin2(aluin2),     // imm, shamt는 aluin2으로 받겠음
        .aluout(aluout)
    );
    
    assign excuted_output = {aluout, wrAddr};
    assign writeData = aluout;
    assign writeAddr = wrAddr;
    assign writeEn = valid & RFwrite;
    
    
endmodule
