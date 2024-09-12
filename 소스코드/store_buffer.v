module store_buffer (
    input wire clk,
    input wire reset,
    input wire store_we,                     // 쓰기 요청 신호
    input wire [31:0] store_address,         // 쓰기 주소
    input wire [31:0] store_data,            // 쓰기 데이터
    input wire mem_ready,                    // 메모리가 준비되었음을 알리는 신호
    output reg [31:0] mem_address,           // 메모리로 보낼 주소
    output reg [31:0] mem_data,              // 메모리로 보낼 데이터
    output reg mem_write_en                  // 메모리에 쓰기 활성화 신호
);

    // 스토어 버퍼는 FIFO(선입선출) 큐로 구현
    reg [31:0] buffer_address [3:0];         // 최대 4개의 주소 저장
    reg [31:0] buffer_data [3:0];            // 최대 4개의 데이터 저장
    reg [1:0] head;                          // 큐의 head 포인터
    reg [1:0] tail;                          // 큐의 tail 포인터
    reg full;                                // 버퍼가 가득 찼는지 여부
    reg empty;                               // 버퍼가 비었는지 여부

    // 초기화 및 상태 관리
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            head <= 2'b00;
            tail <= 2'b00;
            full <= 0;
            empty <= 1;
            mem_write_en <= 0;
        end else begin
            // 스토어 요청이 들어왔을 때 (store_we 신호가 1일 때)
            if (store_we && !full) begin
                buffer_address[tail] <= store_address;
                buffer_data[tail] <= store_data;
                tail <= tail + 1;  // tail 포인터 증가 (비트 크기 2비트로 자동 순환)
                empty <= 0;
                if (tail + 1 == head) begin
                    full <= 1;  // tail이 head에 도달하면 버퍼가 가득 찼음
                end
            end

            // 메모리가 준비되었을 때, 버퍼에서 데이터를 메모리에 기록
            if (mem_ready && !empty) begin
                mem_address <= buffer_address[head];
                mem_data <= buffer_data[head];
                mem_write_en <= 1;  // 메모리 쓰기 활성화
                head <= head + 1;  // head 포인터 증가 (비트 크기 2비트로 자동 순환)
                full <= 0;
                if (head + 1 == tail) begin
                    empty <= 1;  // head가 tail에 도달하면 버퍼가 비었음
                end
            end else begin
                mem_write_en <= 0;  // 메모리 쓰기 비활성화
            end
        end
    end
endmodule
