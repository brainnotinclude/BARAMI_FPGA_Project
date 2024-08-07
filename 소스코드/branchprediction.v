module branchprediction (
    input clk,
    input rst_n,
    input [31:0] pc,           // 프로그램 카운터 (PC)
    input branch_taken,        // 실제 분기 결과
    input branch,              // 분기 명령 발생 여부
    output wire prediction          // 분기 예측 결과
);

    // LUT 크기 정의
    parameter TABLE_SIZE = 16;      // LUT 크기 (16 엔트리)
    parameter INDEX_BITS = 4;        // LUT 인덱스로 사용할 비트 수 (4비트)

    // LUT 선언
    reg [1:0] prediction_table [0:TABLE_SIZE-1];

    // LUT 인덱스
    wire [INDEX_BITS-1:0] index;
    assign index = pc[INDEX_BITS+1:2]; // PC의 하위 비트를 인덱스로 사용

    // 분기 예측 결과
    assign prediction = (prediction_table[index] >= 2'b10) ? 1'b1 : 1'b0;  // 2'b10 이상일 경우 Taken 예측


    integer i;
    // 분기 예측 테이블 업데이트
    always @(posedge clk or negedge rst_n) begin
        if (rst_n) begin
            // 예측 테이블 초기화
            for (i = 0; i < TABLE_SIZE; i = i + 1) begin
                prediction_table[i] <= 2'b00; // 모든 엔트리를 'Strongly Not Taken'으로 초기화
            end
        end else if (branch) begin
            // 분기 발생 시, 실제 결과에 따라 테이블 업데이트
            if (branch_taken) begin
                case(prediction_table[index])
                    2'b11: prediction_table[index] <= 2'b11;
                    2'b10: prediction_table[index] <= 2'b11;
                    2'b01: prediction_table[index] <= 2'b11;
                    2'b00: prediction_table[index] <= 2'b01;
                    endcase
                     
            end else begin
               case(prediction_table[index])
                   2'b00: prediction_table[index] <= 2'b00;
                   2'b01: prediction_table[index] <= 2'b00;
                   2'b10: prediction_table[index] <= 2'b00;
                   2'b11: prediction_table[index] <= 2'b10;
               endcase           
            end
        end
    end

endmodule
