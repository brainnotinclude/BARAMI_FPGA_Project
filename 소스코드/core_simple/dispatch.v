`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/15 10:24:35
// Design Name: 
// Module Name: dispatch
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

//Input decoded instrucion assumption: last modified 2024-08-23 jeyun park
//32bit for source1, 32bit for source2, valid bit for source1(1bit), valid bit for source2(1bit), 5 bit for Rd
//Also we need control bits: aluop(5bit), dispatch control(2bit), memread/memwrite/memtoreg(3bit), regWrite(1bit), branch(1bit) => 12bit
//We don't have regWrite signal at present: we need to modify decoder logic)
//Arrange it as {aluop, memwrite, memread, memtoreg, branch, regwrite, dispatch_control, s2, s2_valid, s1, s1_valid, rd} => For the ease of modification: aluop signal will change with the expansion of pipeline(complex signal & fp signal added)
//Last modified:2024-08-26 by jeyun park => Modify according to the assumed arrangement, instB<->instA typo modification, ROB function add
module dispatch(
    input [82:0] instA,             //Caution!!!: Bit width should be match with decoder output
    input [82:0] instB,
    input complex_empty_0,          //Distributed RS: Empty bit for each RS entry
    input complex_empty_1,
    input simple_empty_0,
    input simple_empty_1,
    input fp_empty_0,
    input fp_empty_1,
    input [3:0] rob_tail,
    input [3:0] rob_head,
    
    //Dispatch module makes an output for an instruction to one of RS entries. We need data port and valid bit(So the entry knows that it should save given data) 
    output reg [80:0] complex_0_data,
    output reg [3:0] complex_0_entry_num,          
    output reg complex_0_valid,
    output reg [80:0] complex_1_data,
    output reg [3:0] complex_1_entry_num,
    output reg complex_1_valid,
    output reg [80:0] simple_0_data,
    output reg [3:0] simple_0_entry_num,
    output reg simple_0_valid,
    output reg [80:0] simple_1_data,
    output reg [3:0] simple_1_entry_num,
    output reg simple_1_valid,
    output reg [80:0] fp_0_data,
    output reg [3:0] fp_0_entry_num,
    output reg fp_0_valid,
    output reg [80:0] fp_1_data,
    output reg [3:0] fp_1_entry_num,
    output reg fp_1_valid,
    output reg rs_full_A,               //For stall: It means that RS corresponding to type of instruction A is full. It doesn't mean all RS is full.
    output reg rs_full_B,
    output reg next_rob_tail
    );
    
    wire [5:0] rs_valid;
    reg [5:0] rs_valid_B;
    
    wire [1:0] dispatch_control_A;
    wire [1:0] dispatch_control_B;
    reg [2:0] selected_RS_A;
    reg [2:0] selected_RS_B;
    //instruction signal without dispatch control
    wire [80:0] instA_xdc;
    wire [80:0] instB_xdc;
    
    
    assign rs_valid = {complex_empty_0, complex_empty_1, simple_empty_0, simple_empty_1, fp_empty_0, fp_empty_1};                           //Concat the valid bits for each entries
    //s2, s2_valid, s1, s1_valid, rd =>71bit
    assign dispatch_control_A = instA[72:71];
    assign dispatch_control_B = instB[72:71];
    assign instA_xdc = {instA[82:73], instA[70:0]};
    assign instB_xdc = {instB[82:73], instB[70:0]};
    
    
    //Select RS position
    always@(*) begin
        //Except valid output port, all outputs should be marked as invalid.
    
        complex_0_data = 0;
        complex_0_entry_num = 0;
        complex_0_valid = 0;
        complex_1_data = 0;
        complex_1_entry_num = 0;
        complex_1_valid = 0;
        simple_0_data = 0;
        simple_0_entry_num = 0;
        simple_0_valid = 0;
        simple_1_data = 0;
        simple_1_entry_num = 0;
        simple_1_valid = 0;
        fp_0_data = 0;
        fp_0_entry_num = 0;
        fp_0_valid = 0;
        fp_1_data = 0;
        fp_1_entry_num = 0;
        fp_1_valid = 0;
        rs_valid_B = rs_valid;
        rs_full_A = 0;                          
        rs_full_B = 0;
        next_rob_tail = rob_tail;
        
        if(rob_tail + 4'd1 == rob_head) begin
            rs_full_B = 1'b1;
        end
        else begin 
            if(dispatch_control_A == 2'b11) begin
                casex(rs_valid[5:2])                //"Simple"type can goes into complex0/1, simple0/1
                    4'bxxx1: begin
                        simple_1_data = instA_xdc;
                        simple_1_entry_num = rob_tail;
                        simple_1_valid = 1'b1;
                        rs_valid_B[2] = 1'b0;
                        next_rob_tail = rob_tail+1;
                    end
                    4'bxx10: begin
                        simple_0_data = instA_xdc;
                        simple_0_entry_num = rob_tail;
                        simple_0_valid = 1'b1;
                        rs_valid_B[3] = 1'b0;
                        next_rob_tail = rob_tail+1;
                    end
                    4'bx100: begin
                        complex_1_data = instA_xdc;
                        complex_1_valid = 1'b1;
                        complex_1_entry_num = rob_tail;
                        rs_valid_B[4] = 1'b0;
                        next_rob_tail = rob_tail+1;
                    end
                    4'b1000: begin
                        complex_0_data = instA_xdc;
                        complex_1_entry_num = rob_tail;
                        complex_0_valid = 1'b1;
                        rs_valid_B[5] = 1'b0;
                        next_rob_tail = rob_tail+1;
                    end
                    default:                    //error case: RS full
                        rs_full_A = 1'b1;
                endcase
            end
            else if(dispatch_control_A == 2'b01) begin
                casex(rs_valid[5:4])                //"Complex" type can goes into complex 0/1
                    2'bx1: begin
                        complex_1_data = instA_xdc;
                        complex_1_entry_num = rob_tail;
                        complex_1_valid = 1'b1;
                        rs_valid_B[4] = 1'b0;
                        next_rob_tail = rob_tail+1;
                    end
                    2'b10: begin
                        complex_0_data = instA_xdc;
                        complex_0_entry_num = rob_tail;
                        complex_0_valid = 1'b1;
                        rs_valid_B[5] = 1'b0;
                        next_rob_tail = rob_tail+1;
                    end
                    default:                    //error case: RS full
                        rs_full_A = 1'b1;
                endcase
            end
            else if(dispatch_control_A == 2'b10) begin
                casex(rs_valid[1:0])                //"FP" type can goes into FP 0/1
                    2'bx1: begin
                        fp_1_data = instA_xdc;
                        fp_1_entry_num = rob_tail;
                        fp_1_valid = 1'b1;
                        rs_valid_B[0] = 1'b0;
                        next_rob_tail = rob_tail+1;
                    end
                    2'b10: begin
                        fp_0_data = instA_xdc;
                        fp_0_entry_num = rob_tail;
                        fp_0_valid = 1'b1;
                        rs_valid_B[1] = 1'b0;
                        next_rob_tail = rob_tail+1;
                    end
                    default:                    //error case: RS full
                        rs_full_A = 1'b1;
                endcase
            end
            else if(dispatch_control_A == 2'b00)begin
                //Do nothing;
            end
        end
        
        //Caution: must consider overflow
        if((rob_tail + 4'd1 == rob_head) ||(rob_tail + 4'd2 == rob_head)) begin
            rs_full_B = 1'b1;
        end
        else begin 
            //Handle same as instruction A, but should not select port that is using by A: So use rs_valid_B 
            if(dispatch_control_B == 2'b11) begin
                casex(rs_valid_B[5:2])
                    4'bxxx1: begin
                        simple_1_data = instB_xdc;
                        simple_1_entry_num = next_rob_tail;
                        simple_1_valid = 1'b1;
                        next_rob_tail = next_rob_tail+1;                    
                    end
                    4'bxx10: begin
                        simple_0_data = instB_xdc;
                        simple_0_entry_num = next_rob_tail;
                        simple_0_valid = 1'b1;
                        next_rob_tail = next_rob_tail+1;
    
                    end
                    4'bx100: begin
                        complex_1_data = instB_xdc;
                        complex_1_entry_num = next_rob_tail;
                        complex_1_valid = 1'b1;
                        next_rob_tail = next_rob_tail+1;
                    end
                    4'b1000: begin
                        complex_0_data = instB_xdc;
                        complex_0_entry_num = next_rob_tail;
                        complex_0_valid = 1'b1;
                        next_rob_tail = next_rob_tail+1;
                    end
                    default:                    //error case: RS full
                        rs_full_B = 1'b1;
                endcase
            end
            else if(dispatch_control_B == 2'b01) begin
                casex(rs_valid_B[5:4])
                    2'bx1: begin
                        complex_1_data = instB_xdc;
                        complex_1_entry_num = next_rob_tail;
                        complex_1_valid = 1'b1;
                        next_rob_tail = next_rob_tail+1;
                    end
                    2'b10: begin
                        complex_0_data = instB_xdc;
                        complex_0_entry_num = next_rob_tail;
                        complex_0_valid = 1'b1;
                        next_rob_tail = next_rob_tail+1;
                    end
                    default:                    //error case: RS full
                        rs_full_B = 1'b1;
                endcase
            end
            else if(dispatch_control_B == 2'b10) begin
                casex(rs_valid_B[1:0])
                    2'bx1: begin
                        fp_1_data = instB_xdc;
                        fp_1_entry_num = next_rob_tail;
                        fp_1_valid = 1'b1;
                        next_rob_tail = next_rob_tail+1;
                    end
                    2'b10: begin
                        fp_0_data = instB_xdc;
                        fp_0_entry_num = next_rob_tail;
                        fp_0_valid = 1'b1;
                        next_rob_tail = next_rob_tail+1;
                    end
                    default:                    //error case: RS full
                        rs_full_B = 1'b1;
                endcase
            end
            else if(dispatch_control_B == 2'b00) begin
                //Do nothing
            end
        end
    end
    
endmodule
