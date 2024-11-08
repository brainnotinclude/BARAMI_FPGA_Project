module floating_round (
    input [47:0] mant_in, 
    input [2:0] mode,
    input sign_bit,
    output reg [23:0] mant_out
);

    wire guard_bit;
    wire round_bit;
    wire sticky_bit;
    wire [23:0] mant_truncated;
    wire round_increment;

    // 24��Ʈ ����
    assign mant_truncated = mant_in[47:24];

    // Guard, Round, Sticky ��Ʈ ���
    assign guard_bit = mant_in[23]; // 24��° ��Ʈ
    assign round_bit = mant_in[22]; // 25��° ��Ʈ
    assign sticky_bit = |mant_in[21:0]; // 26��° ���� ��Ʈ OR ����

    // RNE ��忡 ���� �ݿø� ����
    assign round_increment = guard_bit && (round_bit || sticky_bit || mant_truncated[0]); // for RNE
    // RNE�� G�� 1�̸鼭, R�� 1�̰ų� S�� 1�̰ų� mant�� 0�� ��� �ø��ǰ� �������� �����̴�. 

    always @(*) begin
    case(mode)
    3'b000: begin               //RNE
        if (round_increment) begin
            mant_out = mant_truncated + 1;
        end else begin
            mant_out = mant_truncated;
        end
    end 
    3'b001:mant_out = mant_truncated;        //�� ���� 
    3'b010: begin                            // �����̸� 1���ϴ� �� -0.5 �� -1�� 
        if (sign_bit && (guard_bit || round_bit || sticky_bit)) begin  // �� ����Ʈ or�ϴ� ������ �� �� 0�̸� 1���� �ʿ� �������Ƿ� 
            mant_out = mant_truncated + 1;
        end else begin
            mant_out = mant_truncated;
        end  
    end
    3'b011: begin                         // ����̸� 1���ϴ� 0.5 �� 1��
        if (!sign_bit && (guard_bit || round_bit || sticky_bit)) begin
            mant_out = mant_truncated + 1;
        end else begin
            mant_out = mant_truncated;
        end
    end
    3'b100: begin                         
        if (guard_bit) begin       // 0.5 �̻��̸� �ø� �ƴϸ� ���� RNE�ε� �� ������?
            mant_out = mant_truncated + 1;
        end else begin
            mant_out = mant_truncated;
        end 
    end
    default: mant_out = 24'b0;
    endcase
end 
endmodule
