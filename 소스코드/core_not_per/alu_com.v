`timescale 1ns/1ps
module alu_com(
    input clk,
    input rst_n,
    input [5:0] aluop,
    input [31:0] aluin1,     // pc는 aluin1으로 받겠음
    input [31:0] aluin2,     // imm, shamt는 aluin2으로 받겠음
    input [4:0] rd,
    output reg [31:0] aluout,
    output reg branch_taken,
    output reg branch_update,
    output reg [31:0] rs2_data,     //amoswap할 데이터를 이걸로 내보내기?
    output reg mem_reserved           
    );

    // add sub lui auipc part
    wire [31:0] sum;
    wire [31:0] bar_aluin2;
    assign bar_aluin2 = (aluop[0]|aluop[3] ? ~aluin2 :aluin2);    // 덧셈은 aluin2 그대로, 뺄셈은 aluin2 각 비트를 inverse한 값으로 계산
    
    ripple_carry_adder add_ripple_carry_adder(
    .a(aluin1),                       
    .b(bar_aluin2),
    .cin(aluop[0]|aluop[3]),
    .sum(sum),
    .cout()
    );            // aluop[0]|aluop[3]으로 덧셈과 뺄셈 구분, 뺄셈은 cin으로 1이 들어가야 함 sub는 00001, slt는 01000으로 주기 때문에 둘을 or한 것
   
    // slt sltu part  
    wire overflow;
    wire [31:0] slt_alu;    //slt 연산 결과
    wire [31:0] sltu_alu;    // sltu 연산 결과
    
    assign overflow = (!((aluop[0]|aluop[3])^aluin1[31]^aluin2[31]))&(aluin1[31]^sum[31])&(!aluop[0]|aluop[3]);
    assign slt_alu = {31'b0, (sum[31]^overflow)};             
    assign sltu_alu = ((aluin1 < aluin2) ? 32'b1 :32'b0); // unsigned를 위한 단순 비교
    
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
    .out(mult_out)               // 곱셈 계산 결과
    );
    
    wire [31:0] mul_out;
    wire [31:0] mulh_out;
    assign mul_out = mult_out[31:0];       // 하위 32비트
    assign mulh_out = mult_out[63:32];     // 상위 32비트

    // divide part                  // div = 11000 divu = 11010 rem = 11100 remu = 11110
    wire [31:0] aluin1_unsigned;         // 나눗셈 연산은 기본적으로 절대값을 씌운 다음 진행
    wire [31:0] aluin2_unsigned;         // 그러기 위해서는 명령어가 unsign인지 아닌지 구분 필요
    wire error;
    wire [31:0] quotient;                // aluop[1]을 div와 rem 같게(0), divu, remu(1)같게 설정
    wire [31:0] remainder;               // 이를 이용해 나눗셈 모듈에 넣을 입력을 정해줌
    assign aluin1_unsigned = (aluop[1] ? aluin1 : (aluin1[31] ? ~aluin1+1 : aluin1));       // 만약 div인데 음수인경우 2의 보수로 양수로 만듦
    assign aluin2_unsigned = (aluop[1] ? aluin2 : (aluin2[31] ? ~aluin2+1 : aluin2));
    
    divide u_divide(                    
    .dividend(aluin1_unsigned),
    .divisor(aluin2_unsigned),
    .error(error),
    .quotient(quotient),
    .remainder(remainder));
    // 나눗셈 결과를 div, divu, rem, remu에 모두 올바른 값으로 저장 필요
    // 이를 위해 처음 받은 두 입력의 최상위 비트를 붙여 2비트 짜리 mod_div라는 변수를 만듦
    // 이 변수를 이용해 나눗셈 몫과 나머지가 양수를 가져야 하는지 음수를 가져야 하는지 결정
    // divu, remu인 경우는 양 음 관계없는 연산이므로 나눗셈 몫과 나머지를 그대로 받음
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
 
    // lw sw  sw는 aluin2 자리에 rs2가 아닌 imm이 들어오도록, rs2는 메모리에 저장할 값으로 core_simple에서 FF 타게 해서 끌고 오든 다른 방식 필요할듯
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
    // sw와 마찬가지로 저장할, 교환할 레지스터 값은 따로 끌고 와야함 얘도 rs2이므로 같은 경로 이용하면 될 것으로 보임?
    // exe 결과로는 rs1 그대로
    
    //lr.w
    // 얘도 그대魯
    
    // sc.w
    // 얘도?
    
    // 셋 다 rs2를 다른 경로로 받음. 그렇지 않은 경우 exe output 늘리고, 그 전 단계 rs 값 묶인 비트 확장하면서 해야함? 
    // 그 경우 sw는 imm이랑 rs2 구분할 방ㅓㅂ이..
    
    // csrrw
    // 지정된 csr은 12ㅣ트 imm 자리에서 받으면 rs2, csr에 쓸 값은 rs1, rd는 csr 데이터 값을 저장할 레지스터 정보 즉 csr레지스터에서 읽고 그 값 rd에 저장하고 rs1을 다시 csr에 써야 완성
    // ex-com에서 처리? exe? 
    
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