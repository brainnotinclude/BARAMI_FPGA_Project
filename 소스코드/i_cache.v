// cache line이 끊기는 경우 -> 감지를 하는 모듈이 필요할 듯, 그 모듈에서 이 모듈로 1을 주면 끊겼다고 
//판단하고 다음 라인까지 읽을 수 있도록 하는 것이 필요할 듯. 사실상 책의 내용이 완전히 이해가 가지 않음...
// T_logic 모듈
// T_logic 모듈
module T_logic (
    input [21:0] tag,       // 입력 주소의 태그 부분 (31:10)
    input [21:0] cache_tag, // 캐시 라인의 태그
    output reg hit          // 히트 여부 출력
);
    always @(*) begin
        if (tag == cache_tag) begin
            hit = 1;
        end else begin
            hit = 0;
        end
    end
endmodule

// MUX 모듈
module MUX (
    input select,            // MUX 선택 신호
    input [31:0] data0,      // 입력 데이터 0 (32비트)
    input [31:0] data1,      // 입력 데이터 1 (32비트)
    output reg [31:0] out    // 출력 데이터 (32비트)
);
    always @(*) begin
        case (select)
            1'b0: out = data0;
            1'b1: out = data1;
            default: out = 32'b0;
        endcase
    end
endmodule

// Pseudo_LRU 모듈
module Pseudo_LRU (
    input clk,
    input rst_n,            // Active-low reset signal
    input access0,          // Cache line 0 access
    input access1,          // Cache line 1 access
    output reg evict_line   // Line to evict (0 or 1)
);
    reg lru_bit;  // Single bit to track LRU

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lru_bit <= 0;  // Reset LRU bit to 0 when rst_n is low
        end else begin
            if (access0) begin
                lru_bit <= 1;  // Set LRU bit to 1 when accessing line 0
            end else if (access1) begin
                lru_bit <= 0;  // Set LRU bit to 0 when accessing line 1
            end
        end
    end

    always @(*) begin
        evict_line = lru_bit;  // Decide eviction line based on LRU bit
    end
endmodule

