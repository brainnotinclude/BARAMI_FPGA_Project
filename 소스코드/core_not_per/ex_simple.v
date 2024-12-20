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
//Last modified: 2024-08-28 jeyun park

//Input decoded instrucion assumption: last modified 2024-08-23 jeyun park
//32bit for source1, 32bit for source2, 5 bit for Rd
//Also we need control bits: aluop(5bit), memread/memwrite/memtoreg(3bit), regWrite(1bit), branch(1bit) => 10bit
//We don't have regWrite signal at present: we need to modify decoder logic)
//Arrange it as {aluop, memwrite, memread, memtoreg, branch, regwrite, s2, s2_valid, s1, s1_valid, rd} => For the ease of modification: aluop signal will change with the expansion of pipeline(complex signal & fp signal added)
module ex_simple(
    input rst_n,
    //From RS
    input [113:0] rs_simple_0,
    input [113:0] rs_simple_1,
    input [3:0] rs_simple_0_entry_num,
    input [3:0] rs_simple_1_entry_num,
    input selector,

    output reg simple_0_issue,
    output reg simple_1_issue,
    //To ROB
    output [74:0] executed_inst,                     //regWrite+result+writeAddr
    output reg valid,
    //To RF
    output [31:0] writeData,
    output [4:0] writeAddr,
    output writeEn,
    output reg [3:0] simple_rob_num
    );
    wire valid0;            //RS0 ready bit
    wire valid1;            //RS1 ready bit
    reg regWrite;
    wire [31:0] aluout;
    reg [31:0] aluin1;
    reg [31:0] aluin2;
    reg [5:0] aluop;
    reg [4:0] wrAddr;
    
    //Check if rs1, rs2 are both ready
    assign valid0 = rs_simple_0[5] & rs_simple_0[38];
    assign valid1 = rs_simple_1[5] & rs_simple_1[38];
    
    always@(*) begin
        if((valid0==1'b1) && (valid1==1'b0)) begin          //RS0 is ready
            aluin1 = rs_simple_0[37:6];
            aluin2 = rs_simple_0[70:39];
            aluop = rs_simple_0[81:76];
            wrAddr = rs_simple_0[4:0];
            valid = 1'b1;
            regWrite = rs_simple_0[71];
            simple_rob_num = rs_simple_0_entry_num;
            simple_0_issue = 1'b1;
        end
        else if((valid0==1'b0) && (valid1==1'b1)) begin         //RS1 is ready
            aluin1 = rs_simple_1[37:6];
            aluin2 = rs_simple_1[70:39];
            aluop = rs_simple_1[81:76];
            wrAddr = rs_simple_1[4:0];
            valid = 1'b1;
            regWrite = rs_simple_1[71];
            simple_rob_num = rs_simple_1_entry_num;
            simple_1_issue = 1'b1;
        end
        else if((valid0==1'b1) && (valid1==1'b1)) begin         //If both ready, then select one entry using selector
            if(selector == 1'b0) begin                          //Selector points newer one, so we choose non-pointed entry 
                aluin1 = rs_simple_1[37:6];
                aluin2 = rs_simple_1[70:39];
                aluop = rs_simple_1[81:76];
                wrAddr = rs_simple_1[4:0];
                regWrite = rs_simple_1[71];
                simple_rob_num = rs_simple_1_entry_num;
                simple_1_issue = 1'b1;
            end
            else begin
                aluin1 = rs_simple_0[37:6];
                aluin2 = rs_simple_0[70:39];
                aluop = rs_simple_0[81:76];
                wrAddr = rs_simple_0[4:0];
                regWrite = rs_simple_0[71];
                simple_rob_num = rs_simple_0_entry_num;
                simple_0_issue = 1'b1;
                
            end
            valid = 1'b1;
        end
        else begin
                aluin1 = 32'b0;
                aluin2 = 32'b0;
                aluop = 5'b0;
                wrAddr = 5'b0;
                valid = 1'b0;
                regWrite = 1'b0;
                simple_0_issue = 1'b0;
                simple_1_issue = 1'b0;
        end
    end
    
    wire divide_error;
    alu alu(
        .rst_n(rst_n),
        .aluop(aluop),
        .aluin1(aluin1),     // pc는 aluin1으로 받겠음
        .aluin2(aluin2),     // imm, shamt는 aluin2으로 받겠음
        .aluout(aluout),
        .divide_error(divide_error)
    );
    //memdata + memwrite + memread + memtoreg + branch + fpregwrite + regWrite + result + writeAddr
    assign executed_inst = {37'b0,regWrite, aluout, wrAddr};
    assign writeData = aluout;
    assign writeAddr = wrAddr;
    assign writeEn = valid & regWrite;
    
    
endmodule
