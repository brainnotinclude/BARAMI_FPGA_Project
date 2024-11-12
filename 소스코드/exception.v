module misaligned_exception(
    input wire clk,
    input wire reset,
    input wire [31:0] address,  // Memory address input
    input wire [6:0] opcode,    // 7-bit opcode input for instruction type identification
    output reg exception,       // Exception signal
    output reg flush            // Flush signal
);

    // Opcode values for lw and sw 변경 필요함
    localparam LW_OPCODE = 7'b0000011;  // Load Word opcode
    localparam SW_OPCODE = 7'b0100011;  // Store Word opcode

    // Exception의 에러 코드, 수정가능
    localparam MISALIGNED_EXCEPTION_CODE = 32'h00000004;

    // Registers for exception status
    reg [31:0] mcause;   // 익셉션 원인을 저장하는 레지스터
    reg [31:0] mepc;     // 익셉션이 발생한 명령어의 PC 

    // Signal to indicate valid memory operation (valid only for lw or sw)
    wire valid;
    assign valid = (opcode == LW_OPCODE) || (opcode == SW_OPCODE);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            exception <= 0;
            flush <= 0;
            mcause <= 32'b0;
            mepc <= 32'b0;
        end else begin
            //4의 배수인지 확인
            if (valid && (address[1:0] != 2'b00)) begin
                exception <= 1; // 레지스터값 참조해서 어떻게 처리되는
                flush <= 1;   // Trigger flush
                mcause <= MISALIGNED_EXCEPTION_CODE;
                mepc <= address; // Capture the address causing the exception
            end else begin
                exception <= 0;
                flush <= 0;
            end
        end
    end
endmodule
