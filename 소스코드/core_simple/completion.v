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
//Last modified: 2024-08-24 jeyun park
module completion(
    input [64:0] rob_out_inst_0,
    input [64:0] rob_out_inst_1,
    input rob_out_valid_0,
    input rob_out_valid_1,
    
    
    output [63:0] completed_inst_0,
    output [63:0] completed_inst_1,
    output completed_inst_0_valid,
    output completed_inst_1_valid,
    output [4:0] updateAddrA,
    output [4:0] updateAddrB,
    output updateEnA,
    output updateEnB
    );
    
    assign updateAddrA = rob_out_inst_0[6:2];
    assign updateAddrB = rob_out_inst_1[6:2];
    //If not register-write instruction | not illigal instruction(or bubble), then enable
    assign updateEnA = rob_out_inst_0[1] & ~(rob_out_inst_0[0]) & rob_out_valid_0;
    assign updateEnB = rob_out_inst_1[1] & ~(rob_out_inst_1[0]) & rob_out_valid_1;
    
    //You may not understand why post-execution process is divided into complete/retire stage. It is mainly because of store instuction. Store instruction will wait until store is finished
    assign completed_inst_0 = rob_out_inst_0[64:1];
    assign completed_inst_1 = rob_out_inst_1[64:1];
    assign completed_inst_0_valid = rob_out_inst_0[0] & rob_out_valid_0;
    assign completed_inst_1_valid = rob_out_inst_1[0] & rob_out_valid_0;
endmodule
