`timescale 1ns/1ps

module tb_alu;

    // �Է� ��ȣ
    reg clk;
    reg rst_n;
    reg [4:0] aluop;
    reg [31:0] aluin1;
    reg [31:0] aluin2;

    // ��� ��ȣ
    wire [31:0] aluout;


    // ALU ��� �ν��Ͻ�ȭ
    alu uut (
        .clk(clk),
        .rst_n(rst_n),
        .aluop(aluop),
        .aluin1(aluin1),
        .aluin2(aluin2),
        .aluout(aluout)
    );

    // Ŭ�� ����
    always #5 clk = ~clk;

    // �׽�Ʈ �ó�����
    initial begin
        // �ʱ� ����
        clk = 0;
        rst_n = 0;
        aluop = 5'h0;
        aluin1 = 32'h0;
        aluin2 = 32'h0;

        // �ùķ��̼� ����
        #20 $finish;
    end

endmodule
