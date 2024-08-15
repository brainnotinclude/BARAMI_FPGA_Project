`timescale 1ns/1ps

module tb_alu;

    // 입력 신호
    reg clk;
    reg rst_n;
    reg [4:0] aluop;
    reg [31:0] aluin1;
    reg [31:0] aluin2;

    // 출력 신호
    wire [31:0] aluout;


    // ALU 모듈 인스턴스화
    alu uut (
        .clk(clk),
        .rst_n(rst_n),
        .aluop(aluop),
        .aluin1(aluin1),
        .aluin2(aluin2),
        .aluout(aluout)
    );

    // 클럭 생성
    always #5 clk = ~clk;

    // 케스트 시나리오
    initial begin
        // 초기 설정
        clk = 0;
        rst_n = 0;
        aluop = 5'h0;
        aluin1 = 32'h0;
        aluin2 = 32'h0;
        
        
        #1
        rst_n = 1;
        
      
        #10
        aluop = 5'd0;
        aluin1 = -32'h1;
        aluin2 = 32'h0;   
        #10 
        aluop = 5'd0;
        aluin1 = -32'h1;
        aluin2 = 32'h1;
        #10 
        aluop = 5'd0;
        aluin1 = -32'h1;
        aluin2 = -32'h1;
        #10 
        aluop = 5'd0;
        aluin1 = 32'h1;
        aluin2 = 32'h1;
        
        
        #20            
        aluop = 5'd2;  
        aluin1 = 32'h1;
        aluin2 = 32'h0;
        #20            
        aluop = 5'd2;  
        aluin1 = -32'h1;
        aluin2 = 32'h0;
        #20            
        aluop = 5'd2;
        aluin1 = -32'h1;
        aluin2 = 32'h1;
        #20            
        aluop = 5'd2;  
        aluin1 = -32'h1;
        aluin2 = -32'h1;
        #20            
        aluop = 5'd2;  
        aluin1 = 32'h1;
        aluin2 = 32'h1;
        
        
        #30            
        aluop = 5'd3;  
        aluin1 = 32'h1;
        aluin2 = 32'h0;
        #30            
        aluop = 5'd3;  
        aluin1 = -32'h1;
        aluin2 = 32'h0;
        #30            
        aluop = 5'd3; 
        aluin1 = -32'h1;
        aluin2 = 32'h1;
        #30            
        aluop = 5'd3;  
        aluin1 = -32'h1;
        aluin2 = -32'h1;
        #30            
        aluop = 5'd3;  
        aluin1 = 32'h1;
        aluin2 = 32'h1;
        
        
        #40            
        aluop = 5'd4;  
        aluin1 = 32'h1;
        aluin2 = 32'h0;
        #40            
        aluop = 5'd4;  
        aluin1 = -32'h1;
        aluin2 = 32'h0;
        #40            
        aluop = 5'd4; 
        aluin1 = -32'h1;
        aluin2 = 32'h1;
        #40            
        aluop = 5'd4;  
        aluin1 = -32'h1;
        aluin2 = -32'h1;
        #40            
        aluop = 5'd4;  
        aluin1 = 32'h1;
        aluin2 = 32'h1;

        #50            
        aluop = 5'd5;  
        aluin1 = 32'h1;
        aluin2 = 32'h0;
        #50            
        aluop = 5'd5;  
        aluin1 = -32'h1;
        aluin2 = 32'h0;
        #50            
        aluop = 5'd5; 
        aluin1 = -32'h1;
        aluin2 = 32'h1;
        #50            
        aluop = 5'd5;  
        aluin1 = -32'h1;
        aluin2 = -32'h1;
        #50            
        aluop = 5'd5;  
        aluin1 = 32'h1;
        aluin2 = 32'h1;

    
        #60            
        aluop = 5'd6;  
        aluin1 = 32'h1;
        aluin2 = 32'h0;
        #60            
        aluop = 5'd6;  
        aluin1 = -32'h1;
        aluin2 = 32'h0;
        #60            
        aluop = 5'd6; 
        aluin1 = -32'h1;
        aluin2 = 32'h1;
        #60            
        aluop = 5'd6;  
        aluin1 = -32'h1;
        aluin2 = -32'h1;
        #60            
        aluop = 5'd6;  
        aluin1 = 32'h1;
        aluin2 = 32'h1;


        #70            
        aluop = 5'd7;  
        aluin1 = 32'h1;
        aluin2 = 32'h0;
        #70            
        aluop = 5'd7;  
        aluin1 = -32'h1;
        aluin2 = 32'h0;
        #70            
        aluop = 5'd7; 
        aluin1 = -32'h1;
        aluin2 = 32'h1;
        #70            
        aluop = 5'd7;  
        aluin1 = -32'h1;
        aluin2 = -32'h1;
        #70            
        aluop = 5'd7;  
        aluin1 = 32'h1;
        aluin2 = 32'h1;


        #80            
        aluop = 5'd8;  
        aluin1 = 32'h1;
        aluin2 = 32'h0;
        #80            
        aluop = 5'd8;  
        aluin1 = -32'h1;
        aluin2 = 32'h0;
        #80            
        aluop = 5'd8; 
        aluin1 = -32'h1;
        aluin2 = 32'h1;
        #80            
        aluop = 5'd8;  
        aluin1 = -32'h1;
        aluin2 = -32'h1;
        #80            
        aluop = 5'd8;  
        aluin1 = 32'h1;
        aluin2 = 32'h1;

        
        #90            
        aluop = 5'd9;  
        aluin1 = 32'h1;
        aluin2 = 32'h0;
        #90            
        aluop = 5'd9;  
        aluin1 = -32'h1;
        aluin2 = 32'h0;
        #90            
        aluop = 5'd9; 
        aluin1 = -32'h1;
        aluin2 = 32'h1;
        #90            
        aluop = 5'd9;  
        aluin1 = -32'h1;
        aluin2 = -32'h1;
        #90            
        aluop = 5'd9;  
        aluin1 = 32'h1;
        aluin2 = 32'h1;
        
        
        #100            
        aluop = 5'd16;  
        aluin1 = 32'h1;
        aluin2 = 32'h0;
        #100            
        aluop = 5'd16;  
        aluin1 = -32'h1;
        aluin2 = 32'h0;
        #100            
        aluop = 5'd16; 
        aluin1 = -32'h1;
        aluin2 = 32'h1;
        #100            
        aluop = 5'd16;  
        aluin1 = -32'h1;
        aluin2 = -32'h1;
        #100           
        aluop = 5'd16;  
        aluin1 = 32'h1;
        aluin2 = 32'h1;
        
        
        #110            
        aluop = 5'd22;  
        aluin1 = 32'h1;
        aluin2 = 32'h0;
        #110            
        aluop = 5'd22;  
        aluin1 = -32'h1;
        aluin2 = 32'h0;
        #110            
        aluop = 5'd22; 
        aluin1 = -32'h1;
        aluin2 = 32'h1;
        #110            
        aluop = 5'd22;  
        aluin1 = -32'h1;
        aluin2 = -32'h1;
        #110            
        aluop = 5'd22;  
        aluin1 = 32'h1;
        aluin2 = 32'h1;
        
        
        #120            
        aluop = 5'd24;  
        aluin1 = 32'h1;
        aluin2 = 32'h0;
        #120            
        aluop = 5'd24;  
        aluin1 = -32'h1;
        aluin2 = 32'h0;
        #120            
        aluop = 5'd24; 
        aluin1 = -32'h1;
        aluin2 = 32'h1;
        #120            
        aluop = 5'd24;  
        aluin1 = -32'h1;
        aluin2 = -32'h1;
        #120            
        aluop = 5'd24;  
        aluin1 = 32'h1;
        aluin2 = 32'h1;
        
        
        #130            
        aluop = 5'd26;  
        aluin1 = 32'h1;
        aluin2 = 32'h0;
        #130            
        aluop = 5'd26;  
        aluin1 = -32'h1;
        aluin2 = 32'h0;
        #130            
        aluop = 5'd26; 
        aluin1 = -32'h1;
        aluin2 = 32'h1;
        #130            
        aluop = 5'd26;  
        aluin1 = -32'h1;
        aluin2 = -32'h1;
        #130            
        aluop = 5'd26;  
        aluin1 = 32'h1;
        aluin2 = 32'h1;
        
        
        #140            
        aluop = 5'd28;  
        aluin1 = 32'h1;
        aluin2 = 32'h0;
        #140            
        aluop = 5'd28;  
        aluin1 = -32'h1;
        aluin2 = 32'h0;
        #140            
        aluop = 5'd28; 
        aluin1 = -32'h1;
        aluin2 = 32'h1;
        #140            
        aluop = 5'd28;  
        aluin1 = -32'h1;
        aluin2 = -32'h1;
        #140            
        aluop = 5'd28;  
        aluin1 = 32'h1;
        aluin2 = 32'h1;
        
        
        #150            
        aluop = 5'd30;  
        aluin1 = 32'h1;
        aluin2 = 32'h0;
        #150            
        aluop = 5'd30;  
        aluin1 = -32'h1;
        aluin2 = 32'h0;
        #150            
        aluop = 5'd30; 
        aluin1 = -32'h1;
        aluin2 = 32'h1;
        #150            
        aluop = 5'd30;  
        aluin1 = -32'h1;
        aluin2 = -32'h1;
        #150            
        aluop = 5'd30;  
        aluin1 = 32'h1;
        aluin2 = 32'h1;
        
        
        // 시뮬레이션 종료
        #160 $finish;
    end

endmodule
