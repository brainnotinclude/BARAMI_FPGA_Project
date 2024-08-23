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

    // 24비트 추출
    assign mant_truncated = mant_in[47:24];

    // Guard, Round, Sticky 비트 계산
    assign guard_bit = mant_in[23]; // 24번째 비트
    assign round_bit = mant_in[22]; // 25번째 비트
    assign sticky_bit = |mant_in[21:0]; // 26번째 이후 비트 OR 연산

    // RNE 모드에 따른 반올림 결정
    assign round_increment = guard_bit && (round_bit || sticky_bit || mant_truncated[0]); // for RNE
    // RNE는 G가 1이면서, R이 1이거나 S가 1이거나 mant가 0인 경우 올림되고 나머지는 내림이다. 

    always @(*) begin
    case(mode)
    3'b000: begin               //RNE
        if (round_increment) begin
            mant_out = mant_truncated + 1;
        end else begin
            mant_out = mant_truncated;
        end
    end 
    3'b001:mant_out = mant_truncated;        //걍 절삭 
    3'b010: begin                            // 음수이면 1더하는 즉 -0.5 면 -1로 
        if (sign_bit && (guard_bit || round_bit || sticky_bit)) begin  // 저 세비트 or하는 이유는 셋 다 0이면 1더할 필요 없어지므로 
            mant_out = mant_truncated + 1;
        end else begin
            mant_out = mant_truncated;
        end  
    end
    3'b011: begin                         // 양수이면 1더하는 0.5 가 1로
        if (!sign_bit && (guard_bit || round_bit || sticky_bit)) begin
            mant_out = mant_truncated + 1;
        end else begin
            mant_out = mant_truncated;
        end
    end
    3'b100: begin                         
        if (guard_bit) begin       // 0.5 이상이면 올림 아니면 절삭 RNE인데 덜 섬세한?
            mant_out = mant_truncated + 1;
        end else begin
            mant_out = mant_truncated;
        end 
    end
    default: mant_out = 24'b0;
    endcase
end 
endmodule
