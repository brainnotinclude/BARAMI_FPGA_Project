module store (
    input wire clk,
    input wire rst_n,
    input wire set_busy,            // 명령어 실행 신호
    input wire [31:0] store_addr,   // 저장할 주소
    input wire [31:0] store_data,   // 저장할 데이터
    output reg busy                 // 현재 처리중인 상태
);

    // 상태 변화에 따른 busy 관리
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy <= 0; // 초기화 시 busy는 0
        end else if (set_busy && !busy) begin
            busy <= 1; // 새로운 store가 시작되면 busy 설정
        end else if (busy) begin
            // store 작업이 끝났다고 가정하고 busy 비트 해제
            busy <= 0; // 한 사이클 후에 busy를 해제
        end
    end

    // store 작업을 처리하는 로직은 여기서 수행되나,
    // 실제 버스 처리 모듈에서 이뤄질 수 있음.

endmodule
