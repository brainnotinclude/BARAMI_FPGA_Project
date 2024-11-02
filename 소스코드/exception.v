module MisalignedExceptionHandler (
    input wire [31:0] instruction_address,
    input wire [31:0] pc,                // 현재 프로그램 카운터 (PC)
    output reg [31:0] next_pc,           // 다음 프로그램 카운터 (PC)
    output reg exception_triggered,      // 예외 발생 신호
    output reg [31:0] exception_code     // 예외 코드
);

// 예외 처리기 시작 주소 (CSR에 정의된 주소를 사용 가능)
localparam [31:0] EXCEPTION_HANDLER_ADDR = 32'h00000004;
localparam [31:0] MISALIGNED_INSTRUCTION_EXCEPTION = 32'd0x02; // RISC-V 예외 코드

// 주소의 정렬 검사 (32비트 정렬 확인)
wire misaligned = (instruction_address[1:0] != 2'b00);

always @(*) begin
    if (misaligned) begin
        // 예외 발생 시 처리
        exception_triggered = 1'b1;       // 예외 발생 표시
        exception_code = MISALIGNED_INSTRUCTION_EXCEPTION;
        next_pc = EXCEPTION_HANDLER_ADDR; // 예외 처리기 주소로 PC 설정
    end else begin
        // 정상 실행 경로
        exception_triggered = 1'b0;       // 예외 발생 안 함
        exception_code = 32'b0;           // 예외 코드 초기화
        next_pc = pc + 4;                 // 다음 명령어로 PC 증가
    end
end

endmodule
