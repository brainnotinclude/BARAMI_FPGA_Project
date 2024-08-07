module branchprediction (
    input clk,
    input rst_n,
    input [31:0] pc,           // ���α׷� ī���� (PC)
    input branch_taken,        // ���� �б� ���
    input branch,              // �б� ��� �߻� ����
    output wire prediction          // �б� ���� ���
);

    // LUT ũ�� ����
    parameter TABLE_SIZE = 16;      // LUT ũ�� (16 ��Ʈ��)
    parameter INDEX_BITS = 4;        // LUT �ε����� ����� ��Ʈ �� (4��Ʈ)

    // LUT ����
    reg [1:0] prediction_table [0:TABLE_SIZE-1];

    // LUT �ε���
    wire [INDEX_BITS-1:0] index;
    assign index = pc[INDEX_BITS+1:2]; // PC�� ���� ��Ʈ�� �ε����� ���

    // �б� ���� ���
    assign prediction = (prediction_table[index] >= 2'b10) ? 1'b1 : 1'b0;  // 2'b10 �̻��� ��� Taken ����


    integer i;
    // �б� ���� ���̺� ������Ʈ
    always @(posedge clk or negedge rst_n) begin
        if (rst_n) begin
            // ���� ���̺� �ʱ�ȭ
            for (i = 0; i < TABLE_SIZE; i = i + 1) begin
                prediction_table[i] <= 2'b00; // ��� ��Ʈ���� 'Strongly Not Taken'���� �ʱ�ȭ
            end
        end else if (branch) begin
            // �б� �߻� ��, ���� ����� ���� ���̺� ������Ʈ
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
