`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/15 10:16:47
// Design Name: 
// Module Name: core_simple
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


module core_simple(
        input clk,
        input rst_n,
        input [31:0] instA,
        input [31:0] instB,
        output pcF1,
        output pcF2
    );
    
    localparam decoded_inst_bit = 78;
    localparam dispatched_inst_bit = 76;
    
    wire EN;
    wire [11:0] imm;
    wire [19:0] imm_jal;
    wire [31:0] imm_jalr;   //for jalr 11
    wire [1:0] PCSrc;
    
    
    //Variables for Fetch->Decode
    reg [31:0] instA_decode;        //FF b/w fetch and decode
    reg [31:0] instB_decode;
    
    //Variables for Decode->Dispatch
    //Bit width should be changed according to decoded bit width
    wire [decoded_inst_bit - 1:0] decoded_instA;
    wire [decoded_inst_bit - 1:0] decoded_instB;
    reg [decoded_inst_bit - 1:0] instA_dispatch;        //FF b/w decode and dispatch
    reg [decoded_inst_bit - 1:0] instB_dispatch;
    
    //Variables for Dispatch->Execute
    reg [1:0] complex_empty;
    reg [1:0] simple_empty;
    reg [1:0] fp_empty;
    reg [dispatched_inst_bit-1:0] rs_simple_0;
    reg [dispatched_inst_bit-1:0] rs_simple_1;
    reg [dispatched_inst_bit-1:0] rs_complex_0;
    reg [dispatched_inst_bit-1:0] rs_complex_1;
    reg [dispatched_inst_bit-1:0] rs_fp_0;
    reg [dispatched_inst_bit-1:0] rs_fp_1;
    reg rs_selector_complex;
    reg rs_selector_simple;
    reg rs_selector_fp;

    wire [dispatched_inst_bit-1:0] complex_0_data;          
    wire complex_0_valid;
    wire [dispatched_inst_bit-1:0] complex_1_data;
    wire complex_1_valid;
    wire [dispatched_inst_bit-1:0] simple_0_data;
    wire simple_0_valid;
    wire [dispatched_inst_bit-1:0] simple_1_data;
    wire simple_1_valid;
    wire [dispatched_inst_bit-1:0] fp_0_data;
    wire fp_0_vali;
    wire [dispatched_inst_bit-1:0] fp_1_data;
    wire fp_1_valid;
    wire rs_full_A;              //For stall: It means that RS corresponding to type of instruction A is full. It doesn't mean all RS is full.
    wire rs_full_B;
    
    wire complex_0_issue;
    wire complex_1_issue;
    wire simple_0_issue;
    wire simple_1_issue;
    wire fp_0_issue;
    wire fp_1_issue;
    
    //Variables to distingush control bits and data bits -> complex rs entries c0, c1 / simple rs entries s0, s1 / fp rs entries f0, f1
    wire [31:0] rs_c0_RS1;
    wire [31:0] rs_c0_RS2;
    wire rs_c0_RS1_valid;
    wire rs_c0_RS2_valid;
    wire [31:0] rs_c1_RS1;
    wire [31:0] rs_c1_RS2;
    wire rs_c1_RS1_valid;
    wire rs_c1_RS2_valid;
    wire [31:0] rs_s0_RS1;
    wire [31:0] rs_s0_RS2;
    wire rs_s0_RS1_valid;
    wire rs_s0_RS2_valid;
    wire [31:0] rs_s1_RS1;
    wire [31:0] rs_s1_RS2;
    wire rs_s1_RS1_valid;
    wire rs_s1_RS2_valid;
    wire [31:0] rs_f0_RS1;
    wire [31:0] rs_f0_RS2;
    wire rs_f0_RS1_valid;
    wire rs_f0_RS2_valid;
    wire [31:0] rs_f1_RS1;
    wire [31:0] rs_f1_RS2;
    wire rs_f1_RS1_valid;
    wire rs_f1_RS2_valid;        


    
    
    
    //Bind value to zero: because there is no control instructions in simple pipeline.
    assign EN = 1'b0;   //Next_pc_logic 내의 EN->!EN 수정 아직 안 된 것 같음.
    assign imm = 12'b0;
    assign imm_jal = 20'b0;
    assign imm_jalr = 32'b0;
    assign PCSrc = 2'b00;
    
    next_pc_logic next_pc(
        .clk(clk),
        .rst_n(rst_n),
        .EN(EN),
        .imm(imm),
        .imm_jal(imm_jal),
        .imm_jalr(imm_jalr),   //for jalr 11
        .PCSrc(PCSrc),
    
        .pcF1(pcF1),
        .pcF2(pcF2)
    );
    
    //Update FF between Fetch/Decode 
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            instA_decode <= 32'b0;
            instB_decode <= 32'b0;
        end
        else begin
            instA_decode <= instA;
            instB_decode <= instB;
        end
    end
    
    //We are making decoder module right now, so I/O port list can be changed
    /*decoder decoder(
        .instA(instA_decode),
        .instB(instB_decode),
        
        .imm(imm),
        .imm_jal(imm_jal),
        .imm_jalr(imm_jalr),
        .PCSrc(PCSrc),
        .decoded_instA(decoded_instA),
        .decoded_instB(decoded_instB)
    );*/
    
    //Update FF between Decode/Dispatch
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            instA_dispatch <= 0;
            instB_dispatch <= 0;
        end
        else begin
            instA_dispatch <= decoded_instA;
            instB_dispatch <= decoded_instB;
        end
    end
    
    dispatch dispatch(
        .instA(instA_dispatch),             //Caution!!!: Bit width should be match with decoder output
        .instB(instB_dispatch),
        .complex_empty_0(complex_empty[0]),          //Distributed RS: Empty bit for each RS entry
        .complex_empty_1(complex_empty[1]),
        .simple_empty_0(simple_empty[0]),
        .simple_empty_1(simple_empty[1]),
        .fp_empty_0(fp_empty[0]),
        .fp_empty_1(fp_empty[1]),
        
        //Dispatch module makes an output for an instruction to one of RS entries. We need data port and valid bit(So the entry knows that it should save given data) 
        .complex_0_data(complex_0_data),          
        .complex_0_valid(complex_0_valid),
        .complex_1_data(complex_1_data),
        .complex_1_valid(complex_1_valid),
        .simple_0_data(simple_0_data),
        .simple_0_valid(simple_0_valid),
        .simple_1_data(simple_1_data),
        .simple_1_valid(simple_1_valid),
        .fp_0_data(fp_0_data),
        .fp_0_valid(fp_0_valid),
        .fp_1_data(fp_1_data),
        .fp_1_valid(fp_1_valid),
        .rs_full_A(rs_full_A),               //For stall: It means that RS corresponding to type of instruction A is full. It doesn't mean all RS is full.
        .rs_full_B(rs_full_B)
    );
    
    //Update RS(RS is the FF between Dispatch/Execution)
    //RS structure: 2 entries per FU. 
    //Assume RS entry is compriesed of rs2_vt(32bit) + valid bit(1bit) + rs1_vt(32bit) + valid bit(1bit) + rd(5bit) + ALU_ctrl(5bit) = 76bit
    //Caution: if control signal bit changes, this assignment should also be changed
    //Meaning of variable name: rs_(reservation station type)_(reservation station #)_(source register #)
    assign rs_c0_RS1 = rs_complex_0[42:11];
    assign rs_c0_RS2 = rs_complex_0[75:44];
    assign rs_c0_RS1_valid = rs_complex_0[10];
    assign rs_c0_RS2_valid = rs_complex_0[43];
    assign rs_c1_RS1 = rs_complex_1[42:11];
    assign rs_c1_RS2 = rs_complex_1[75:44];
    assign rs_c1_RS1_valid = rs_complex_1[10];
    assign rs_c1_RS2_valid = rs_complex_1[43];
    assign rs_s0_RS1 = rs_simple_0[42:11];
    assign rs_s0_RS2 = rs_simple_0[75:44];
    assign rs_s0_RS1_valid = rs_simple_0[10];
    assign rs_s0_RS2_valid = rs_simple_0[43];
    assign rs_s1_RS1 = rs_simple_1[42:11];
    assign rs_s1_RS2 = rs_simple_1[75:44];
    assign rs_s1_RS1_valid = rs_simple_1[10];
    assign rs_s1_RS2_valid = rs_simple_1[43];
    assign rs_f0_RS1 = rs_fp_0[42:11];
    assign rs_f0_RS2 = rs_fp_0[75:44];
    assign rs_f0_RS1_valid = rs_fp_0[10];
    assign rs_f0_RS2_valid = rs_fp_0[43];
    assign rs_f1_RS1 = rs_fp_1[42:11];
    assign rs_f1_RS2 = rs_fp_1[75:44];
    assign rs_f1_RS1_valid = rs_fp_1[10];
    assign rs_f1_RS2_valid = rs_fp_1[43];  
    
    always@(posedge clk, negedge rst_n)begin
        if(!rst_n) begin
            rs_simple_0 <= 0;
            rs_simple_1 <= 0;
            rs_complex_0 <= 0;
            rs_complex_1 <= 0;
            rs_fp_0 <= 0;
            rs_fp_1 <= 0;
            simple_empty <= 2'b11;
            complex_empty <= 2'b11;
            fp_empty <= 2'b11;
            
            rs_selector_complex <= 1'b0;
            rs_selector_simple <= 1'b0;
            rs_selector_fp <= 1'b0;
        end
        else begin
            //Needs modification? ->Depends on synthesizer. Maybe we should put assignment to same reg into one if~else if~else
            if(complex_0_valid) begin                   //Note that valid bit and empty bit cannot be both 1
                rs_complex_0 <= complex_0_data;
                complex_empty[0] <= 1'b1;
                rs_selector_complex <= 1'b0;
            end
            if(complex_1_valid) begin                   //Note that valid bit and empty bit cannot be both 1
                rs_complex_1 <= complex_1_data;
                complex_empty[1] <= 1'b1;
                rs_selector_complex <= 1'b1;
            end
            if(simple_0_valid) begin                   //Note that valid bit and empty bit cannot be both 1
                rs_simple_0 <= simple_0_data;
                simple_empty[0] <= 1'b1;
                rs_selector_simple <= 1'b0;
            end
            if(simple_1_valid) begin                   //Note that valid bit and empty bit cannot be both 1
                rs_simple_1 <= simple_1_data;
                simple_empty[1] <= 1'b1;
            end
            if(fp_0_valid) begin                   //Note that valid bit and empty bit cannot be both 1
                rs_fp_0 <= fp_0_data;
                fp_empty[0] <= 1'b1;                
                rs_selector_fp <= 1'b0;
            end
            if(fp_1_valid) begin                   //Note that valid bit and empty bit cannot be both 1
                rs_fp_1 <= fp_1_data;
                fp_empty[1] <= 1'b1;
                rs_selector_fp <= 1'b1;
            end
            
            //Forwarding -> Now editing!!!!!: We will make wrTag and wrdata at later stages 
            //Forwarding for RS1(source 1)
            if((!rs_c0_RS1_valid) && (wrTag == rs_c0_RS1[4:0])) begin
                rs_complex_0[42:11] <= wrdata;
                rs_complex_0[10] <= 1'b1;
            end
            if((!rs_c1_RS1_valid) && (wrTag == rs_c1_RS1[4:0])) begin
                rs_complex_1[42:11] <= wrdata;
                rs_complex_1[10] <= 1'b1;
            end
            if((!rs_s0_RS1_valid) && (wrTag == rs_s0_RS1[4:0])) begin
                rs_simple_0[42:11] <= wrdata;
                rs_simple_0[10] <= 1'b1;
            end
            if((!rs_s1_RS1_valid) && (wrTag == rs_s1_RS1[4:0])) begin
                rs_simple_1[42:11] <= wrdata;
                rs_simple_1[10] <= 1'b1;
            end
            if((!rs_f0_RS1_valid) && (wrTag == rs_f0_RS1[4:0])) begin
                rs_fp_0[42:11] <= wrdata;
                rs_fp_0[10] <= 1'b1;
            end
            if((!rs_f1_RS1_valid) && (wrTag == rs_f1_RS1[4:0])) begin
                rs_fp_1[42:11] <= wrdata;
                rs_fp_1[10] <= 1'b1;
            end
            
            //Forwarding for RS2(source 2)
            if((!rs_c0_RS2_valid) && (wrTag == rs_c0_RS2[4:0])) begin
                rs_complex_0[75:44] <= wrdata;
                rs_complex_0[43] <= 1'b1;
            end
            if((!rs_c1_RS2_valid) && (wrTag == rs_c1_RS2[4:0])) begin
                rs_complex_1[75:44] <= wrdata;
                rs_complex_1[43] <= 1'b1;
            end
            if((!rs_s0_RS2_valid) && (wrTag == rs_s0_RS2[4:0])) begin
                rs_simple_0[75:44] <= wrdata;
                rs_simple_0[43] <= 1'b1;
            end
            if((!rs_s1_RS2_valid) && (wrTag == rs_s1_RS2[4:0])) begin
                rs_simple_1[75:44] <= wrdata;
                rs_simple_1[43] <= 1'b1;
            end
            if((!rs_f0_RS2_valid) && (wrTag == rs_f0_RS2[4:0])) begin
                rs_fp_0[75:44] <= wrdata;
                rs_fp_0[43] <= 1'b1;
            end
            if((!rs_f1_RS2_valid) && (wrTag == rs_f1_RS2[4:0])) begin
                rs_fp_1[75:44] <= wrdata;
                rs_fp_1[43] <= 1'b1;
            end
            
            //Issueing
            if(complex_0_issue) begin
                complex_empty[0] <= 1'b0;
            end
            if(complex_1_issue) begin
                complex_empty[1] <= 1'b0;
            end
            if(simple_0_issue) begin
                simple_empty[0] <= 1'b0;
            end
            if(simple_1_issue) begin
                simple_empty[1] <= 1'b0;
            end
            if(fp_0_issue) begin
                fp_empty[0] <= 1'b0;
            end
            if(fp_1_issue) begin
                fp_empty[1] <= 1'b0;
            end
        end
    end
    
    //Need modification of ALU: Use wrapper?
    ex_simple simple(
        
    );
endmodule
    