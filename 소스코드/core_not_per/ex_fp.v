`timescale 1ns / 1ps

module ex_fp(
    //From RS
    input [113:0] rs_fp_0,
    input [113:0] rs_fp_1,
    input [3:0] rs_fp_0_entry_num,
    input [3:0] rs_fp_1_entry_num,
    input selector,
    
    //To RS
    output reg fp_0_issue,
    output reg fp_1_issue,
    //To ROB
    output [74:0] executed_inst,
    output reg valid,
    
    output [31:0] writedata_fp,
    output [4:0] writeaddr_fp,
    output writeen_fp,
    
    output reg [3:0] fp_rob_num
    );
    
    wire valid0;
    wire valid1;
    wire [31:0] aluout;
    reg [31:0] aluin1;
    reg [31:0] aluin2;
    reg [4:0] aluop;
    reg [4:0] wrAddr;
    reg fpregwrite;
    
    //Check if rs1, rs2 are both ready
    assign valid0 = rs_fp_0[10] & rs_fp_0[43];
    assign valid1 = rs_fp_1[10] & rs_fp_1[43];
    
    always@(*) begin
        if((valid0==1'b1) && (valid1==1'b0)) begin          //RS0 is ready
            aluin1 = rs_fp_0[37:6];
            aluin2 = rs_fp_0[70:39];
            aluop = rs_fp_0[80:76];
            wrAddr = rs_fp_0[4:0];
            valid = 1'b1;
            fpregwrite = rs_fp_0[71];
            fp_rob_num = rs_fp_0_entry_num;
            fp_0_issue = 1'b1;
        end
        else if((valid0==1'b0) && (valid1==1'b1)) begin         //RS1 is ready
            aluin1 = rs_fp_1[37:6];
            aluin2 = rs_fp_1[70:39];
            aluop = rs_fp_1[80:76];
            wrAddr = rs_fp_1[4:0];
            valid = 1'b1;
            fpregwrite = rs_fp_1[71];
            fp_rob_num = rs_fp_1_entry_num;
            fp_1_issue = 1'b1;
        end
        else if((valid0==1'b0) && (valid1==1'b1)) begin         //If both ready, then select one entry using selector
            if(selector == 1'b0) begin                          //Selector points newer one, so we choose non-pointed entry 
                aluin1 = rs_fp_1[37:6];
                aluin2 = rs_fp_1[70:39];
                aluop = rs_fp_1[80:76];
                wrAddr = rs_fp_1[4:0];
                fpregwrite = rs_fp_1[71];
                fp_rob_num = rs_fp_1_entry_num;
                fp_1_issue = 1'b1;
            end
            else begin
                aluin1 = rs_fp_0[37:6];
                aluin2 = rs_fp_0[70:39];
                aluop = rs_fp_0[80:76];
                wrAddr = rs_fp_0[4:0];
                fpregwrite = rs_fp_0[71];
                fp_rob_num = rs_fp_0_entry_num;
                fp_0_issue = 1'b1;
            end
            valid = 1'b1;
        end
        else begin
                aluin1 = 32'b0;
                aluin2 = 32'b0;
                aluop = 5'b0;
                wrAddr = 5'b0;
                valid = 1'b0;
                fpregwrite=1'b0;
                fp_0_issue = 1'b0;
                fp_1_issue = 1'b0;
          end
          end
          
    floating floating(
        .aluop(aluop),
        .a(aluin1),     // pc는 aluin1으로 받겠음
        .b(aluin2),     // imm, shamt는 aluin2으로 받겠음
        .result(aluout),
        .mode(3'b0)     //mode는 통일
    );
    
    assign executed_inst = {37'b0,fpregwrite, 1'b0, aluout, wrAddr};
    assign writedata_fp = aluout;
    assign writeaddr_fp = wrAddr;
    assign writeen_fp = valid &fpregwrite;
    
endmodule
