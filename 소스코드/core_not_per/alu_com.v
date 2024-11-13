`timescale 1ns/1ps
module alu_com(
    input clk,
    input rst_n,
    input [5:0] aluop,
    input [31:0] aluin1,     // pc�� aluin1���� �ް���
    input [31:0] aluin2,     // imm, shamt�� aluin2���� �ް���
    input [4:0] rd,
    output reg [31:0] aluout,
    output reg branch_taken,
    output reg branch_update,
    output reg [31:0] rs2_data,     //amoswap�� �����͸� �̰ɷ� ��������?
    output reg mem_reserved           
    );

    // add sub lui auipc part
    wire [31:0] sum;
    wire [31:0] bar_aluin2;
    assign bar_aluin2 = (aluop[0]|aluop[3] ? ~aluin2 :aluin2);    // ������ aluin2 �״��, ������ aluin2 �� ��Ʈ�� inverse�� ������ ���
    
    ripple_carry_adder add_ripple_carry_adder(
    .a(aluin1),                       
    .b(bar_aluin2),
    .cin(aluop[0]|aluop[3]),
    .sum(sum),
    .cout()
    );            // aluop[0]|aluop[3]���� ������ ���� ����, ������ cin���� 1�� ���� �� sub�� 00001, slt�� 01000���� �ֱ� ������ ���� or�� ��
   
    // slt sltu part  
    wire overflow;
    wire [31:0] slt_alu;    //slt ���� ���
    wire [31:0] sltu_alu;    // sltu ���� ���
    
    assign overflow = (!((aluop[0]|aluop[3])^aluin1[31]^aluin2[31]))&(aluin1[31]^sum[31])&(!aluop[0]|aluop[3]);
    assign slt_alu = {31'b0, (sum[31]^overflow)};             
    assign sltu_alu = ((aluin1 < aluin2) ? 32'b1 :32'b0); // unsigned�� ���� �ܼ� ��
    
    // sll part
    wire [31:0] sll;
    assign sll = aluin1 << aluin2;
    
    // xor part 
    wire [31:0] xor_alu;
    assign xor_alu = aluin1 ^ aluin2;
    
    // srl part
    wire [31:0] srl;
    assign srl = aluin1 >> aluin2;
    
    // sra part
    wire [31:0] sra;
    assign sra = aluin1 >>> aluin2;
    
    // or part 
    wire [31:0] or_alu;
    assign or_alu = aluin1 | aluin2;
    
    // and part 
    wire [31:0] and_alu;
    assign and_alu = aluin1 & aluin2;
    
    // mul part
    wire [1:0] mode;
    wire [63:0] mult_out;
    assign mode = aluop[1:0];
    
    multiplier_all u_multiplier_all(
    .mode(mode),
    .a(aluin1),
    .b(aluin2),
    .out(mult_out)               // ���� ��� ���
    );
    
    wire [31:0] mul_out;
    wire [31:0] mulh_out;
    assign mul_out = mult_out[31:0];       // ���� 32��Ʈ
    assign mulh_out = mult_out[63:32];     // ���� 32��Ʈ

    // divide part                  // div = 11000 divu = 11010 rem = 11100 remu = 11110
    wire [31:0] aluin1_unsigned;         // ������ ������ �⺻������ ���밪�� ���� ���� ����
    wire [31:0] aluin2_unsigned;         // �׷��� ���ؼ��� ��ɾ unsign���� �ƴ��� ���� �ʿ�
    wire error;
    wire [31:0] quotient;                // aluop[1]�� div�� rem ����(0), divu, remu(1)���� ����
    wire [31:0] remainder;               // �̸� �̿��� ������ ��⿡ ���� �Է��� ������
    assign aluin1_unsigned = (aluop[1] ? aluin1 : (aluin1[31] ? ~aluin1+1 : aluin1));       // ���� div�ε� �����ΰ�� 2�� ������ ����� ����
    assign aluin2_unsigned = (aluop[1] ? aluin2 : (aluin2[31] ? ~aluin2+1 : aluin2));
    
    divide u_divide(                    
    .dividend(aluin1_unsigned),
    .divisor(aluin2_unsigned),
    .error(error),
    .quotient(quotient),
    .remainder(remainder));
    // ������ ����� div, divu, rem, remu�� ��� �ùٸ� ������ ���� �ʿ�
    // �̸� ���� ó�� ���� �� �Է��� �ֻ��� ��Ʈ�� �ٿ� 2��Ʈ ¥�� mod_div��� ������ ����
    // �� ������ �̿��� ������ ��� �������� ����� ������ �ϴ��� ������ ������ �ϴ��� ����
    // divu, remu�� ���� �� �� ������� �����̹Ƿ� ������ ��� �������� �״�� ����
    wire [31:0] div;
    wire [31:0] divu;
    wire [31:0] rem;
    wire [31:0] remu;
    wire [1:0] mod_div;
    assign mod_div = {aluin1[31],aluin2[31]};    
    assign div = ((mod_div == 2'b00 | mod_div == 2'b11) ? quotient : ~quotient +1);
    assign rem = ((mod_div == 2'b00 | mod_div == 2'b11) ? remainder : ~remainder +1);
    assign divu = quotient;
    assign remu = remainder;
    
    wire [31:0] sw_imm;
    assign sw_imm = {20'b0, aluin2[11:5], rd};
 
    // lw sw  sw�� aluin2 �ڸ��� rs2�� �ƴ� imm�� ��������, rs2�� �޸𸮿� ������ ������ core_simple���� FF Ÿ�� �ؼ� ���� ���� �ٸ� ��� �ʿ��ҵ�
    wire [31:0] lw;
    wire [31:0] sw;
    ripple_carry_adder lw_ripple_carry_adder(
    .a(aluin1),                       
    .b(aluin2),
    .cin(0),
    .sum(lw),
    .cout()
    );
    
    ripple_carry_adder sw_ripple_carry_adder(
    .a(aluin1),                       
    .b(sw_imm),
    .cin(0),
    .sum(sw),
    .cout()
    );
    
    wire [31:0] jalr_jal;
    ripple_carry_adder jalr_jal_ripple_carry_adder(
    .a(aluin1),                       
    .b(4),
    .cin(0),
    .sum(jalr_jal),
    .cout()
    );
    
    
    //branch
    //beq
    wire beq_taken;
    assign beq_taken = (aluin1 == aluin2) ? 1 : 0;
    // bne
    wire bne_taken;
    assign bne_taken = (aluin1 != aluin2) ? 1 : 0;
    // blt
    wire blt_taken;
    assign blt_taken = ($signed(aluin1) < $signed(aluin2)) ? 1 : 0 ;
    // bge
    wire bge_taken;
    assign bge_taken = ($signed(aluin1) >= $signed(aluin2)) ? 1: 0;
    // bltu
    wire bltu_taken;
    assign bltu_taken = (aluin1 < aluin2) ? 1:0;
    //bgeu
    wire bgeu_taken;
    assign bgeu_taken = (aluin1 >= aluin2) ? 1:0;
     
    // amoswap  rs1 mem address rs2 mem store data rd old mem data store
    // sw�� ���������� ������, ��ȯ�� �������� ���� ���� ���� �;��� �굵 rs2�̹Ƿ� ���� ��� �̿��ϸ� �� ������ ����?
    // exe ����δ� rs1 �״��
    
    //lr.w
    // �굵 �״���
    
    // sc.w
    // �굵?
    
    // �� �� rs2�� �ٸ� ��η� ����. �׷��� ���� ��� exe output �ø���, �� �� �ܰ� rs �� ���� ��Ʈ Ȯ���ϸ鼭 �ؾ���? 
    // �� ��� sw�� imm�̶� rs2 ������ ��ä���..
    
    // csrrw
    // ������ csr�� 12��Ʈ imm �ڸ����� ������ rs2, csr�� �� ���� rs1, rd�� csr ������ ���� ������ �������� ���� �� csr�������Ϳ��� �а� �� �� rd�� �����ϰ� rs1�� �ٽ� csr�� ��� �ϼ�
    // ex-com���� ó��? exe? 
    
    wire [31:0] csr_data;
    /*csr_rf csr_rf(
    .csr_num(aluin2),
    .csr_outdata(csr_data),
    .csr_indata(aluin1)
    */
    
    // output part
    always @(*) begin
        branch_taken = 0;
        branch_update = 0;
        rs2_data = 0;
        aluout = 0;
        mem_reserved = 0;
        
        if (!rst_n) 
        aluout = 32'b0;
        else begin
        case(aluop)
            6'd0: aluout = sum;
            6'd1: aluout = sum;
            6'd2: aluout = sll;
            6'd3: aluout = xor_alu;
            6'd4: aluout = srl;
            6'd5: aluout = sra;
            6'd6: aluout = or_alu;
            6'd7: aluout = and_alu;
            6'd8: aluout = slt_alu;
            6'd9: aluout = sltu_alu;
            6'd16: aluout = mulh_out;
            6'd17: aluout = mulh_out;
            6'd18: aluout = mulh_out;
            6'd22: aluout = mul_out;
            6'd24: aluout = div;
            6'd26: aluout = divu;
            6'd28: aluout = rem;
            6'd30: aluout = remu;
            6'd32: aluout = lw;
            6'd33: aluout = jalr_jal;
            6'd34: aluout = jalr_jal;
            6'd35: aluout = sw;
            6'd36: rs2_data = aluin2;
            6'd37: begin
            aluout = aluin1;
            mem_reserved = 1;
            end
            6'd38: begin
            aluout = aluin1;
            rs2_data = aluin2;
            end
            6'd40: 
            begin
            branch_taken = beq_taken;
            branch_update = 1;
            end
            6'd41: 
            begin
            branch_taken = bne_taken;
            branch_update = 1;
            end
            6'd42: 
            begin
            branch_taken = blt_taken;
            branch_update = 1;
            end
            6'd43: 
            begin
            branch_taken = bge_taken;
            branch_update = 1;
            end
            6'd44: 
            begin
            branch_taken = bltu_taken;
            branch_update = 1;
            end
            6'd45: 
            begin
            branch_taken = bgeu_taken;
            branch_update = 1;
            end
            6'd48:aluout = csr_data;
            
            
                 
                 
    endcase
    end
end   
endmodule