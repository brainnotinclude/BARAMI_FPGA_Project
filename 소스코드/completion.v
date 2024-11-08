`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/21 18:28:38
// Design Name: 
// Module Name: completion
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

//Input
//Non-store instruction: updateAddr(5bit) + writeEn(1bit) + store bit(1bit)
//Store instruction: data word(32bit) + store address(32bit) + store bit(1bit)
//Store bit: check if the result is store
//Last modified: 2024-08-24 jeyun park
module completion(
    input [72:0] rob_out_inst_0,
    input [72:0] rob_out_inst_1,
    input rob_out_valid_0,
    input rob_out_valid_1,
    
    
    output [64:0] completed_inst_0,
    output [64:0] completed_inst_1,
    output completed_inst_0_valid,
    output completed_inst_1_valid,
    output [4:0] updateAddrA,
    output [4:0] updateAddrB,
    output updateEnA,
    output updateEnB,
    output [4:0] updateAddrA_fp,
    output [4:0] updateAddrB_fp,
    output updateEnA_fp,
    output updateEnB_fp
    );
    //{memdata, memwrite, memread, fpregwrite, regwrite, aluout, wrAddr};
    wire fp_signal_0;
    assign fp_signal_0 = rob_out_inst_0[38];
    wire fp_signal_1;
    assign fp_signal_1 = rob_out_inst_1[38];
    
    //For non-store
    assign updateAddrA_fp = rob_out_inst_0[4:0];
    assign updateAddrB_fp = rob_out_inst_1[4:0];
    
    //For non-store instructions
    assign updateAddrA = rob_out_inst_0[4:0];
    assign updateAddrB = rob_out_inst_1[4:0];
    
    //If not register-write instruction | not illigal instruction(or bubble), then enable
    assign updateEnA = rob_out_inst_0[37] & ~(rob_out_inst_0[40]) & rob_out_valid_0;
    assign updateEnB = rob_out_inst_1[37] & ~(rob_out_inst_1[40]) & rob_out_valid_1;
    assign updateEnA_fp = rob_out_inst_0[38] & ~(rob_out_inst_0[40]) & rob_out_valid_0;
    assign updateEnB_fp = rob_out_inst_1[38] & ~(rob_out_inst_1[40]) & rob_out_valid_1;
    
    //For store instruction
    assign completed_inst_0 = {rob_out_inst_0[72:41], rob_out_inst_0[36:5],rob_out_inst_0[40]};
    assign completed_inst_1 = {rob_out_inst_1[72:41], rob_out_inst_1[36:5],rob_out_inst_0[40]};
    assign completed_inst_0_valid = rob_out_inst_0[0] & rob_out_valid_0;
    assign completed_inst_1_valid = rob_out_inst_1[0] & rob_out_valid_0;
endmodule
