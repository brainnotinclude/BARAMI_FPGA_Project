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

    // 테스트 시나리오
    initial begin
        // 초기 설정
        clk = 0;
        rst_n = 0;
        aluop = 5'h0;
        aluin1 = 32'h0;
        aluin2 = 32'h0;

        // 시뮬레이션 종료
        #20 $finish;
    end

endmodule
