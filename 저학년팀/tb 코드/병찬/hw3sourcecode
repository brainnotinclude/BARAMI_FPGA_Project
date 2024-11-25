module adder_4bit (
    input [3:0] A,  // 4-bit 입력 A
    input [3:0] B,  // 4-bit 입력 B
    input Cin,      // 입력 캐리
    output [3:0] Sum, // 4-bit 합계
    output Cout      // 출력 캐리
);
    assign {Cout, Sum} = A + B + Cin; // 가산기 동작
endmodule

module subtractor_4bit (
    input [3:0] A,  // 4-bit 입력 A
    input [3:0] B,  // 4-bit 입력 B
    input Bin,      // 입력 Borrow (감산용 캐리)
    output [3:0] Diff, // 4-bit 차이
    output Bout     // 출력 Borrow
);
    assign {Bout, Diff} = A - B - Bin; // 감산기 동작
endmodule
