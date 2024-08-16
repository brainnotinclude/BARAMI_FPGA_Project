`timescale 1ns/1ps

module tb_alu;

    // �Է� ��ȣ
    reg clk;
    reg rst_n;
    reg [4:0] aluop;
    reg [31:0] aluin1;
    reg [31:0] aluin2;

    // ��� ��ȣ
    wire [31:0] aluout;


    // ALU ��� �ν��Ͻ�ȭ
    alu uut (
        .clk(clk),
        .rst_n(rst_n),
        .aluop(aluop),
        .aluin1(aluin1),
        .aluin2(aluin2),
        .aluout(aluout)
    );

    // Ŭ�� ����
    always #1 clk = ~clk;

    // �׽�Ʈ �ó�����
    initial begin
        // �ʱ� ����
        clk = 0;
        rst_n = 0;
        //add
        aluop = 5'd0;
        aluin1 = 32'd5;
        aluin2 = 32'd3;
        #1
        rst_n = 1;
        #1
        //mul test
        aluop = 5'd22;
        aluin1 = 32'd2;
        aluin2 = 32'd3;
        #2
        aluop = 5'd22;
        aluin1 = 32'd2;
        aluin2 = 32'd0;
        #2
        aluop = 5'd22;
        aluin1 = -32'd5;
        aluin2 = 32'd3;
        #2
        aluop = 5'd22;
        aluin1 = -32'd2;
        aluin2 = -32'd8;
        #2
        aluop = 5'd22;
        aluin1 = 32'h7FFFFFFF;
        aluin2 = 32'h80000000;
        #2
        //mulhu
        aluop = 5'd16;
        aluin1 = 32'd18;
        aluin2 = 32'd2;
        #2
        aluop = 5'd16;
        aluin1 = 32'h88888888;
        aluin2 = 32'h80000000;
        #2
        aluop = 5'd16;
        aluin1 = 32'hffffffff;
        aluin2 = 32'd2;
        #2
        aluop = 5'd16;
        aluin1 = 32'hffffffff;
        aluin2 = 32'hffffffff;
        #2
        //mulhsu
        aluop = 5'd17;
        aluin1 = 32'h00000002;
        aluin2 = 32'hffffffff;
        #2
        aluop = 5'd17;
        aluin1 = 32'hffffffff;
        aluin2 = 32'h00000002;
        #2
        aluop = 5'd17;
        aluin1 = 32'h80000000;
        aluin2 = 32'hffffffff;
        #2
        //mulh
        aluop = 5'd18;
        aluin1 = 32'h2;
        aluin2 = 32'h3;
        #2
        aluop = 5'd18;
        aluin1 = 32'h80000000;
        aluin2 = 32'h2;
        #2
        aluop = 5'd18;
        aluin1 = 32'hffffffff;
        aluin2 = 32'hffffffff;
        #2
        aluop = 5'd18;
        aluin1 = 32'h80000000;
        aluin2 = 32'h7fffffff;
        #2
        //div
        aluop = 5'd24;
        aluin1 = 32'd15;
        aluin2 = 32'd3;
        #2
        aluop = 5'd24;
        aluin1 = -32'd15;
        aluin2 = 32'd3;
        #2
        aluop = 5'd24;
        aluin1 = -32'd15;
        aluin2 = -32'd3;
        #2
        aluop = 5'd24;
        aluin1 = 32'h80000000;
        aluin2 = 32'hffffffff;
        #2
        aluop = 5'd24;
        aluin1 = 32'h80000000;
        aluin2 = 32'h7fffffff;
        #2
        aluop = 5'd24;
        aluin1 = 32'd5;
        aluin2 = 32'd0;
        #2
        aluop = 5'd24;
        aluin1 = -32'd1;
        aluin2 = 32'd0;
        #2
        aluop = 5'd24;
        aluin1 = 32'd17;
        aluin2 = 32'd3;
        #2
        //divu
        aluop = 5'd26;
        aluin1 = 32'd15;
        aluin2 = 32'd3;
        #2
        aluop = 5'd26;
        aluin1 = 32'hffffffff;
        aluin2 = 32'h00000001;
        #2
        aluop = 5'd26;
        aluin1 = 32'hffffffff;
        aluin2 = 32'h00000003;
        #2
        aluop = 5'd26;
        aluin1 = 32'd5;
        aluin2 = 32'd0;
        #2
        aluop = 5'd26;
        aluin1 = 32'd17;
        aluin2 = 32'd3;
        #2
        //rem
        aluop = 5'd28;
        aluin1 = 32'd5;
        aluin2 = 32'd2;
        #2
        aluop = 5'd28;
        aluin1 = -32'd5;
        aluin2 = 32'd2;
        #2
        aluop = 5'd28;
        aluin1 = -32'd5;
        aluin2 = -32'd2;
        #2
        aluop = 5'd28;
        aluin1 = 32'd5;
        aluin2 = 32'd0;
        #2
        aluop = 5'd28;
        aluin1 = -32'd1;
        aluin2 = 32'd0;
        #2
        aluop = 5'd28;
        aluin1 = 32'h80000000;
        aluin2 = 32'h00000003;
        #2
        aluop = 5'd28;
        aluin1 = 32'h80000000;
        aluin2 = 32'h7fffffff;
        #2
        aluop = 5'd28;
        aluin1 = 32'h80000000;
        aluin2 = 32'hffffffff;
        #2
        //remu
        aluop = 5'd30;
        aluin1 = 32'd5;
        aluin2 = 32'd2;
        #2
        aluop = 5'd30;
        aluin1 = 32'd5;
        aluin2 = 32'd0;
        #2
        aluop = 5'd30;
        aluin1 = 32'hffffffff;
        aluin2 = 32'd0;
        #2
        aluop = 5'd30;
        aluin1 = 32'hffffffff;
        aluin2 = 32'h00000001;
        #2
        aluop = 5'd30;
        aluin1 = 32'hffffffff;
        aluin2 = 32'h00000003;
        #2
        aluop = 5'd30;
        aluin1 = 32'h80000000;
        aluin2 = 32'hffffffff;
        #2
        //or
        aluop = 5'd6;
        aluin1 = 32'd5;
        aluin2 = 32'd5;
        #2
        aluop = 5'd6;
        aluin1 = 32'd5;
        aluin2 = 32'd3;
        #2
        aluop = 5'd6;
        aluin1 = 32'd5;
        aluin2 = 32'd0;
        #2
        aluop = 5'd6;
        aluin1 = 32'd5;
        aluin2 = 32'hffffffff;
        #2
        //and
        aluop = 5'd7;
        aluin1 = 32'd5;
        aluin2 = 32'd5;
        #2
        aluop = 5'd7;
        aluin1 = 32'd5;
        aluin2 = 32'd3;
        #2
        aluop = 5'd7;
        aluin1 = 32'd5;
        aluin2 = 32'd0;
        #2
        aluop = 5'd7;
        aluin1 = 32'd5;
        aluin2 = 32'hffffffff;
        #2
        //xor
        aluop = 5'd3;
        aluin1 = 32'd5;
        aluin2 = 32'd5;
        #2
        aluop = 5'd3;
        aluin1 = 32'd5;
        aluin2 = 32'd3;
        #2
        aluop = 5'd3;
        aluin1 = 32'd5;
        aluin2 = 32'd0;
        #2
        aluop = 5'd3;
        aluin1 = 32'd5;
        aluin2 = 32'hffffffff;
        #2
        //srl
        aluop = 5'd4;
        aluin1 = 32'd8;
        aluin2 = 32'd1;
        #2
        aluop = 5'd4;
        aluin1 = 32'd8;
        aluin2 = 32'd3;
        #2
        aluop = 5'd4;
        aluin1 = 32'd8;
        aluin2 = 32'd0;
        #2
        aluop = 5'd4;
        aluin1 = 32'd8;
        aluin2 = 32'd32;
        #2
        //sra
        aluop = 5'd5;
        aluin1 = 32'd8;
        aluin2 = 32'd1;
        #2
        aluop = 5'd5;
        aluin1 = -32'd8;
        aluin2 = 32'd1;
        #2
        aluop = 5'd5;
        aluin1 = -32'd8;
        aluin2 = 32'd0;
        #2
        aluop = 5'd5;
        aluin1 = -32'd8;
        aluin2 = 32'd32;
        #2
        // �ùķ��̼� ����
        $finish;
    end

endmodule
