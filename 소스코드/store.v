module store (
    input wire clk,
    input wire rst_n,
    input wire set_busy,            // 명령어 실행 신호
    input wire [31:0] store_addr,   // 저장할 주소
    input wire [31:0] store_data,   // 저장할 데이터
    input wire store_done,          // 버스 모듈에서 store 작업 완료 신호
    output reg busy                 // 현재 처리중인 상태
);

    // 상태 변화에 따른 busy 관리
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy <= 0; // 초기화 시 busy는 0
        end else if (set_busy && !busy) begin
            busy <= 1; // 새로운 store가 시작되면 busy 설정
        end else if (busy && store_done) begin
            // 버스 모듈에서 store 작업 완료 신호가 오면 busy 해제
            busy <= 0; // store 작업이 완료되면 busy 해제
        end
    end

    // store 작업을 처리하는 로직은 여기서 수행되나,
    // 실제 데이터 전송은 버스 처리 모듈에서 이뤄질 것임.

endmodule
