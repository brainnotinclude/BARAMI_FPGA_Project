module ex_complex(
    //From RS
    input [113:0] rs_complex_0,
    input [113:0] rs_complex_1,
    input [3:0] rs_complex_0_entry_num,
    input [3:0] rs_complex_1_entry_num,
    input selector,
   

    output complex_0_issue,
    output complex_1_issue,
    //To ROB
    output [74:0] executed_inst,                     //memdata + memwrite + memread + memtoreg + branch + fpregwrite + regWrite + result + writeAddr
    output reg valid,
    //To RF
    output [31:0] writeData,
    output [4:0] writeAddr,
    output writeEn,
    output reg [3:0] complex_rob_num,
    // To prediction
    output branch_taken,
    output branch_update
    );
    wire valid0;            //RS0 ready bit
    wire valid1;            //RS1 ready bit
    
    reg memwrite;
    reg memread;
    reg memtoreg;
    reg branch;
    reg regwrite;
    
    wire [31:0] aluout;
    reg [31:0] aluin1;
    reg [31:0] aluin2;
    reg [5:0] aluop;
    reg [4:0] wrAddr;
    reg [31:0] memdata;
    //Check if rs1, rs2 are both ready
    assign valid0 = rs_complex_0[5] & rs_complex_0[38];
    assign valid1 = rs_complex_1[5] & rs_complex_1[38];
    
    always@(*) begin
        if((valid0==1'b1) && (valid1==1'b0)) begin          //RS0 is ready
            aluin1 = rs_complex_0[37:6];
            aluin2 = rs_complex_0[70:39];
            aluop = rs_complex_0[81:76];
            wrAddr = rs_complex_0[4:0];
            valid = 1'b1;
            memdata = rs_complex_0[113:82];
            memwrite = rs_complex_0[75];
            memread = rs_complex_0[74];
            memtoreg = rs_complex_0[73];
            branch = rs_complex_0[72];
            regwrite = rs_complex_0[71];
            complex_rob_num = rs_complex_0_entry_num;
        end
        else if((valid0==1'b0) && (valid1==1'b1)) begin         //RS1 is ready
            aluin1 = rs_complex_1[37:6];
            aluin2 = rs_complex_1[70:39];
            aluop = rs_complex_1[81:76];
            wrAddr = rs_complex_1[4:0];
            valid = 1'b1;
            memdata = rs_complex_1[113:82];
            memwrite = rs_complex_1[75];
            memread = rs_complex_1[74];
            memtoreg = rs_complex_1[73];
            branch = rs_complex_1[72];
            regwrite = rs_complex_1[71];
            complex_rob_num = rs_complex_1_entry_num;
        end
        else if((valid0==1'b0) && (valid1==1'b1)) begin         //If both ready, then select one entry using selector
            if(selector == 1'b0) begin                          //Selector points newer one, so we choose non-pointed entry 
                aluin1 = rs_complex_1[37:6];
                aluin2 = rs_complex_1[70:39];
                aluop = rs_complex_1[81:76];
                wrAddr = rs_complex_1[4:0];
                memdata = rs_complex_1[113:82];
                memwrite = rs_complex_1[75];
                memread = rs_complex_1[74];
                memtoreg = rs_complex_1[73];
                branch = rs_complex_1[72];
                regwrite = rs_complex_1[71];
                complex_rob_num = rs_complex_1_entry_num;
            end
            else begin
                aluin1 = rs_complex_0[37:6];
                aluin2 = rs_complex_0[70:39];
                aluop = rs_complex_0[81:76];
                wrAddr = rs_complex_0[4:0];
                memdata = rs_complex_0[113:82];
                memwrite = rs_complex_0[75];
                memread = rs_complex_0[74];
                memtoreg = rs_complex_0[73];
                branch = rs_complex_0[72];
                regwrite = rs_complex_0[71];
                complex_rob_num = rs_complex_0_entry_num;
            end
            valid = 1'b1;
        end
        else begin
                aluin1 = 32'b0;
                aluin2 = 32'b0;
                aluop = 6'b0;
                wrAddr = 5'b0;
                valid = 1'b0;
                memdata = 32'b0;
                memwrite = 0;
                memread = 0;
                memtoreg = 0;
                branch = 0;
                regwrite = 0;
        end
    end
    
    alu_com alu_com(
        .aluop(aluop),
        .aluin1(aluin1),     // pc는 aluin1으로 받겠음
        .aluin2(aluin2),     // imm, shamt는 aluin2으로 받겠음
        .rd(wrAddr),
        .aluout(aluout),
        .branch_taken(branch_taken),
        .branch_update(branch_update),
        .mem_reserved(mem_reserved)
    );
    
    
    assign executed_inst = {memdata, memwrite, memread, memtoreg, branch, 1'b0, regwrite, aluout, wrAddr};
    assign writeData = aluout;
    assign writeAddr = wrAddr;
    assign writeEn = valid & regwrite;
    
    
    
endmodule
