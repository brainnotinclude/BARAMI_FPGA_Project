`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/28 22:36:49
// Design Name: 
// Module Name: registerFile
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

//4 read port and 2 write port: maximum 2 instructions are decoded at one cycle
//Assuming there a two instructions A and B. Then 2 read port and one write port is allocated to each instruction
//Finished: Source read(need modification), Destination allocation, write to RRF, register update
//Last modified: 2024-08-09 by jeyun park: 
module registerFile (
    input clk,
    input rst_n,
    input wr_enable_A,              //write enable
    input wr_enable_B,
    input map_en_A,                 //RRF mapping enable: this means that there is a GPR write instruction in decode stage, so we need destination allocation in this cycle
    input map_en_B,
    input [4:0] addrA_0,            //read addresses
    input [4:0] addrA_1,
    input [4:0] addrB_0,
    input [4:0] addrB_1,
    input [4:0] wraddrA,            //write addresses for real write -> happens when finishes execution
    input [4:0] wraddrB,
    input [4:0] wraddrA_map,        //write addresses for destination allocation
    input [4:0] wraddrB_map,
    input [31:0] writeDataA,        //write data
    input [31:0] writeDataB,
    input updateEnA,
    input updateEnB,
    input [4:0] updateAddrA,
    input [4:0] updateAddrB,
    output [31:0] dataA_0,         //read data for A
    output dataA_0_ready,          //check if data is valid. If not, decoder should not use the data and pass register tag to next stage
    output [31:0] dataA_1,
    output dataA_1_ready,
    output [31:0] dataB_0,
    output dataB_0_ready,
    output [31:0] dataB_1,
    output dataB_1_ready,
    output reg wrA_rrError,             //If RRF is full then we can't use register renaming
    output reg wrB_rrError
    );
    
    reg [31:0] arf[31:0];           //32 32bit registers(ARF)
    reg [2:0] arfTag[31:0];         //Tag bit for ARF-RRF mapping 
    reg [31:0] arfBusy;             //Busy bit for ARF: if busy, use data in RRF. Not busy means that there is no pending write to that entry.
    reg [31:0] rrf[7:0];            //8 32bit registers(RRF)
    reg [7:0] rrfBusy;              //8 RRF busy bits: set when the entry is mapped to ARF entry
    reg [7:0] rrfValid;             //If set, it indicates that the register-updating instruction has finished excution but not completed. This means that register writing is already finished, so we can use the entry value
    integer i;
    reg [2:0] emptyRRFentry1;       //Tag of empty RRF entry. If there is only one empty entry, then value in this variable is valid.
    reg [2:0] emptyRRFentry2;       //Tag of empty RRF entry. This value is chosen from the set of(empty RRF - emptyRRFentry1)
    reg [1:0] rrfEmptyValid;        //Valid bit of emptyRRFentry1, 2 variable.
    reg [7:0] rrfBusyTemp;
    
    //read data and make ready signal: check ARF busy bit, then check RRF valid bit
    assign dataA_0 = (~arfBusy[addrA_0]) ? arf[addrA_0] :
                     (rrfValid[arfTag[addrA_0]]) ? rrf[arfTag[addrA_0]] : 32'h00000000;
    assign dataA_0_ready = (~arfBusy[addrA_0]) ? 1'b1 :
                     (rrfValid[arfTag[addrA_0]]) ? 1'b1 : 1'b0;
    assign dataA_1 = (~arfBusy[addrA_1]) ? arf[addrA_1] :
                     (rrfValid[arfTag[addrA_1]]) ? rrf[arfTag[addrA_1]] : 32'h00000000;
    assign dataA_1_ready = (~arfBusy[addrA_1]) ? 1'b1 :
                     (rrfValid[arfTag[addrA_1]]) ? 1'b1 : 1'b0;
                       
    //Need to add case: destination of A is source of B => B is behind A if in-order.
    assign dataB_0 = (~arfBusy[addrB_0]) ? arf[addrB_0] :
                     (rrfValid[arfTag[addrB_0]]) ? rrf[arfTag[addrB_0]] : 32'h00000000;
    assign dataB_0_ready = (addrB_0 == wraddrA_map)? 1'b0 :
                     (~arfBusy[addrB_0]) ? 1'b1 :
                     (rrfValid[arfTag[addrB_0]]) ? 1'b1 : 1'b0;  
    assign dataB_1 = (~arfBusy[addrB_1]) ? arf[addrB_1] :
                     (rrfValid[arfTag[addrB_1]]) ? rrf[arfTag[addrB_1]] : 32'h00000000;
    assign dataB_1_ready = (addrB_1 == wraddrA_map)? 1'b0 :
                     (~arfBusy[addrB_1]) ? 1'b1 :
                     (rrfValid[arfTag[addrB_1]]) ? 1'b1 : 1'b0;                   
    
    always@(posedge clk, negedge rst_n) begin
        //Initialization: every bit to zero
        if(!rst_n) begin
            for(i=0; i<32; i=i+1) begin
                arf[i] <= 32'h00000000;
                arfTag[i] <= 3'b000;
                rrf[i] <= 32'h00000000;
            end
            arfBusy <= 32'h00000000;
            rrfBusy <= 8'h00;
            rrfValid <=8'h00;
        end
        
        else begin
            //Change tag, valid, busy bits when write operation occurs(destination allocation process)
            if(map_en_A) begin
                if(!arfBusy[wraddrA_map] && rrfEmptyValid[0]) begin
                    arfBusy[wraddrA_map] <= 1;              //ARF busy bit set
                    arfTag[wraddrA_map] <= emptyRRFentry1;//Empty RRF tag 
                    rrfBusy[emptyRRFentry1] <= 1'b1;  //RRF busy bit set
                    rrfValid[emptyRRFentry1] <= 1'b0; //RRF valid bit reset
                    wrA_rrError <= 1'b0;
                end
                else begin                  //Case that there is already a pending instruction or there is no available RRF entry.
                    wrA_rrError <= 1'b1;
                end
            end
            if(map_en_B) begin
                if(!arfBusy[wraddrB_map] && rrfEmptyValid[1]) begin
                    arfBusy[wraddrB_map] <= 1;              //ARF busy bit set
                    arfTag[wraddrB_map] <= emptyRRFentry2;//Empty RRF tag 
                    rrfBusy[emptyRRFentry2] <= 1'b1;  //RRF busy bit set
                    rrfValid[emptyRRFentry2] <= 1'b0; //RRF valid bit reset
                    wrB_rrError <= 1'b0;
                end
                else begin                  //Case that there is already a pending instruction or there is no available RRF entry.
                    wrB_rrError <= 1'b1;
                end
            end
            
            //Write to RRF
            if(wr_enable_A) begin
                rrf[arfTag[wraddrA]] <= writeDataA;
                rrfValid[arfTag[wraddrA]] <= 1'b1;              //Modify valid bit because after RRF write, this value is valid
            end
            if(wr_enable_B) begin
                rrf[arfTag[wraddrB]] <= writeDataA;
                rrfValid[arfTag[wraddrB]] <= 1'b1;
            end
            
            //Update ARF entry with the data from corresponding RRF entry
            if(updateEnA) begin
                arf[updateAddrA] <= rrf[arfTag[updateAddrA]];           //Data update
                arfBusy[updateAddrA] <= 1'b0;                           //Now not busy
                rrfBusy[arfTag[updateAddrA]] <= 1'b0;                   //RRF also not busy
            end
            if(updateEnB) begin
                arf[updateAddrB] <= rrf[arfTag[updateAddrB]];
                arfBusy[updateAddrB] <= 1'b0;
                rrfBusy[arfTag[updateAddrB]] <= 1'b0;
            end
            
        end
    end
    
    //logic for empty rrf entry search
    always@(*) begin
        rrfBusyTemp = rrfBusy;
        //Check if there is one available RRF entry
        casex(rrfBusy)
            8'b0xxxxxxx: begin
                emptyRRFentry1 = 3'd7;
                rrfBusyTemp[7] = 1'b1;
                rrfEmptyValid[0] = 1'b1;
            end
            8'b10xxxxxx: begin
                emptyRRFentry1 = 3'd6;
                rrfBusyTemp[6] = 1'b1;
                rrfEmptyValid[0] = 1'b1;
            end
            8'b110xxxxx: begin
                emptyRRFentry1 = 3'd5;
                rrfBusyTemp[5] = 1'b1;
                rrfEmptyValid[0] = 1'b1;
            end
            8'b1110xxxx: begin
                emptyRRFentry1 = 3'd4;
                rrfBusyTemp[4] = 1'b1;
                rrfEmptyValid[0] = 1'b1;
            end
            8'b11110xxx: begin
                emptyRRFentry1 = 3'd3;
                rrfBusyTemp[3] = 1'b1;
                rrfEmptyValid[0] = 1'b1;
            end
            8'b111110xx: begin
                emptyRRFentry1 = 3'd2;
                rrfBusyTemp[2] = 1'b1;
                rrfEmptyValid[0] = 1'b1;
            end
            8'b1111110x: begin
                emptyRRFentry1 = 3'd1;
                rrfBusyTemp[1] = 1'b1;
                rrfEmptyValid[0] = 1'b1;
            end
            8'b11111110: begin
                emptyRRFentry1 = 3'd0;
                rrfBusyTemp[0] = 1'b1;
                rrfEmptyValid[0] = 1'b1;
            end
            8'b11111111: begin
                rrfEmptyValid[0] = 1'b0;
            end
        endcase
        
        //Check if there is two available RRF entry
        casex(rrfBusyTemp)
            8'b10xxxxxx: begin
                emptyRRFentry2 = 3'd6;
                rrfEmptyValid[1] = 1'b1;
            end
            8'b110xxxxx: begin
                emptyRRFentry2 = 3'd5;
                rrfEmptyValid[1] = 1'b1;
            end
            8'b1110xxxx: begin
                emptyRRFentry2 = 3'd4;
                rrfEmptyValid[1] = 1'b1;
            end
            8'b11110xxx: begin
                emptyRRFentry2 = 3'd3;
                rrfEmptyValid[1] = 1'b1;
            end
            8'b111110xx: begin
                emptyRRFentry2 = 3'd2;
                rrfEmptyValid[1] = 1'b1;
            end
            8'b1111110x: begin
                emptyRRFentry2 = 3'd1;
                rrfEmptyValid[1] = 1'b1;
            end
            8'b11111110: begin
                emptyRRFentry2 = 3'd0;
                rrfEmptyValid[1] = 1'b1;
            end
            default: begin
                rrfEmptyValid[1] = 1'b0;
            end
        endcase
    end
    
endmodule
