module TLB_tb;
    reg clk;
    reg reset;
    reg we;                             // 쓰기 허용 신호
    reg [19:0] virtual_page_number;     // 20비트 가상 페이지 번호
    reg [19:0] physical_page_number;    // 20비트 물리 페이지 번호
    reg dirty_in;                       // 더티 비트 입력
    reg [31:0] virtual_address;         // 32비트 가상 주소 입력
    wire tlb_hit;                       // TLB 히트 출력
    wire [31:0] physical_address;       // 32비트 물리 주소 출력

    // TLB 모듈 인스턴스화
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

    // 클럭 생성
    always #5 clk = ~clk;

    initial begin
        // 초기화
        clk = 0;
        reset = 1;
        we = 0;
        virtual_page_number = 20'b0;
        physical_page_number = 20'b0;
        dirty_in = 0;
        virtual_address = 32'b0;

        // 리셋 해제
        #10 reset = 0;

        // TLB에 첫 번째 엔트리 추가
        #10 we = 1;
        virtual_page_number = 20'hABC01;
        physical_page_number = 20'h12345;
        dirty_in = 1;
        #10 we = 0;

        // TLB에 두 번째 엔트리 추가
        #10 we = 1;
        virtual_page_number = 20'hDEF02;
        physical_page_number = 20'h67890;
        dirty_in = 1;
        #10 we = 0;

        // 첫 번째 가상 주소 조회 (TLB 히트)
        #10 virtual_address = {20'hABC01, 12'h000};
        #10 $display("TLB Hit: %b, Physical Address: %h", tlb_hit, physical_address);

        // 두 번째 가상 주소 조회 (TLB 히트)
        #10 virtual_address = {20'hDEF02, 12'hFFF};
        #10 $display("TLB Hit: %b, Physical Address: %h", tlb_hit, physical_address);

        // 존재하지 않는 가상 주소 조회 (TLB 미스)
        #10 virtual_address = {20'h12345, 12'hABC};
        #10 $display("TLB Hit: %b, Physical Address: %h", tlb_hit, physical_address);

        // TLB에 세 번째 엔트리 추가
        #10 we = 1;
        virtual_page_number = 20'hFED03;
        physical_page_number = 20'h0FEDC;
        dirty_in = 1;
        #10 we = 0;

        // 세 번째 가상 주소 조회 (TLB 히트)
        #10 virtual_address = {20'hFED03, 12'h123};
        #10 $display("TLB Hit: %b, Physical Address: %h", tlb_hit, physical_address);

        // 시뮬레이션 종료
        #100 $finish;
    end
endmodule
