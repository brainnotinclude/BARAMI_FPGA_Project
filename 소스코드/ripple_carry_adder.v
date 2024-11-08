`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/15 10:40:44
// Design Name: 
// Module Name: ripple_carry_adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ripple_carry_adder(
  input		[31:0] 	a,
  input		[31:0] 	b,
	input 					cin,
	output	[31:0] 	sum,
	output 					cout
);

	wire [31:0] ctmp;
	assign cout = ctmp[31];

	full_adder bit31 (.a(a[31]), .b(b[31]), .c_in(ctmp[30]), .sum(sum[31]), .c_out(ctmp[31]));
	full_adder bit30 (.a(a[30]), .b(b[30]), .c_in(ctmp[29]), .sum(sum[30]), .c_out(ctmp[30]));
	full_adder bit29 (.a(a[29]), .b(b[29]), .c_in(ctmp[28]), .sum(sum[29]), .c_out(ctmp[29]));
	full_adder bit28 (.a(a[28]), .b(b[28]), .c_in(ctmp[27]), .sum(sum[28]), .c_out(ctmp[28]));
	full_adder bit27 (.a(a[27]), .b(b[27]), .c_in(ctmp[26]), .sum(sum[27]), .c_out(ctmp[27]));
	full_adder bit26 (.a(a[26]), .b(b[26]), .c_in(ctmp[25]), .sum(sum[26]), .c_out(ctmp[26]));
	full_adder bit25 (.a(a[25]), .b(b[25]), .c_in(ctmp[24]), .sum(sum[25]), .c_out(ctmp[25]));
	full_adder bit24 (.a(a[24]), .b(b[24]), .c_in(ctmp[23]), .sum(sum[24]), .c_out(ctmp[24]));
	full_adder bit23 (.a(a[23]), .b(b[23]), .c_in(ctmp[22]), .sum(sum[23]), .c_out(ctmp[23]));
	full_adder bit22 (.a(a[22]), .b(b[22]), .c_in(ctmp[21]), .sum(sum[22]), .c_out(ctmp[22]));
	full_adder bit21 (.a(a[21]), .b(b[21]), .c_in(ctmp[20]), .sum(sum[21]), .c_out(ctmp[21]));
	full_adder bit20 (.a(a[20]), .b(b[20]), .c_in(ctmp[19]), .sum(sum[20]), .c_out(ctmp[20]));
	full_adder bit19 (.a(a[19]), .b(b[19]), .c_in(ctmp[18]), .sum(sum[19]), .c_out(ctmp[19]));
	full_adder bit18 (.a(a[18]), .b(b[18]), .c_in(ctmp[17]), .sum(sum[18]), .c_out(ctmp[18]));
	full_adder bit17 (.a(a[17]), .b(b[17]), .c_in(ctmp[16]), .sum(sum[17]), .c_out(ctmp[17]));
	full_adder bit16 (.a(a[16]), .b(b[16]), .c_in(ctmp[15]), .sum(sum[16]), .c_out(ctmp[16]));
  full_adder bit15 (.a(a[15]), .b(b[15]), .c_in(ctmp[14]), .sum(sum[15]), .c_out(ctmp[15]));
	full_adder bit14 (.a(a[14]), .b(b[14]), .c_in(ctmp[13]), .sum(sum[14]), .c_out(ctmp[14]));
	full_adder bit13 (.a(a[13]), .b(b[13]), .c_in(ctmp[12]), .sum(sum[13]), .c_out(ctmp[13]));
	full_adder bit12 (.a(a[12]), .b(b[12]), .c_in(ctmp[11]), .sum(sum[12]), .c_out(ctmp[12]));
	full_adder bit11 (.a(a[11]), .b(b[11]), .c_in(ctmp[10]), .sum(sum[11]), .c_out(ctmp[11]));
	full_adder bit10 (.a(a[10]), .b(b[10]), .c_in(ctmp[9]),  .sum(sum[10]), .c_out(ctmp[10]));
	full_adder bit9  (.a(a[9]),  .b(b[9]),  .c_in(ctmp[8]),  .sum(sum[9]),  .c_out(ctmp[9]));
	full_adder bit8  (.a(a[8]),  .b(b[8]),  .c_in(ctmp[7]),  .sum(sum[8]),  .c_out(ctmp[8]));
	full_adder bit7  (.a(a[7]),  .b(b[7]),  .c_in(ctmp[6]),  .sum(sum[7]),  .c_out(ctmp[7]));
	full_adder bit6  (.a(a[6]),  .b(b[6]),  .c_in(ctmp[5]),  .sum(sum[6]),  .c_out(ctmp[6]));
	full_adder bit5  (.a(a[5]),  .b(b[5]),  .c_in(ctmp[4]),  .sum(sum[5]),  .c_out(ctmp[5]));
	full_adder bit4  (.a(a[4]),  .b(b[4]),  .c_in(ctmp[3]),  .sum(sum[4]),  .c_out(ctmp[4]));
	full_adder bit3  (.a(a[3]),  .b(b[3]),  .c_in(ctmp[2]),  .sum(sum[3]),  .c_out(ctmp[3]));
	full_adder bit2  (.a(a[2]),  .b(b[2]),  .c_in(ctmp[1]),  .sum(sum[2]),  .c_out(ctmp[2]));
	full_adder bit1  (.a(a[1]),  .b(b[1]),  .c_in(ctmp[0]),  .sum(sum[1]),  .c_out(ctmp[1]));
	full_adder bit0  (.a(a[0]),  .b(b[0]),  .c_in(cin),      .sum(sum[0]),  .c_out(ctmp[0]));

endmodule
