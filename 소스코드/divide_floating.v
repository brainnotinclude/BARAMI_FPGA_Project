module divide_floating (
    input [23:0] dividend,  // �������� ���ϴ� ��
    input [23:0] divisor,   // ������ ��
    output reg error,
    output reg [23:0] quotient,  // ��
    output reg [23:0] remainder  // ������
); 
    // ������ ������ ����� ����� �ڷῡ ���� �� ��ũ ÷��
    
    reg [47:0] remainder_reg;        // ���� ���� 
    reg [23:0] divisor_reg;          // ���� �����Ǿ�� �ϴ� �κ�
    reg [5:0] i; // for loop���� ���� ����

    always @(*) begin
        // �ʱⰪ ����
        remainder_reg = {24'b0, dividend}; // ó�� ������ remainder_reg �����ʿ� dividend��, ������ 0���� ä���
        divisor_reg = divisor;             // ������ ���� �������Ϳ� �������ֱ�

        // �ݺ��� ������ ����
        for (i = 0; i < 24; i = i + 1) begin          // 32ȸ �ݺ�
            // ������ �˰����� �� �ܰ� ����           
            remainder_reg = {remainder_reg[46:0], 1'b0};      // �ڸ����� �ű�� ���� shift 
            if (remainder_reg[47:24] >= divisor_reg) begin    //  ���� 32��Ʈ�� divisor_reg�� ���Ͽ� �� �� ������ ���� ������ ��Ʈ�� 1 �־� �� ����ϴ� 
                remainder_reg[47:24] = remainder_reg[47:24] - divisor_reg;
                remainder_reg[0] = 1'b1; // LSB�� 1�� ���
            end
        end

        // ��� �Ҵ�
        if (divisor == 0)
        begin 
        quotient = 24'b0;
        remainder = 24'b0;
        error = 1;
        end 
        else begin
        quotient = remainder_reg[23:0];       // ������ 32��Ʈ�� ���̵ǰ� ���� 32��Ʈ�� �������� �ȴ�. 
        remainder = remainder_reg[47:23];
        error = 0;
        end
    end
endmodule
