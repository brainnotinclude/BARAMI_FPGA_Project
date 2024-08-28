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

//Last modified: 224-08-28 by jeyun park
module core_simple(
        input clk,
        input rst_n,
        input [31:0] instA,
        input [31:0] instB,
        input store_finish,
        input [31:0] store_fin_addr,
        
        output pcF1,
        output pcF2
    );
    
    //Parameters for signals
    localparam decoded_inst_bit = 83;
    localparam dispatched_inst_bit = 76;
    
    //For fetch stage
    wire EN;
    wire [11:0] imm;
    wire [19:0] imm_jal;
    wire [31:0] imm_jalr;   //for jalr 11
    wire [1:0] PCSrc;
    
    
    //Variables for Fetch->Decode
    reg [31:0] instA_decode;        //FF b/w fetch and decode
    reg [31:0] instB_decode;
    
    reg pcF1_decoder;            // decoder 단계에서 사용하는 pc는 현재 clock가 아닌 이전 clock pc 값임
    reg pcF2_decoder;    
    
    //Variables for Decode->Dispatch
    //Bit width should be changed according to decoded bit width
    wire [decoded_inst_bit - 1:0] decoded_instA;
    wire [decoded_inst_bit - 1:0] decoded_instB;
    reg [decoded_inst_bit - 1:0] instA_dispatch;        //FF b/w decode and dispatch
    reg [decoded_inst_bit - 1:0] instB_dispatch;
    wire errorA;
    wire errorB;
    
    //Variables for decoder<->RF connection
    wire [31:0] s1A;
    wire [31:0] s2A;
    wire [31:0] s1B;
    wire [31:0] s2B;
    wire rs1A_valid;
    wire rs2A_valid;
    wire rs1B_valid;
    wire rs2B_valid;
    wire map_en_A;
    wire map_en_B;
    wire [4:0] rs1A;
    wire [4:0] rs2A;
    wire [4:0] rs1B;
    wire [4:0] rs2B;
    wire [4:0] rdA;
    wire [4:0] rdB;
    
    //Variables for forwarding -> I will cover it later
    
    
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
    
    wire [3:0] comp_0_entry_num;
    wire [3:0] comp_1_entry_num;
    wire [3:0] simple_0_entry_num;
    wire [3:0] simple_1_entry_num;
    wire [3:0] fp_0_entry_num;
    wire [3:0] fp_1_entry_num;
    
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


    //Variables for ROB: Execute -> complete
    wire [36:0] executed_inst_simple;
    
    //Old ROB variables: now modifying 
    /*reg [36:0] rob [7:0];
    reg [3:0] rob_tag [7:0];
    reg [7:0] rob_valid;
    reg [3:0] rob_number;

    reg [2:0] rob_empty_slot_simple;
    reg [2:0] rob_empty_slot_complex;
    reg [2:0] rob_empty_slot_fp;
    
    integer i;
    
    wire simple_valid;
    wire complex_valid;
    wire fp_valid;*/


    //For registerFile: finish(execution) & complete step
    wire [4:0] wraddrA;
    wire [4:0] wraddrB;
    wire [31:0] writeDataA;
    wire [31:0] writeDataB;
    wire wr_enable_A;
    wire wr_enable_B;
    wire [4:0] updateAddrA;
    wire [4:0] updateAddrB;
    wire updateEnA;
    wire updateEnB;
    
    
    
    //Bind value to zero: because there is no control instructions in simple pipeline.
    assign EN = 1'b0;   //If code of next_pc_logic changes, this also should be change
    assign imm = 12'b0;
    assign imm_jal = 20'b0;
    assign imm_jalr = 32'b0;
    assign PCSrc = 2'b00;
    
    //Next_pc_logic should be modified: So it can handle stall
    next_pc_logic next_pc(
        .clk(clk),
        .rst_n(rst_n),
        // .EN(EN),
        .imm(imm),
        .imm_jal(imm_jal),
        .imm_jalr(imm_jalr),   //for jalr 11
        .PCSrc(PCSrc),
        
        .errorA(errorA),
        .errorB(errorB),
        .rs_full_A(rs_full_A),
        .rs_full_B(rs_full_B),
    
        .pcF1(pcF1),
        .pcF2(pcF2)
    );
    
    //Update FF between Fetch/Decode 
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            instA_decode <= 32'b0;
            instB_decode <= 32'b0;
            pcF1_decoder <= 32'b0;
            pcF2_decoder <= 32'b0;
        end
        else begin
            //"error" is the only case that stalls on decode stage
            //next_pc_logic should be modified: to fix the pc when stall!!!
            //What happens if stall at dispatch? -> decode does not change anything, so we only need to fix the FF value
            //There are two cases: error at instA, error at instB
            //Error at instA: we should process insruction in-order at dispatch stage, so we stall both instruction.
            //Error at instB: error instruction does not pass to dispatch stage(bubble occurs). instB moves to instA position, and fetched new instruction goes to position of instB.
            //Both need to handle PC properly.
            if(!errorA & !rs_full_A) begin                      //If "register configuration error on instruction A at decode stage" or "rs full error on instruction A at dispatch stage)" then value of fetch/decode FF should be preserved 
                if(!errorB & !rs_full_B) begin                  //If there is no error: Normal update
                    instA_decode <= instA;
                    instB_decode <= instB;
                    pcF1_decoder <= pcF1;                       // 명령어에 맞춰 pc도 따라가는
                    pcF2_decoder <= pcF2;
                end
                else begin                                     //In this case, only one instruction should go to next stage
                    instA_decode <= instB_decode;
                    instB_decode <= instA;
                    pcF1_decoder <= pcF2_decoder;
                    pcF2_decoder <= pcF1;
                end    
            end
            else begin
                //Do nothing
            end
        end
    end
    
    //We are making decoder module right now, so I/O port list can be changed
    //I personally changed decoder_RF_conv.v: seperate the RF files
    
    decoder decoder(
        .clk(clk),
        .rst_n(rst_n),
        .instA(instA_decode),                 //1st instruction
        .instB(instB_decode),                 //2nd instruction
        //Caution!!: what is the PC value using for the instruction? We need to talk about it and modify the logic for it
        .pcA(pcF1_decoder),            // pc value는 각 명령어에 대한 본인 pc 값 
        .pcB(pcF2_decoder),
    
        //From forwarding path -> Need modification?: tag match in or out decoder
        //wires for forwarding not yet declared
        .forwarding_A(forwarding_A),
        .forwarding_B(forwarding_B),
        .forwarding_addr_A(forwarding_addr_A),
        .forwarding_addr_B(forwarding_addr_B),
        
        //From RF
        .s1A(s1A),
        .s2A(s2A),
        .s1B(s1B),
        .s2B(s2B),
        .rs1A_valid(rs1A_valid),
        .rs2A_valid(rs2A_valid),
        .rs1B_valid(rs1B_valid),
        .rs2B_valid(rs2B_valid),
    
        //To other stages
        .decoded_instA(decoded_instA),               //Decoded instructions: need to be vectorized!!
        .decoded_instB(decoded_instB),
    
    //To RF
        .map_en_A(map_en_A),
        .map_en_B(map_en_B),
        .rs1A(rs1A),
        .rs2A(rs2A),
        .rs1B(rs1B),
        .rs2B(rs2B),
        .rdA(rdA),
        .rdB(rdA)
    );
    
    registerFile RF_integer(
        .clk(clk),
        .rst_n(rst_n),
        .wr_enable_A(wr_enable_A),              //write enable
        .wr_enable_B(wr_enable_B),
        .map_en_A(map_en_A),                 //RRF mapping enable: this means that there is a GPR write instruction in decode stage, so we need destination allocation in this cycle
        .map_en_B(map_en_B),
        .addrA_0(rs1A),            //read addresses
        .addrA_1(rs2A),
        .addrB_0(rs1B),
        .addrB_1(rs2B),
        .wraddrA(wraddrA),            //write addresses for real write -> happens when finishes execution  //
        .wraddrB(wraddrB),
        .wraddrA_map(rdA),        //write addresses for destination allocation
        .wraddrB_map(rdB),
        .writeDataA(writeDataA),        //write data        ->happens when finishes execution
        .writeDataB(writeDataB),
        .updateEnA(updateEnA),          //happens when instruction retired
        .updateEnB(updateEnB),          
        .updateAddrA(updateAddrA),
        .updateAddrB(updateAddrB),
        .dataA_0(s1A),         //read data for A
        .dataA_0_ready(rs1A_valid),          //check if data is valid. If not, decoder should not use the data and pass register tag to next stage
        .dataA_1(s2A),
        .dataA_1_ready(rs2A_valid),
        .dataB_0(s1B),
        .dataB_0_ready(rs1B_valid),
        .dataB_1(s2B),
        .dataB_1_ready(rs2B_valid),
        .wrA_rrError(errorA),             //If RRF is full then we can't use register renaming
        .wrB_rrError(errorB)
    );
    
    //Update FF between Decode/Dispatch
    //Instruction handling occurs sequencially until dispatch
    //So, if RS entry of instA is unusable, than both instA and B should be stalled.
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            instA_dispatch <= 0;
            instB_dispatch <= 0;
        end
        else begin
            if(!rs_full_A & !rs_full_B) begin
                //Note that on errorA & !errorB situation, decode/dispatch FF should not be updated b/c it is in-order.
                if(!errorA) begin
                    instA_dispatch <= decoded_instA;
                    if(!errorB) begin
                        instB_dispatch <= decoded_instB;
                    end
                    else begin
                        instB_dispatch <= 0;
                    end
                end
                else begin
                    instA_dispatch <= 0;
                    instB_dispatch <= 0;
                end
            end
            else if(!rs_full_A & rs_full_B) begin
                instA_dispatch <= instB_dispatch;
                //Note that on errorA & !errorB situation, decode/dispatch FF should not be updated b/c it is in-order.
                if(!errorA) begin
                    instB_dispatch <= decoded_instA;
                end
                else begin
                    instB_dispatch <= 0;
                end
            end
            else begin
                //Do nothing: preserve the value
            end
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
        .rob_tail(tail),
        .rob_head(head),
        
        //Dispatch module makes an output for an instruction to one of RS entries. We need data port and valid bit(So the entry knows that it should save given data) 
        .complex_0_data(complex_0_data),
        .comp_0_entry_num(comp_0_entry_num),          
        .complex_0_valid(complex_0_valid),
        .complex_1_data(complex_1_data),
        .comp_1_entry_num(comp_1_entry_num),
        .complex_1_valid(complex_1_valid),
        .simple_0_data(simple_0_data),
        .simple_0_entry_num(simple_0_entry_num),
        .simple_0_valid(simple_0_valid),
        .simple_1_data(simple_1_data),
        .simple_1_entry_num(simple_1_entry_num),
        .simple_1_valid(simple_1_valid),
        .fp_0_data(fp_0_data),
        .fp_0_entry_num(fp_0_entry_num),
        .fp_0_valid(fp_0_valid),
        .fp_1_data(fp_1_data),
        .fp_1_entry_num(fp_1_entry_num),
        .fp_1_valid(fp_1_valid),
        .rs_full_A(rs_full_A),               //For stall: It means that RS corresponding to type of instruction A is full. It doesn't mean all RS is full.
        .rs_full_B(rs_full_B),
        .next_rob_tail(next_rob_tail)
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
    
    reg [3:0] rs_comp_0_entry_num;
    reg [3:0] rs_comp_1_entry_num;
    reg [3:0] rs_simple_0_entry_num;
    reg [3:0] rs_simple_1_entry_num;
    reg [3:0] rs_fp_0_entry_num;
    reg [3:0] rs_fp_1_entry_num;
    
    always@(posedge clk, negedge rst_n)begin
        if(!rst_n) begin
            rs_simple_0 <= 0;
            rs_simple_1 <= 0;
            rs_complex_0 <= 0;
            rs_complex_1 <= 0;
            rs_fp_0 <= 0;
            rs_fp_1 <= 0;
            rs_comp_0_entry_num <= 0;
            rs_comp_1_entry_num <= 0;
            rs_simple_0_entry_num <= 0;
            rs_simple_1_entry_num <= 0;
            rs_fp_0_entry_num <= 0;
            rs_fp_1_entry_num <= 0;
            
            simple_empty <= 2'b11;
            complex_empty <= 2'b11;
            fp_empty <= 2'b11;
            
            rs_selector_complex <= 1'b0;
            rs_selector_simple <= 1'b0;
            rs_selector_fp <= 1'b0;
        end
        else begin
            //Needs modification? ->Depends on synthesizer. Maybe we should put assignment to same reg into one if~else if~else
            //Dispatch module -> RS : If proper entry is full, then that instruction doesn't make any dispatch. However, if rs_full_A, next instruction(B) should also stop because it is in-order
            //Also, dispatch module should update ROB entry
            if(!rs_full_A) begin
                if(complex_0_valid) begin                   //Note that valid bit and empty bit cannot be both 1
                    rs_complex_0 <= complex_0_data;
                    complex_empty[0] <= 1'b0;
                    rs_selector_complex <= 1'b0;
                    rs_comp_0_entry_num <= comp_0_entry_num;
                    rob_busy[comp_0_entry_num] <= 1'b1;
                end
                if(complex_1_valid) begin                   //Note that valid bit and empty bit cannot be both 1
                    rs_complex_1 <= complex_1_data;
                    complex_empty[1] <= 1'b1;
                    rs_selector_complex <= 1'b1;
                    rs_comp_1_entry_num <= comp_1_entry_num;
                    rob_busy[comp_1_entry_num] <= 1'b1;
                end
                if(simple_0_valid) begin                   //Note that valid bit and empty bit cannot be both 1
                    rs_simple_0 <= simple_0_data;
                    simple_empty[0] <= 1'b0;
                    rs_selector_simple <= 1'b0;
                    rs_simple_0_entry_num <= simple_0_entry_num;
                    rob_busy[simple_0_entry_num] <= 1'b1;
                end
                if(simple_1_valid) begin                   //Note that valid bit and empty bit cannot be both 1
                    rs_simple_1 <= simple_1_data;
                    simple_empty[1] <= 1'b1;
                    rs_simple_1_entry_num <= simple_1_entry_num;
                    rob_busy[simple_1_entry_num] <= 1'b1;
                end
                if(fp_0_valid) begin                   //Note that valid bit and empty bit cannot be both 1
                    rs_fp_0 <= fp_0_data;
                    fp_empty[0] <= 1'b0;                
                    rs_selector_fp <= 1'b0;
                    rs_fp_0_entry_num <= fp_0_entry_num;
                    rob_busy[fp_0_entry_num] <= 1'b1;
                end
                if(fp_1_valid) begin                   //Note that valid bit and empty bit cannot be both 1
                    rs_fp_1 <= fp_1_data;
                    fp_empty[1] <= 1'b0;
                    rs_selector_fp <= 1'b1;
                    rs_fp_1_entry_num <= fp_1_entry_num;
                    rob_busy[fp_1_entry_num] <= 1'b1;
                end
            end
            
            //Forwarding -> Now editing!!!!!: We will make wrTag and wrdata at later stages 
            //Forwarding for RS1(source 1)
            if((!rs_c0_RS1_valid) && (wrAddrA == rs_c0_RS1[4:0]) && wr_enable_A) begin
                rs_complex_0[42:11] <= writeDataA;
                rs_complex_0[10] <= 1'b1;
            end
            if((!rs_c1_RS1_valid) && (wrAddrA == rs_c1_RS1[4:0]) && wr_enable_A) begin
                rs_complex_1[42:11] <= writeDataA;
                rs_complex_1[10] <= 1'b1;
            end
            if((!rs_s0_RS1_valid) && (wrAddrA == rs_s0_RS1[4:0]) && wr_enable_A) begin
                rs_simple_0[42:11] <= writeDataA;
                rs_simple_0[10] <= 1'b1;
            end
            if((!rs_s1_RS1_valid) && (wrAddrA == rs_s1_RS1[4:0]) && wr_enable_A) begin
                rs_simple_1[42:11] <= writeDataA;
                rs_simple_1[10] <= 1'b1;
            end
            //Caution: FP should connected to the fp register
            if((!rs_f0_RS1_valid) && (wrAddrFP == rs_f0_RS1[4:0]) && wr_enable_FP) begin
                rs_fp_0[42:11] <= writeDataFP;
                rs_fp_0[10] <= 1'b1;
            end
            if((!rs_f1_RS1_valid) && (wrAddrFP == rs_f1_RS1[4:0]) && wr_enable_FP) begin
                rs_fp_1[42:11] <= writeDataFP;
                rs_fp_1[10] <= 1'b1;
            end
            
            //Forwarding for RS2(source 2)
            if((!rs_c0_RS2_valid) && (wrAddrA == rs_c0_RS2[4:0]) && wr_enable_A) begin
                rs_complex_0[75:44] <= writeDataA;
                rs_complex_0[43] <= 1'b1;
                
            end
            if((!rs_c1_RS2_valid) && (wrAddrA == rs_c1_RS2[4:0]) && wr_enable_A) begin
                rs_complex_1[75:44] <= writeDataA;
                rs_complex_1[43] <= 1'b1;
                
            end
            if((!rs_s0_RS2_valid) && (wrAddrA == rs_s0_RS2[4:0]) && wr_enable_A) begin
                rs_simple_0[75:44] <= writeDataA;
                rs_simple_0[43] <= 1'b1;
                
            end
            if((!rs_s1_RS2_valid) && (wrAddrA == rs_s1_RS2[4:0]) && wr_enable_A) begin
                rs_simple_1[75:44] <= writeDataA;
                rs_simple_1[43] <= 1'b1;
                
            end
            //Caution: FP should connected to the fp register
            if((!rs_f0_RS2_valid) && (wrAddrFP == rs_f0_RS2[4:0]) && wr_enable_FP) begin
                rs_fp_0[75:44] <= writeDataFP;
                rs_fp_0[43] <= 1'b1;
                
            end
            if((!rs_f1_RS2_valid) && (wrAddrFP == rs_f1_RS2[4:0]) && wr_enable_FP) begin
                rs_fp_1[75:44] <= writeDataFP;
                rs_fp_1[43] <= 1'b1;
                
            end
            
            //Issueing
            if(complex_0_issue) begin
                complex_empty[0] <= 1'b1;
                rob_issued[rs_comp_0_entry_num] <= 1'b1;
            end
            if(complex_1_issue) begin
                complex_empty[1] <= 1'b1;
                rob_issued[rs_comp_1_entry_num] <= 1'b1;
            end
            if(simple_0_issue) begin
                simple_empty[0] <= 1'b1;
                rob_issued[rs_simple_0_entry_num] <= 1'b1;
            end
            if(simple_1_issue) begin
                simple_empty[1] <= 1'b1;
                rob_issued[rs_simple_1_entry_num] <= 1'b1;
            end
            if(fp_0_issue) begin
                fp_empty[0] <= 1'b1;
                rob_issued[rs_fp_0_entry_num] <= 1'b1;
            end
            if(fp_1_issue) begin
                fp_empty[1] <= 1'b1;
                rob_issued[rs_fp_1_entry_num] <= 1'b1;
            end
        end
    end
    
    //simple FU
    //We connect simple output to port A. Because FP output is connected to different RF, it is resonable that each simple/complex output is hard-wired to one RF port
    wire [3:0] simple_rob_num;
    
    //On speculative instructions: We need mechanism to not to architecurally finsh(write to ARF) the speculative instruction.s 
    ex_simple simple(
        .rs_simple_0(rs_simple_0),
        .rs_simple_1(rs_simple_1),
        .rs_simple_0_entry_num(rs_simple_0_entry_num),
        .rs_simple_1_entry_num(rs_simple_1_entry_num),
        .selector(simple_selector),
    
        .simple_0_issue(simple_0_issue),
        .simple_1_issue(simple_1_issue),
    
        .excuted_inst(executed_inst_simple),
        .valid(simple_valid),
        
        .writeData(writeDataA),
        .writeAddr(wrAddrA),
        .writeEn(wr_enable_A),
        .simple_rob_num(simple_rob_num)
    );
    
    
    
    //Complex FU and FP FU: is on progress

    //ROB logic: find empty entry and pass instruction to next stage according to the order.
    //ROB: Execute <-> complete
    //Maybe we need modification: If store needs extra bit
    
    Caution: We are now modifying the ROB code : 2024-08-23 jeyun park;
    
    reg [15:0] rob_busy;                    //If ROB entry allocate, then 1
    reg [15:0] rob_issued;                  //If issued to execution, then 1
    reg [15:0] rob_finished;                //If finished execution
    reg [15:0] rob_speculative;         //For later use(branch)
    wire [15:0] rob_valid;                //Check if instruction is architecturally finished: case of invalid speculation
    reg [3:0] head;
    reg [3:0] tail;
    
    wire next_rob_tail;
    
    reg [37:0] rob[15:0];                  //Entry of ROB <= Entry of ROB ctrl bits : Can be optimized.
    
    reg [37:0] rob_out_inst_0;
    reg [37:0] rob_out_inst_1;
    reg rob_out_valid_0;
    reg rob_out_valid_1;
    
    //update logic for ROB
    always@(posedge clk, negedge rst_n) begin
        if(rst_n) begin
            head <= 4'b0;
            tail <= 4'b0;
            rob_busy <= 16'b0;
            rob_issued <= 16'b0;
            rob_finished <= 16'b0;
            rob_speculative <= 16'b0;
        end
        else begin
            //Tail pointer update
            tail <= next_rob_tail;
            
            //ROB entry bits update & entry update
            if(simple_valid) begin
                rob_finished[simple_rob_num] <= 1'b1;
                rob[simple_rob_num] <= executed_inst_simple;
            end
            if(complex_valid) begin
                rob_finished[complex_rob_num] <= 1'b1;
                rob[complex_rob_num] <= executed_inst_simple;
            end
            if(fp_valid) begin
                rob_finished[fp_rob_num] <= 1'b1;
                rob[fp_rob_num] <= executed_inst_simple;
            end
            
            //Generate output
            if(rob_valid[head] & store_empty_valid[0]) begin
                rob_out_inst_0 <= {rob[head][4:0], rob[head][37], 1'b0/*For store bit: modify when making complex pipeline*/};
                rob_out_valid_0 <= 1'b1;
                if(rob_valid[head+1] & store_empty_valid[1]) begin
                    rob_out_inst_1 <= {rob[head+1][4:0], rob[head+1][37], 1'b0/*For store bit: modify when making complex pipeline*/};;
                    rob_out_valid_1 <= 1'b1;
                    head <= head+2;
                end
                else begin
                    head <= head+1;
                    rob_out_valid_1 <= 1'b0;
                end
            end
            else begin
                rob_out_valid_0 <= 1'b0;
                rob_out_valid_1 <= 1'b0;
            end
        end
    end
    
    assign rob_valid = rob_finished & ~(rob_speculative);
    
    
    //Store buffer: Completion <-> Retire
    //Caution!!: Some instructions in "complex" group should be handled differently -> For example, store instruction should get out of completion buffer doing nothing!.
    
    //Completion: Write to destination reg
    wire [63:0] completed_inst_0;
    wire [63:0] completed_inst_1;
    wire compled_inst_0_valid;
    wire compled_inst_1_valid;
    
    completion completion(
        .rob_out_inst_0(rob_out_inst_0),
        .rob_out_inst_1(rob_out_inst_1),
        .rob_out_valid_0(rob_out_valid_0),
        .rob_out_valid_1(rob_out_valid_1),
        
        .updateAddrA(updateAddrA),
        .updateAddrB(updateAddrB),
        .updateEnA(updateEnA),
        .updateEnB(updateEnB),
        .completed_inst_0(completed_inst_0),
        .completed_inst_1(completed_inst_1),
        .completed_inst_0_valid(completed_inst_0_valid),
        .completed_inst_1_valid(completed_inst_1_valid)
    );
    
    //Store buffer and its control logic
    //Store buffer entry number: can be changed if there is a better one
    reg [63:0] store_buffer [7:0];
    reg [7:0] store_buffer_busy;
    reg [7:0] store_buffer_busy_1;
    reg [2:0] store_empty_0;
    reg [2:0] store_empty_1;
    reg [1:0] store_empty_valid;
    integer store_i;
    
    reg [2:0] store_fin_tag;                //Entry # of finished store instruction
    
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            for(store_i=0; store_i<8; store_i=store_i+1) begin
                store_buffer[store_i] = 64'b0;
            end
            store_buffer_busy <= 8'b0;
        end
        else begin
            case({completed_inst_1_valid, completed_inst_0_valid})
                11: begin
                    if(store_empty_valid[0]) begin
                        store_buffer[store_empty_0] <= completed_inst_0;
                        store_buffer_busy[store_empty_0] <= 1'b1;
                    end
                    else begin
                        //Error case: we can use this for debugging
                    end
                    
                    if(store_empty_valid[1]) begin
                        store_buffer[store_empty_1] <= completed_inst_1;
                        store_buffer_busy[store_empty_1] <= 1'b1;
                    end
                    else begin
                        //Error case
                    end
                end
                10: begin
                    if(store_empty_valid[0]) begin
                        store_buffer[store_empty_0] <= completed_inst_1;
                        store_buffer_busy[store_empty_0] <= 1'b1;
                    end
                    else begin
                        //Error case
                    end
                end
                01: begin
                    if(store_empty_valid[0]) begin
                        store_buffer[store_empty_0] <= completed_inst_0;
                        store_buffer_busy[store_empty_0] <= 1'b1;
                    end
                    else begin 
                        //Error case
                    end
                end
                00:begin
                    //Do nothing
                end
            endcase
            
            if(store_finish) begin
                store_buffer_busy[store_fin_tag] <= 1'b0;
            end
            
        end
    end
    
    
    //Need combinational logic to specify empty store buffer entry and associative search for update
    always@(*) begin
        store_buffer_busy_1 = store_buffer_busy;
        casex(store_buffer_busy)
            8'b0xxxxxxx: begin
                store_empty_0 = 3'd7;
                store_buffer_busy_1[7] = 1'b1;
                store_empty_valid[0] = 1'b1;
            end
            8'b10xxxxxx: begin
                store_empty_0 = 3'd6;
                store_buffer_busy_1[6] = 1'b1;
                store_empty_valid[0] = 1'b1;
            end
            8'b110xxxxx: begin
                store_empty_0 = 3'd5;
                store_buffer_busy_1[5] = 1'b1;
                store_empty_valid[0] = 1'b1;
            end
            8'b1110xxxx: begin
                store_empty_0 = 3'd4;
                store_buffer_busy_1[4] = 1'b1;
                store_empty_valid[0] = 1'b1;
            end
            8'b11110xxx: begin
                store_empty_0 = 3'd3;
                store_buffer_busy_1[3] = 1'b1;
                store_empty_valid[0] = 1'b1;
            end
            8'b111110xx: begin
                store_empty_0 = 3'd2;
                store_buffer_busy_1[2] = 1'b1;
                store_empty_valid[0] = 1'b1;
            end
            8'b1111110x: begin
                store_empty_0 = 3'd1;
                store_buffer_busy_1[1] = 1'b1;
                store_empty_valid[0] = 1'b1;
            end
            8'b11111110: begin
                store_empty_0 = 3'd0;
                store_buffer_busy_1[0] = 1'b1;
                store_empty_valid[0] = 1'b1;
            end
            8'b11111111: begin
                store_empty_valid[0] = 1'b0;
            end
        endcase

        casex(store_buffer_busy_1)
            8'b10xxxxxx: begin
                store_empty_1 = 3'd6;
                store_empty_valid[1] = 1'b1;
            end
            8'b110xxxxx: begin
                store_empty_1 = 3'd5;
                store_empty_valid[1] = 1'b1;
            end
            8'b1110xxxx: begin
                store_empty_1 = 3'd4;
                store_empty_valid[1] = 1'b1;
            end
            8'b11110xxx: begin
                store_empty_1 = 3'd3;
                store_empty_valid[1] = 1'b1;
            end
            8'b111110xx: begin
                store_empty_1 = 3'd2;
                store_empty_valid[1] = 1'b1;
            end
            8'b1111110x: begin
                store_empty_1 = 3'd1;
                store_empty_valid[1] = 1'b1;
            end
            8'b11111110: begin
                store_empty_1 = 3'd0;
                store_empty_valid[1] = 1'b1;
            end
            8'b11111111: begin
                store_empty_valid[1] = 1'b0;
            end
        endcase
    end
    
    integer j;
    
    always@(*) begin
        for(j=0; j<8; j=j+1) begin
            if(store_buffer[j][31:0] == store_fin_addr) begin
                store_fin_tag = j;
            end
        end    
    end
endmodule
    