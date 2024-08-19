module divide_floating (
    input [23:0] dividend,  // 나눗셈을 당하는 값
    input [23:0] divisor,   // 나누는 값
    output reg error,
    output reg [23:0] quotient,  // 몫
    output reg [23:0] remainder  // 나머지
); 
    // 참고한 나눗셈 방식은 깃허브 자료에 사진 및 링크 첨부
    
    reg [47:0] remainder_reg;        // 사진 참고 
    reg [23:0] divisor_reg;          // 값이 유지되어야 하는 부분
    reg [5:0] i; // for loop에서 사용될 변수

    always @(*) begin
        // 초기값 설정
        remainder_reg = {24'b0, dividend}; // 처음 설정은 remainder_reg 오른쪽에 dividend를, 왼쪽은 0으로 채우기
        divisor_reg = divisor;             // 나누는 값도 레지스터에 저장해주기

        // 반복적 나눗셈 수행
        for (i = 0; i < 24; i = i + 1) begin          // 32회 반복
            // 나눗셈 알고리즘의 한 단계 수행           
            remainder_reg = {remainder_reg[46:0], 1'b0};      // 자릿수를 옮기기 위한 shift 
            if (remainder_reg[47:24] >= divisor_reg) begin    //  왼쪽 32비트와 divisor_reg를 비교하여 뺄 수 있으면 빼고 최하위 비트에 1 넣어 몫에 기록하는 
                remainder_reg[47:24] = remainder_reg[47:24] - divisor_reg;
                remainder_reg[0] = 1'b1; // LSB에 1을 기록
            end
        end

        // 결과 할당
        if (divisor == 0)
        begin 
        quotient = 24'b0;
        remainder = 24'b0;
        error = 1;
        end 
        else begin
        quotient = remainder_reg[23:0];       // 오른쪽 32비트는 몫이되고 왼쪽 32비트는 나머지가 된다. 
        remainder = remainder_reg[47:23];
        error = 0;
        end
    end
endmodule
