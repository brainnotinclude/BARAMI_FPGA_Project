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


module registerFile (
    input clk,
    input rst_n,
    input wr_enable_A,
    input wr_enable_B,
    input map_en_A,
    input map_en_B,
    input [4:0] addrA_0,
    input [4:0] addrA_1,
    input [4:0] addrB_0,
    input [4:0] addrB_1,
    input [4:0] wraddrA,
    input [4:0] wraddrB,
    input [4:0] wraddrA_map,
    input [4:0] wraddrB_map,
    input [31:0] writeDataA,
    input [31:0] writeDataB,
    output [31:0] dataA_0,
    output dataA_0_ready,
    //output dataA_0_rrfBusy,
    output [31:0] dataA_1,
    output dataA_1_ready,
    //output dataA_1_rrfBusy,
    output [31:0] dataB_0,
    output dataB_0_ready,
    //output dataB_0_rrfBusy,
    output [31:0] dataB_1,
    output dataB_1_ready,
    //output dataB_1_rrfBusy
    output wrA_rrfFull,
    output wrB_rrfFull
    );
    
    reg [31:0] arf[31:0];
    reg [2:0] arfTag[31:0];
    reg [31:0] arfBusy;
    reg [31:0] rrf[7:0];
    reg [7:0] rrfBusy;
    reg [7:0] rrfValid;
    integer i;
    wire rrfEmpty;
    
    assign dataA_0 = (~arfBusy[addrA_0]) ? arf[addrA_0] :
                     (rrfValid[arfTag[addrA_0]]) ? rrf[arfTag[addrA_0]] : 32'h0000;
    assign dataA_0_ready = (~arfBusy[addrA_0]) ? 1'b1 :
                     (rrfValid[arfTag[addrA_0]]) ? 1'b1 : 1'b0;
    assign dataA_1 = (~arfBusy[addrA_1]) ? arf[addrA_1] :
                     (rrfValid[arfTag[addrA_1]]) ? rrf[arfTag[addrA_1]] : 32'h0000;
    assign dataA_1_ready = (~arfBusy[addrA_1]) ? 1'b1 :
                     (rrfValid[arfTag[addrA_1]]) ? 1'b1 : 1'b0;  
    assign dataB_0 = (~arfBusy[addrB_0]) ? arf[addrB_0] :
                     (rrfValid[arfTag[addrB_0]]) ? rrf[arfTag[addrB_0]] : 32'h0000;
    assign dataB_0_ready = (~arfBusy[addrB_0]) ? 1'b1 :
                     (rrfValid[arfTag[addrB_0]]) ? 1'b1 : 1'b0;  
    assign dataB_1 = (~arfBusy[addrB_1]) ? arf[addrB_1] :
                     (rrfValid[arfTag[addrB_1]]) ? rrf[arfTag[addrB_1]] : 32'h0000;
    assign dataB_1_ready = (~arfBusy[addrB_1]) ? 1'b1 :
                     (rrfValid[arfTag[addrB_1]]) ? 1'b1 : 1'b0;                   
    
    always@(posedge clk, negedge rst_n) begin
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
            if(map_en_A) begin
                if(!arfBusy[wraddrA]) begin
                    arfBusy[wraddrA] <= 1;
                    arfTag[wraddrA] <= rrfEmpty;//빈 rrf tag 
                end
                else begin                  //arf에 이미 rrf가 태그되어 있는 경우
                    //해당 명령어는 대기해야 함. 가장 간단한 해법: stall?
                end
            end
        end
    end
    
    //logic for empty rrf entry search: rrf가 모두 찬 경우 역시 고려 필요
    always@(*) begin
        
    end
    
endmodule
