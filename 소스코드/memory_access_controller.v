module memory_access_controller (
    input wire clk,
    input wire reset,
    input wire tlb_hit,                      // TLB 모듈에서 나온 히트 신호
    input wire [31:0] virtual_address,       // 가상 주소 입력
    output reg page_table_access,            // 페이지 테이블 액세스 신호
    output reg [19:0] virtual_page_number,   // 페이지 테이블로 보낼 가상 페이지 번호
    input wire [19:0] page_table_frame,      // 페이지 테이블에서 받은 물리 프레임 번호
    input wire page_table_ready,             // 페이지 테이블에서 데이터가 준비되었음을 알리는 신호
    output reg tlb_we,                       // TLB 쓰기 활성화 신호
    output reg [19:0] tlb_virtual_page,      // TLB에 저장할 가상 페이지 번호
    output reg [19:0] tlb_physical_page      // TLB에 저장할 물리 페이지 번호
);

    reg [19:0] vp_number;  // 가상 페이지 번호
    reg [11:0] page_offset; // 페이지 오프셋
    reg waiting_for_page_table; // 페이지 테이블 준비를 기다리는 상태

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            page_table_access <= 0;
            tlb_we <= 0;
            waiting_for_page_table <= 0;  // 대기 상태 초기화
        end else begin
            vp_number <= virtual_address[31:12];  // 가상 페이지 번호 추출
            page_offset <= virtual_address[11:0]; // 페이지 오프셋 추출
            
            // TLB 히트가 아닐 때 페이지 테이블에 액세스
            if (!tlb_hit && !waiting_for_page_table) begin
                page_table_access <= 1;  // 페이지 테이블 액세스 신호 활성화
                virtual_page_number <= vp_number;  // 페이지 테이블에 가상 페이지 번호 전달
                waiting_for_page_table <= 1;  // 페이지 테이블 준비 대기 상태로 전환
            end

            // 페이지 테이블 데이터가 준비되었는지 확인
            if (waiting_for_page_table && page_table_ready) begin
                tlb_we <= 1;  // TLB 쓰기 신호 활성화
                tlb_virtual_page <= vp_number;  // TLB에 저장할 가상 페이지 번호
                tlb_physical_page <= page_table_frame;  // TLB에 저장할 물리 페이지 번호
                waiting_for_page_table <= 0;  // 대기 상태 해제
                page_table_access <= 0;  // 페이지 테이블 액세스 종료
            end else if (waiting_for_page_table && !page_table_ready) begin
                // 페이지 테이블이 아직 준비되지 않으면 계속 대기
                tlb_we <= 0;  // TLB 쓰기 비활성화
            end

            // TLB 히트일 때는 페이지 테이블 액세스 및 쓰기 비활성화
            if (tlb_hit) begin
                page_table_access <= 0;
                tlb_we <= 0;
                waiting_for_page_table <= 0;  // 대기 상태 초기화
            end
        end
    end
endmodule
