module Data_Cache (
    input [31:0] address,          // 주소 입력 (32비트)
    input [31:0] write_data,       // 메모리에 저장할 데이터 (32비트)
    input read_enable,             // 읽기 명령 활성화
    input write_enable,            // 쓰기 명령 활성화
    output reg [31:0] read_data,   // 읽은 데이터 출력 (32비트)
    output reg hit,                // 캐시 히트 여부
    input clk,                     // 클럭 신호
    input rst_n,                   // Active-low reset signal
    output reg memory_read,        // 메모리 읽기 신호
    output reg memory_write,       // 메모리 쓰기 신호
    input [31:0] memory_data_in,   // 메모리에서 읽어온 데이터
    output reg [31:0] memory_data_out  // 메모리로 쓸 데이터
);

    // 캐시 라인과 태그 정의
    reg [31:0] cache_lines[255:0][1:0];  // 32비트 데이터 저장, 256개의 인덱스와 2개의 라인
    reg [21:0] cache_tags[255:0][1:0];   // 22비트 태그 저장

    // LRU 비트 및 제어 로직
    reg lru_bits[255:0];                 // 2-way set-associative에서 LRU 관리를 위한 비트
    wire evict_line;                     // 교체할 캐시 라인 번호 (0 또는 1)

    // 인덱스 및 태그 계산
    wire [7:0] index = address[9:2];     // 주소에서 인덱스 추출
    wire [21:0] tag = address[31:10];    // 주소에서 태그 추출

    // 히트 여부 확인을 위한 신호
    wire hit_line0 = (tag == cache_tags[index][0]);
    wire hit_line1 = (tag == cache_tags[index][1]);

    // LRU 로직: 캐시 라인 교체를 결정하는 데 사용
    assign evict_line = lru_bits[index];

    // 캐시 초기화 및 캐시 미스 처리 로직
    integer i, j;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hit <= 0;
            memory_read <= 0;
            memory_write <= 0;
            read_data <= 32'b0;

            // 캐시 라인과 태그 초기화
            for (i = 0; i < 256; i = i + 1) begin
                for (j = 0; j < 2; j = j + 1) begin
                    cache_lines[i][j] <= 32'b0;
                    cache_tags[i][j] <= 22'b0;
                end
                lru_bits[i] <= 0;
            end
        end else begin
            hit <= 0;  // 초기화

            // 읽기 처리
            if (read_enable && !write_enable) begin
                if (hit_line0) begin
                    read_data <= cache_lines[index][0];
                    hit <= 1;
                    lru_bits[index] <= 1'b1;  // LRU 업데이트
                end else if (hit_line1) begin
                    read_data <= cache_lines[index][1];
                    hit <= 1;
                    lru_bits[index] <= 1'b0;  // LRU 업데이트
                end else begin
                    // 캐시 미스 발생 시 메모리에서 데이터 가져오기
                    memory_read <= 1;
                    memory_write <= 0;
                    read_data <= memory_data_in;
                    cache_lines[index][evict_line] <= memory_data_in;
                    cache_tags[index][evict_line] <= tag;
                    lru_bits[index] <= ~evict_line;  // LRU 업데이트
                end
            end

            // 쓰기 처리
            if (write_enable && !read_enable) begin
                if (hit_line0) begin
                    cache_lines[index][0] <= write_data;
                    hit <= 1;
                    lru_bits[index] <= 1'b1;  // LRU 업데이트
                end else if (hit_line1) begin
                    cache_lines[index][1] <= write_data;
                    hit <= 1;
                    lru_bits[index] <= 1'b0;  // LRU 업데이트
                end else begin
                    // 캐시 미스 발생 시 메모리에 데이터 쓰기
                    memory_read <= 0;
                    memory_write <= 1;
                    memory_data_out <= write_data;
                    cache_lines[index][evict_line] <= write_data;
                    cache_tags[index][evict_line] <= tag;
                    lru_bits[index] <= ~evict_line;  // LRU 업데이트
                end
            end

            // 메모리 액세스 후 메모리 읽기/쓰기 신호 해제
            if (memory_read || memory_write) begin
                memory_read <= 0;
                memory_write <= 0;
            end
        end
    end

endmodule
