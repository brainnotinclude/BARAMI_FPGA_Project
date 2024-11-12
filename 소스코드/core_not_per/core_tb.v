`timescale 1ns/1ps
module tb_core_simple;

    // 테스트벤치에서 사용할 신호 선언
    reg clk;
    reg rst_n;
    reg [31:0] instA;
    reg [31:0] instB;
    reg store_finish;
    reg [31:0] store_fin_addr;
    
    wire [31:0] pcF1;
    wire [31:0] pcF2;

    // DUT (Device Under Test) 인스턴스화
    core_simple uut (
        .clk(clk),
        .rst_n(rst_n),
        .instA(instA),
        .instB(instB),
        .store_finish(store_finish),
        .store_fin_addr(store_fin_addr),
        .pcF1(pcF1),
        .pcF2(pcF2)
    );

    // 클럭 생성기
    always #5 clk = ~clk;  // 10단위의 주기

    // 초기화 및 테스트 시나리오
    initial begin
        // 초기 신호 설정
        clk = 0;
        rst_n = 1;
        instA = 0;
        instB = 0;
        store_finish = 0;
        store_fin_addr = 0;

        // 리셋 신호 활성화
        #5 rst_n = 0;
        #20 rst_n = 1;

        // 테스트 벡터 입력
         instA = 32'h00108113;
        instB = 32'h00218213;
        #10 instA = 32'h002202b3;
        instB = 32'h00318613;
        #10 instA = 32'h00000000;
        instB = 32'h00000000;

        // 테스트 완료
        #100 $finish;
    end

endmodule
