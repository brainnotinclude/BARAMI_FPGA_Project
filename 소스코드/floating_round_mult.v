module floating_round_mult (
    input [47:0] mant_in, 
    input [2:0] mode,
    input sign_bit,
    input [5:0] count,
    output reg [22:0] mant_out
);

    reg guard_bit;
    reg round_bit;
    reg sticky_bit;
    reg [22:0] mant_truncated;
    wire round_increment;
    reg [5:0] temp;

   always @(*) begin
        case (count)
            6'd0: mant_truncated = mant_in[46:24];
            6'd1: mant_truncated = mant_in[45:23];
            6'd2: mant_truncated = mant_in[44:22];
            6'd3: mant_truncated = mant_in[43:21];
            6'd4: mant_truncated = mant_in[42:20];
            6'd5: mant_truncated = mant_in[41:19];
            6'd6: mant_truncated = mant_in[40:18];
            6'd7: mant_truncated = mant_in[39:17];
            6'd8: mant_truncated = mant_in[38:16];
            6'd9: mant_truncated = mant_in[37:15];
            6'd10: mant_truncated = mant_in[36:14];
            6'd11: mant_truncated = mant_in[35:13];
            6'd12: mant_truncated = mant_in[34:12];
            6'd13: mant_truncated = mant_in[33:11];
            6'd14: mant_truncated = mant_in[32:10];
            6'd15: mant_truncated = mant_in[31:9];
            6'd16: mant_truncated = mant_in[30:8];
            6'd17: mant_truncated = mant_in[29:7];
            6'd18: mant_truncated = mant_in[28:6];
            6'd19: mant_truncated = mant_in[27:5];
            6'd20: mant_truncated = mant_in[26:4];
            6'd21: mant_truncated = mant_in[25:3];
            6'd22: mant_truncated = mant_in[24:2];
            6'd23: mant_truncated = mant_in[23:1];
            6'd24: mant_truncated = mant_in[22:0];
            6'd25: mant_truncated = {mant_in[21:0],1'b0};
            6'd26: mant_truncated = {mant_in[20:0],2*{1'b0}} ;
            6'd27: mant_truncated = {mant_in[19:0],3*{1'b0}} ;
            6'd28: mant_truncated =  {mant_in[18:0],4*{1'b0}} ;
            6'd29: mant_truncated =  {mant_in[17:0],5*{1'b0}} ;
            6'd30: mant_truncated =  {mant_in[16:0],6*{1'b0}} ;
            6'd31: mant_truncated =  {mant_in[15:0],7*{1'b0}} ;
            6'd32: mant_truncated =  {mant_in[14:0],8*{1'b0}} ;
            6'd33: mant_truncated =  {mant_in[13:0],9*{1'b0}} ;
            6'd34: mant_truncated =  {mant_in[12:0],10*{1'b0}};
            6'd35: mant_truncated = {mant_in[11:0],11*{1'b0}} ;
            6'd36: mant_truncated =  {mant_in[10:0],12*{1'b0}} ;
            6'd37: mant_truncated = {mant_in[9:0],13*{1'b0}} ;
            6'd38: mant_truncated = {mant_in[8:0],14*{1'b0}} ;
            6'd39: mant_truncated = {mant_in[7:0],15*{1'b0}} ;
            6'd40: mant_truncated = {mant_in[6:0],16*{1'b0}} ;
            6'd41: mant_truncated =  {mant_in[5:0],17*{1'b0}} ;
            6'd42: mant_truncated =  {mant_in[4:0],18*{1'b0}} ;
            6'd43: mant_truncated = {mant_in[3:0],19*{1'b0}} ;
            6'd44: mant_truncated = {mant_in[2:0],20*{1'b0}} ;
            6'd45: mant_truncated =  {mant_in[1:0],21*{1'b0}} ;
            6'd46: mant_truncated =  {mant_in[0],22*{1'b0}};
            default: mant_truncated = 23'b0; // 기본값
        endcase
    end
    always @(*) begin
    // Guard, Round, Sticky 비트 계산
    temp = 21 - count;
    guard_bit = mant_in[23-count]; // 24번째 비트
    round_bit = mant_in[22-count]; // 25번째 비트
    case(temp)
    6'd0: sticky_bit = |mant_in[21:0];
    6'd1: sticky_bit = |mant_in[20:0];
    6'd2: sticky_bit = |mant_in[19:0];
    6'd3: sticky_bit = |mant_in[18:0];
    6'd4: sticky_bit = |mant_in[17:0];
    6'd5: sticky_bit = |mant_in[16:0];
    6'd6: sticky_bit = |mant_in[15:0];
    6'd7: sticky_bit = |mant_in[14:0];
    6'd8: sticky_bit = |mant_in[13:0];
    6'd9: sticky_bit = |mant_in[12:0];
    6'd10: sticky_bit = |mant_in[11:0];
    6'd11: sticky_bit = |mant_in[10:0];
    6'd12: sticky_bit = |mant_in[9:0];
    6'd13: sticky_bit = |mant_in[8:0];
    6'd14: sticky_bit = |mant_in[7:0];
    6'd15: sticky_bit = |mant_in[6:0];
    6'd16: sticky_bit = |mant_in[5:0];
    6'd17: sticky_bit = |mant_in[4:0];
    6'd18: sticky_bit = |mant_in[3:0];
    6'd19: sticky_bit = |mant_in[2:0];
    6'd20: sticky_bit = |mant_in[1:0];
    6'd21: sticky_bit = |mant_in[0];
    default:sticky_bit = 0;
    endcase
    end

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
    default: mant_out = 23'b0;
    endcase
end 
endmodule
