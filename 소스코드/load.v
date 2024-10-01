module Load (
    input wire clk,
    input wire rst_n,
    input wire set_busy,           // 명령어 실행 신호
    input wire [31:0] load_addr,   // 불러올 주소
    output reg [31:0] load_data,   // 읽어온 데이터
    output reg valid,              // 데이터가 유효한지 여부
    output reg busy                // 현재 처리중인 상태
);

    // busy 및 valid 상태 관리
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy <= 0;   // 초기화 시 busy는 0
            valid <= 0;  // 초기화 시 valid는 0
        end else if (set_busy && !busy) begin
            busy <= 1;   // 새로운 load가 시작되면 busy 설정
            valid <= 0;  // 아직 데이터가 유효하지 않음
        end else if (busy) begin
            // load 작업이 끝났다고 가정하고 valid 설정 및 busy 해제
            busy <= 0;   // 한 사이클 후에 busy 해제
            valid <= 1;  // 데이터가 유효하다는 신호
        end else if (valid) begin
            // valid가 1이 되었을 때 추가 처리가 필요할 수 있음
            // 다음 명령어를 받아도 됨
            valid <= 0;
        end
    end

    // load 작업을 처리하는 로직은 여기서 수행되나,
    // 실제 버스 처리 모듈에서 이뤄질 수 있음.

endmodule
