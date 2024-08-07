module branchprediction1 (
    input wire clk,
    input wire rst_n,
    input wire [31:0] pc,               // 현재 프로그램 카운터 (PC)
    input wire [31:0] target_addr,      // 분기 타겟 주소
    input wire branch_taken,            // 분기 예측 결과
    input wire branch_update,           // 분기 결과 업데이트 신호
    output reg [31:0] btb_target,       // BTB에서 반환되는 타겟 주소
    output reg hit,                     // BTB 조회 성공 여부 (히트 여부)
    output reg miss                     // BTB 조회 성공 여부 (미스 여부)
);

    parameter BTB_SIZE = 256;            // BTB 크기 정의
    parameter INDEX_BITS = 8;            // 인덱스로 사용할 비트 수 (PC의 하위 비트 사용)

    // BTB 구조 정의
    reg [31:0] target_table [0:BTB_SIZE-1]; // 타겟 주소 저장 테이블
    reg [21:0] tag_table [0:BTB_SIZE-1];    // 태그 저장 테이블 (상위 비트 사용)
    reg valid_table [0:BTB_SIZE-1];         // 유효 비트 테이블

    wire [INDEX_BITS-1:0] index;
    wire [21:0] tag;

    assign index = pc[INDEX_BITS+1:2]; // PC의 인덱스 추출 (하위 8비트 사용)
    assign tag = pc[31:10];             // PC의 상위 비트를 태그로 사용
    
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (rst_n) begin
            // 초기화 
            for (i = 0; i < BTB_SIZE; i = i + 1) begin
                valid_table[i] <= 0;      // 모든 엔트리 무효화
                target_table[i] <= 32'b0; // 타겟 주소 초기화
                tag_table[i] <= 22'b0;    // 태그 초기화
             end
            hit <= 0;
            btb_target <= 32'b0;
            miss <= 0;
        end else begin
            // BTB 조회
            if (valid_table[index] && (tag_table[index] == tag)) begin
                hit <= 1;
                btb_target <= target_table[index];
                miss <= 0;
            end else begin
                hit <= 0;
                btb_target <= 32'b0;
                miss <= 1;
            end

            // BTB 업데이트
            if (branch_update && branch_taken) begin
                valid_table[index] <= 1;
                target_table[index] <= target_addr;
                tag_table[index] <= tag;
            end
        end
    end
endmodule