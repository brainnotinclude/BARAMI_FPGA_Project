module branchprediction1 (
    input wire clk,
    input wire rst_n,
    input wire [31:0] pc,               // ���� ���α׷� ī���� (PC)
    input wire [31:0] target_addr,      // �б� Ÿ�� �ּ�
    input wire branch_taken,            // �б� ���� ���
    input wire branch_update,           // �б� ��� ������Ʈ ��ȣ
    output reg [31:0] btb_target,       // BTB���� ��ȯ�Ǵ� Ÿ�� �ּ�
    output reg hit,                     // BTB ��ȸ ���� ���� (��Ʈ ����)
    output reg miss                     // BTB ��ȸ ���� ���� (�̽� ����)
);

    parameter BTB_SIZE = 256;            // BTB ũ�� ����
    parameter INDEX_BITS = 8;            // �ε����� ����� ��Ʈ �� (PC�� ���� ��Ʈ ���)

    // BTB ���� ����
    reg [31:0] target_table [0:BTB_SIZE-1]; // Ÿ�� �ּ� ���� ���̺�
    reg [21:0] tag_table [0:BTB_SIZE-1];    // �±� ���� ���̺� (���� ��Ʈ ���)
    reg valid_table [0:BTB_SIZE-1];         // ��ȿ ��Ʈ ���̺�

    wire [INDEX_BITS-1:0] index;
    wire [21:0] tag;

    assign index = pc[INDEX_BITS+1:2]; // PC�� �ε��� ���� (���� 8��Ʈ ���)
    assign tag = pc[31:10];             // PC�� ���� ��Ʈ�� �±׷� ���
    
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (rst_n) begin
            // �ʱ�ȭ 
            for (i = 0; i < BTB_SIZE; i = i + 1) begin
                valid_table[i] <= 0;      // ��� ��Ʈ�� ��ȿȭ
                target_table[i] <= 32'b0; // Ÿ�� �ּ� �ʱ�ȭ
                tag_table[i] <= 22'b0;    // �±� �ʱ�ȭ
             end
            hit <= 0;
            btb_target <= 32'b0;
            miss <= 0;
        end else begin
            // BTB ��ȸ
            if (valid_table[index] && (tag_table[index] == tag)) begin
                hit <= 1;
                btb_target <= target_table[index];
                miss <= 0;
            end else begin
                hit <= 0;
                btb_target <= 32'b0;
                miss <= 1;
            end

            // BTB ������Ʈ
            if (branch_update && branch_taken) begin
                valid_table[index] <= 1;
                target_table[index] <= target_addr;
                tag_table[index] <= tag;
            end
        end
    end
endmodule