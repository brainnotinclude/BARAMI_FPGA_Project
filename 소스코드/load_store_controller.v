module load_store_controller (
    input wire clk,
    input wire reset,
    // Store 관련 신호
    input wire store_we,                        // 쓰기 요청 신호
    input wire [31:0] store_address,            // 쓰기 주소
    input wire [31:0] store_data,               // 쓰기 데이터
    input wire store_ready,                     // 스토어 모듈에서 준비 완료 신호
    input wire set_busy_store,                  // Store에서 busy 상태로 설정
    output reg busy_store,                      // Store busy 상태 출력
    // Load 관련 신호
    input wire load_we,                         // 읽기 요청 신호
    input wire [31:0] load_address,             // 읽기 주소
    output reg [31:0] load_data,                // 읽은 데이터
    input wire set_busy_load,                   // Load에서 busy 상태로 설정
    output reg busy_load,                       // Load busy 상태 출력
    input wire valid,                           // Load 데이터가 유효한지 알림
    // Store 버퍼와 연결할 신호
    output reg [31:0] store_buffer_address,     // 버퍼에 전달할 주소
    output reg [31:0] store_buffer_data,        // 버퍼에 전달할 데이터
    output reg store_buffer_write_en,           // 버퍼 쓰기 요청
    input wire store_buffer_full,               // 버퍼가 가득 찼는지 확인
    input wire store_buffer_empty,              // 버퍼가 비었는지 확인
    // Store 모듈에서 읽어오는 데이터
    input wire [31:0] store_buffer_read_data,   // 스토어 버퍼에서 읽은 데이터
    input wire store_buffer_read_valid          // 버퍼 데이터가 유효한지 여부
);

    // 초기화 및 상태 관리
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            busy_store <= 0;
            busy_load <= 0;
            store_buffer_write_en <= 0;
        end else begin
            // 스토어 요청 처리 (busy 상태가 아닐 때)
            if (store_we && !store_buffer_full && !busy_store) begin
                store_buffer_address <= store_address;
                store_buffer_data <= store_data;
                store_buffer_write_en <= 1;  // 버퍼에 쓰기 요청
                busy_store <= set_busy_store;  // Store busy 상태 설정
            end else begin
                store_buffer_write_en <= 0;  // 쓰기 비활성화
            end

            // 스토어 모듈이 준비되었을 때 버퍼에 데이터 기록 완료 처리
            if (store_ready && !store_buffer_empty) begin
                busy_store <= 0;  // Store 작업 완료 시 busy 해제
            end

            // Load 요청 처리 (busy 상태가 아닐 때)
            if (load_we && !busy_load) begin
                store_buffer_address <= load_address;  // 읽기 주소 설정
                busy_load <= set_busy_load;  // Load busy 상태 설정
            end

            // Load 데이터 유효 여부 확인
            if (store_buffer_read_valid) begin
                load_data <= store_buffer_read_data;  // 버퍼에서 데이터를 읽음
                busy_load <= 0;  // Load 완료 후 busy 해제
            end
        end
    end
endmodule
