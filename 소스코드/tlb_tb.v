module TLB_tb;
    reg clk;
    reg reset;
    reg we;                             // ���� ��� ��ȣ
    reg [19:0] virtual_page_number;     // 20��Ʈ ���� ������ ��ȣ
    reg [19:0] physical_page_number;    // 20��Ʈ ���� ������ ��ȣ
    reg dirty_in;                       // ��Ƽ ��Ʈ �Է�
    reg [31:0] virtual_address;         // 32��Ʈ ���� �ּ� �Է�
    wire tlb_hit;                       // TLB ��Ʈ ���
    wire [31:0] physical_address;       // 32��Ʈ ���� �ּ� ���

    // TLB ��� �ν��Ͻ�ȭ
    TLB dut (
        .clk(clk),
        .reset(reset),
        .we(we),
        .virtual_page_number(virtual_page_number),
        .physical_page_number(physical_page_number),
        .dirty_in(dirty_in),
        .virtual_address(virtual_address),
        .tlb_hit(tlb_hit),
        .physical_address(physical_address)
    );

    // Ŭ�� ����
    always #5 clk = ~clk;

    initial begin
        // �ʱ�ȭ
        clk = 0;
        reset = 1;
        we = 0;
        virtual_page_number = 20'b0;
        physical_page_number = 20'b0;
        dirty_in = 0;
        virtual_address = 32'b0;

        // ���� ����
        #10 reset = 0;

        // TLB�� ù ��° ��Ʈ�� �߰�
        #10 we = 1;
        virtual_page_number = 20'hABC01;
        physical_page_number = 20'h12345;
        dirty_in = 1;
        #10 we = 0;

        // TLB�� �� ��° ��Ʈ�� �߰�
        #10 we = 1;
        virtual_page_number = 20'hDEF02;
        physical_page_number = 20'h67890;
        dirty_in = 1;
        #10 we = 0;

        // ù ��° ���� �ּ� ��ȸ (TLB ��Ʈ)
        #10 virtual_address = {20'hABC01, 12'h000};
        #10 $display("TLB Hit: %b, Physical Address: %h", tlb_hit, physical_address);

        // �� ��° ���� �ּ� ��ȸ (TLB ��Ʈ)
        #10 virtual_address = {20'hDEF02, 12'hFFF};
        #10 $display("TLB Hit: %b, Physical Address: %h", tlb_hit, physical_address);

        // �������� �ʴ� ���� �ּ� ��ȸ (TLB �̽�)
        #10 virtual_address = {20'h12345, 12'hABC};
        #10 $display("TLB Hit: %b, Physical Address: %h", tlb_hit, physical_address);

        // TLB�� �� ��° ��Ʈ�� �߰�
        #10 we = 1;
        virtual_page_number = 20'hFED03;
        physical_page_number = 20'h0FEDC;
        dirty_in = 1;
        #10 we = 0;

        // �� ��° ���� �ּ� ��ȸ (TLB ��Ʈ)
        #10 virtual_address = {20'hFED03, 12'h123};
        #10 $display("TLB Hit: %b, Physical Address: %h", tlb_hit, physical_address);

        // �ùķ��̼� ����
        #100 $finish;
    end
endmodule
