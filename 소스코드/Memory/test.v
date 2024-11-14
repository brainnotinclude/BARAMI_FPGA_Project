`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/27 23:40:32
// Design Name: 
// Module Name: test
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


module test(
    input btn, 
    input HCLK,
    input rst_n,
    output LED,
    
    //AHB interface
    input HCLK,
    input [31:0] M_AHB_0_haddr,
    input [2:0] M_AHB_0_hburst,
    input M_AHB_0_hmastlock,
    input [3:0] M_AHB_0_hprot,
    output reg [31:0] M_AHB_0_hrdata,
    output reg M_AHB_0_hready,
    output M_AHB_0_hresp,
    input [2:0] M_AHB_0_hsize,
    input [1:0] M_AHB_0_htrans,
    input [31:0] M_AHB_0_hwdata,
    input M_AHB_0_hwrite
    );
    
    wire [31:0] load_data;
    reg [31:0] load_addr;
    reg btn_delay;
    reg set_busy; 
    
    always@(posedge HCLK, negedge rst_n) begin
        if(!rst_n) begin
            load_addr <= 32'd123456;
        end
        else begin
            btn_delay <= btn;
            if(btn_delay == 1'b0 && btn == 1'b1 && !busy) begin
                set_busy <= 1'b1;
            end
            else begin
                set_busy <= 1'b0;
            end
        end
    end
    
    assign LED = load_data[0];
    
    
    ahb_load LOAD(
    //AHB interface
    .HCLK(HCLK),
    .M_AHB_0_haddr(M_AHB_0_haddr),
    .M_AHB_0_hburst(M_AHB_0_hburst),
    .M_AHB_0_hmastlock(M_AHB_0_hmastlock),
    .M_AHB_0_hprot(M_AHB_0_hprot),
    .M_AHB_0_hrdata(M_AHB_0_hrdata),
    .M_AHB_0_hready(M_AHB_0_hready),
    .M_AHB_0_hresp(M_AHB_0_hresp),
    .M_AHB_0_hsize(M_AHB_0_hsize),
    .M_AHB_0_htrans(M_AHB_0_htrans),
    .M_AHB_0_hwdata(M_AHB_0_hwdata),
    .M_AHB_0_hwrite(M_AHB_0_hwrite),
    
    //interface to CPU
    .load_data(load_data),
    .load_addr(load_addr),
    .set_busy(set_busy),                     //Begin of addr phase: 1-clk pulse
    .busy(busy)                         //1 if loading is not finished
    );
    //load가 잘 수행되는지 확인. LED 켤까?
endmodule
