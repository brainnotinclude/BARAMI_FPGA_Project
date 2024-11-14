`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/09/08 18:54:57
// Design Name: 
// Module Name: ahb_load_store
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

//기본적으로 PL은 항상 READ 요청. Read에서 읽은게 load addr인 경우에만 load된 data 쓰기 수행
//Load/store 분리하기로 결정.

    module ahb_load(
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
    input M_AHB_0_hwrite,
    
    //interface to CPU
    output [31:0] load_data,
    input [31:0] load_addr,
    input set_busy,                     //Begin of addr phase: 1-clk pulse
    output reg busy                         //1 if loading is not finished
    );
    
    reg [1:0] r_ctrl;
    reg [1:0] w_ctrl;
    
    reg addr_ready;
    reg data_ready;
    reg data_data_ready;
    reg w_ready;
    reg r_addr;
    
    reg [31:0] load_addr_internal;
    reg [31:0] load_data_internal;
    
    //We use nonseq send/receive
    //read transfer(PL->ZYNQ): send load addr
    
    always@(posedge HCLK) begin                 //For new load
        if(set_busy) begin
            addr_ready <= 1'b1;                 //Addresss phase for load address ready
            data_ready <= 1'b1;
            load_addr_internal <= load_addr;
            busy <= 1'b1;
        end
        else if(addr_ready == 1'b1 && M_AHB_0_hwrite == 1'b0) begin           //Data phase for load addr
            case(r_ctrl)
                2'b00: begin end        //IDLE
                2'b01: begin end        //BUSY
                2'b10: begin            //nonseq 
                   M_AHB_0_hrdata <= load_addr_internal;
                   M_AHB_0_hready <= 1'b1;
                   addr_ready <= 0;
                end
                2'b11: begin  end
            endcase
        end
        //Problem: how do we know it is addr phase or data phase?
        else if(data_ready == 1'b1 && M_AHB_0_hwrite == 1'b1 && M_AHB_0_haddr == 32'b1) begin           //Addr phase for laod data
            case(r_ctrl)
                2'b00: begin end        //IDLE
                2'b01: begin end        //BUSY
                2'b10: begin            //nonseq 
                   data_ready<=0;
                end
                2'b11: begin  end
            endcase
        end
        else begin      //Data phase for load data & idle case
            case(r_ctrl)
                2'b00: begin end        //IDLE
                2'b01: begin end        //BUSY
                2'b10: begin            //nonseq 
                   load_data_internal <= M_AHB_0_hwdata;
                   M_AHB_0_hready <= 1'b0;
                   busy <= 0;
                end
                2'b11: begin  end
            endcase
        end
    end
    
    
    always@(*) begin                 //mode set
        if(M_AHB_0_hwrite==1'b0) begin
            case(M_AHB_0_htrans)
                2'b00:          //idle
                    r_ctrl=2'b00;
                2'b01:          //busy
                    r_ctrl=2'b01;
                2'b10:          //nonseq
                begin
                    r_ctrl=2'b10;
                    r_addr=M_AHB_0_haddr;
                end
                2'b11:          //seq
                    r_ctrl=2'b11;
            endcase
        end
    end
    
    
endmodule

/*
module ahb_store(
    //AHB interface
    input HCLK,
    input [31:0] M_AHB_0_haddr,
    input [2:0] M_AHB_0_hburst,
    input M_AHB_0_hmastlock,
    input [3:0] M_AHB_0_hprot,
    output reg [31:0] M_AHB_0_hrdata,
    output M_AHB_0_hready,
    output M_AHB_0_hresp,
    input [2:0] M_AHB_0_hsize,
    input [1:0] M_AHB_0_htrans,
    input [31:0] M_AHB_0_hwdata,
    input M_AHB_0_hwrite,
    
    //interface to CPU
    input [31:0] store_data,
    input [31:0] store_addr,
    output [31:0] load_data,
    output [31:0] load_addr
    );
    
    reg [1:0] r_ctrl;
    reg [1:0] w_ctrl;
    reg [1:0] counter;
    
    reg r_ready;
    reg w_ready;
    reg [31:0] store_data_internal;
    reg [31:0] store_addr_internal;
    reg [31:0] load_addr_internal;
    reg [31:0] load_data_internal;
    
    //read transfer(PL->ZYNQ): send store addr, store data, load addr
    always@(posedge HCLK) begin
        if(M_AHB_0_hwrite==1'b0) begin
            case(M_AHB_0_htrans)
                2'b00:          //idle
                    r_ctrl<=2'b00;
                2'b01:          //busy
                    r_ctrl<=2'b01;
                2'b10:          //nonseq
                    r_ctrl<=2'b10;
                2'b11:          //seq
                begin
                    r_ctrl<=2'b11;
                    counter<=2'b00;
                end
            endcase
        end
    end
    
    always@(*) begin
        case(r_ctrl)
            2'b00: begin end        //IDLE
            2'b01: begin end        //BUSY
            2'b10: begin end         //nonseq -> should not happen!
            2'b11: begin
                M_AHB_0_hrdata = store_data_internal;
            end
        endcase
    end
    
    //write transfer(ZYNQ->PL): receive load data
    always@(posedge HCLK) begin
        if(M_AHB_0_hwrite==1'b1) begin  //write address phase
            case(M_AHB_0_htrans)
                2'b00:          //idle
                    w_ctrl<=2'b00;
                2'b01:          //busy
                    w_ctrl<=2'b01;
                2'b10:          //nonseq
                begin
                    w_ctrl<=2'b10;
                    w_ready <= 1'b1;
                end
                2'b11:          //seq
                begin
                    w_ctrl<=2'b11;
                end
            endcase
        end
    end
    
    //write data phase
    always@(posedge HCLK) begin
        if(M_AHB_0_hwrite==1'b1 && w_ready == 1'b1) begin
            case(w_ctrl)
                2'b00: begin end
                2'b01: begin end
                2'b10:
                begin
                    load_data_internal <= M_AHB_0_hwdata;
                    w_ready <= 0;
                end
                2'b10: begin end
            endcase
        end
    end
    
    assign load_data = load_data_internal
    
endmodule*/
