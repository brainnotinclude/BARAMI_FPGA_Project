`timescale 1ns/1ps
module tb_core_simple;

    // �׽�Ʈ��ġ���� ����� ��ȣ ����
    reg clk;
    reg rst_n;
    reg [31:0] instA;
    reg [31:0] instB;
    reg store_finish;
    reg [31:0] store_fin_addr;
    
    wire [31:0] pcF1;
    wire [31:0] pcF2;

    // DUT (Device Under Test) �ν��Ͻ�ȭ
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

    // Ŭ�� ������
    always #5 clk = ~clk;  // 10������ �ֱ�

    // �ʱ�ȭ �� �׽�Ʈ �ó�����
    initial begin
        // �ʱ� ��ȣ ����
        clk = 0;
        rst_n = 1;
        instA = 0;
        instB = 0;
        store_finish = 0;
        store_fin_addr = 0;

        // ���� ��ȣ Ȱ��ȭ
        #5 rst_n = 0;
        #20 rst_n = 1;

        // �׽�Ʈ ���� �Է�
         instA = 32'h00108113;
        instB = 32'h00218213;
        #10 instA = 32'h002202b3;
        instB = 32'h00318613;
        #10 instA = 32'h00000000;
        instB = 32'h00000000;

        // �׽�Ʈ �Ϸ�
        #100 $finish;
    end

endmodule