// Dual_Cache_Subarray 모듈
module Dual_Cache_Subarray (
    input [31:0] address0,            // 첫 번째 PC 값 (32비트 주소 입력)
    input [31:0] address1,            // 두 번째 PC 값 (32비트 주소 입력)
    output [31:0] selected_data0,     // 첫 번째 PC에 대한 선택된 캐시 데이터 (32비트)
    output [31:0] selected_data1,     // 두 번째 PC에 대한 선택된 캐시 데이터 (32비트)
    output hit0,                      // 첫 번째 PC에 대한 태그 비교 결과
    output hit1,                      // 두 번째 PC에 대한 태그 비교 결과
    input clk,                        // 클럭 신호
    input rst_n,                      // Active-low reset signal
    output [1:0] evict_line0,         // 첫 번째 캐시 서브어레이에서 교체할 라인 번호 (0 또는 1)
    output [1:0] evict_line1,         // 두 번째 캐시 서브어레이에서 교체할 라인 번호 (0 또는 1)
    output reg [31:0] memory_data0,   // 첫 번째 메모리 데이터 출력
    output reg [31:32] memory_data1,   // 두 번째 메모리 데이터 출력
    input [31:0] memory_in0,          // 메모리에서 읽어온 첫 번째 데이터
    input [31:0] memory_in1,          // 메모리에서 읽어온 두 번째 데이터
    output reg memory_read0,          // 첫 번째 메모리 읽기 신호
    output reg memory_read1           // 두 번째 메모리 읽기 신호
);

    // 첫 번째 서브어레이
    reg [31:0] cache_lines0[255:0][1:0];  // 32비트 데이터 저장
    reg [21:0] cache_tags0[255:0][1:0];   // 22비트 태그 저장

    // 두 번째 서브어레이
    reg [31:0] cache_lines1[255:0][1:0];  // 32비트 데이터 저장
    reg [21:0] cache_tags1[255:0][1:0];   // 22비트 태그 저장

    wire hit0_line0, hit0_line1;
    wire hit1_line0, hit1_line1;
    wire select0, select1;

    // Index 계산 (주소의 [9:2] 비트 사용)
    wire [7:0] index0 = address0[9:2];
    wire [7:0] index1 = address1[9:2];

    // 첫 번째 PC에 대한 태그는 주소의 [31:10] 비트 사용
    wire [21:0] tag0 = address0[31:10];

    // 두 번째 PC에 대한 태그는 주소의 [31:10] 비트 사용
    wire [21:0] tag1 = address1[31:10];

    // 첫 번째 PC에 대해 각 서브어레이의 캐시 라인에 대해 태그 비교
    T_logic t0_line0(.tag(tag0), .cache_tag(cache_tags0[index0][0]), .hit(hit0_line0));
    T_logic t0_line1(.tag(tag0), .cache_tag(cache_tags0[index0][1]), .hit(hit0_line1));

    // 두 번째 PC에 대해 각 서브어레이의 캐시 라인에 대해 태그 비교
    T_logic t1_line0(.tag(tag1), .cache_tag(cache_tags1[index1][0]), .hit(hit1_line0));
    T_logic t1_line1(.tag(tag1), .cache_tag(cache_tags1[index1][1]), .hit(hit1_line1));

    // 첫 번째 PC에 대한 태그 비교 결과에 따라 MUX 선택 신호 설정
    assign select0 = (hit0_line0) ? 1'b0 : (hit0_line1) ? 1'b1 : 1'b0;

    // 두 번째 PC에 대한 태그 비교 결과에 따라 MUX 선택 신호 설정
    assign select1 = (hit1_line0) ? 1'b0 : (hit1_line1) ? 1'b1 : 1'b0;

    // 첫 번째 PC에 대해 선택된 데이터 출력
    MUX mux0(.select(select0), .data0(cache_lines0[index0][0]), .data1(cache_lines0[index0][1]), .out(selected_data0));

    // 두 번째 PC에 대해 선택된 데이터 출력
    MUX mux1(.select(select1), .data0(cache_lines1[index1][0]), .data1(cache_lines1[index1][1]), .out(selected_data1));

    // 첫 번째 PC에 대해 하나라도 히트가 발생하면 전체 히트로 설정
    assign hit0 = hit0_line0 | hit0_line1;

    // 두 번째 PC에 대해 하나라도 히트가 발생하면 전체 히트로 설정
    assign hit1 = hit1_line0 | hit1_line1;

    // Pseudo-LRU 모듈 인스턴스화 (각 서브어레이에 대해 독립적으로 관리)
    Pseudo_LRU plru0(
        .clk(clk),
        .rst_n(rst_n),  // Active-low reset signal
        .access0(hit0_line0),
        .access1(hit0_line1),
        .evict_line(evict_line0)
    );

    Pseudo_LRU plru1(
        .clk(clk),
        .rst_n(rst_n),  // Active-low reset signal
        .access0(hit1_line0),
        .access1(hit1_line1),
        .evict_line(evict_line1)
    );

    // 캐시 초기화 및 캐시 미스 처리 로직
    integer i, j;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            memory_read0 <= 0;
            memory_read1 <= 0;

            // 캐시 라인과 태그 초기화
            for (i = 0; i < 256; i = i + 1) begin
                for (j = 0; j < 2; j = j + 1) begin
                    cache_lines0[i][j] <= 32'b0;
                    cache_tags0[i][j] <= 22'b0;
                    cache_lines1[i][j] <= 32'b0;
                    cache_tags1[i][j] <= 22'b0;
                end
            end

        end else begin
            // 캐시 미스 처리
            if (!hit0) begin
                memory_read0 <= 1;
                memory_data0 <= memory_in0;
                // 첫 번째 서브어레이 캐시 업데이트
                cache_lines0[index0][evict_line0] <= memory_in0;
                cache_tags0[index0][evict_line0] <= tag0;
            end else begin
                memory_read0 <= 0;
            end

            if (!hit1) begin
                memory_read1 <= 1;
                memory_data1 <= memory_in1;
                // 두 번째 서브어레이 캐시 업데이트
                cache_lines1[index1][evict_line1] <= memory_in1;
                cache_tags1[index1][evict_line1] <= tag1;
            end else begin
                memory_read1 <= 0;
            end
        end
    end

endmodule

