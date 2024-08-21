module decoder_tb();

    reg clk;
    reg rst_n;
    reg [31:0] instA;                 
    reg [31:0] instB;              
    reg [31:0] pc;
    
    reg [31:0] rs1_ex_forwarding_A;
    reg [31:0] rs2_ex_forwarding_A;
    reg [31:0] rs1_mem_forwarding_A;
    reg [31:0] rs2_mem_forwarding_A;
    reg [1:0] rs1_forwarding_bit_A;
    reg [1:0] rs2_forwarding_bit_A;
    
    reg [31:0] rs1_ex_forwarding_B;
    reg [31:0] rs2_ex_forwarding_B;
    reg [31:0] rs1_mem_forwarding_B;
    reg [31:0] rs2_mem_forwarding_B;
    reg [1:0] rs1_forwarding_bit_B;
    reg [1:0] rs2_forwarding_bit_B;
    
    reg [4:0] wraddrA;
    reg [4:0] wraddrB;
    reg [31:0] writeDataA;
    reg [31:0] writeDataB;
    reg updateEnA;
    reg updateEnB;
    reg [4:0] updateAddrA;
    reg [4:0] updateAddrB;
    reg wr_enable_A;
    reg wr_enable_B;
    
    wire [82:0] decoded_instA;              
    wire [82:0] decoded_instB;
    wire errorA;                      
    wire errorB;
    
    decoder_RF_conv u_decoder_RF_conv(
    .clk(clk),
.rst_n(rst_n),
.instA(instA),                 
.instB(instB),              
.pc(pc),

.rs1_ex_forwarding_A(rs1_ex_forwarding_A),
.rs2_ex_forwarding_A(rs2_ex_forwarding_A),
.rs1_mem_forwarding_A(rs1_mem_forwarding_A),
.rs2_mem_forwarding_A(rs2_mem_forwarding_A),
.rs1_forwarding_bit_A(rs1_forwarding_bit_A),
.rs2_forwarding_bit_A(rs2_forwarding_bit_A),

.rs1_ex_forwarding_B(rs1_ex_forwarding_B),
.rs2_ex_forwarding_B(rs2_ex_forwarding_B),
.rs1_mem_forwarding_B(rs1_mem_forwarding_B),
.rs2_mem_forwarding_B(rs2_mem_forwarding_B),
.rs1_forwarding_bit_B(rs1_forwarding_bit_B),
.rs2_forwarding_bit_B(rs2_forwarding_bit_B),

.decoded_instA(decoded_instA),              
.decoded_instB(decoded_instB),
.errorA(errorA),                      
.errorB(errorB),

.wraddrA(wraddrA),
.wraddrB(wraddrB),
.writeDataA(writeDataA),
.writeDataB(writeDataB),
.updateEnA(updateEnA),
.updateEnB(updateEnB),
.updateAddrA(updateAddrA),
.updateAddrB(updateAddrB),
.wr_enable_A(wr_enable_A),
.wr_enable_B(wr_enable_B)
 );


always begin 
#5
clk = ~clk;
end
 
initial begin
clk = 0;
rst_n = 0;
#10 rst_n = 1;
#5 rst_n = 0;

instA = 32'b0;                 
instB = 32'b0;              
pc = 32'b0;

rs1_ex_forwarding_A = 32'b0;
rs2_ex_forwarding_A = 32'b0;
rs1_mem_forwarding_A = 32'b0;
rs2_mem_forwarding_A = 32'b0;
rs1_forwarding_bit_A = 2'b0;
rs2_forwarding_bit_A = 2'b0;

rs1_ex_forwarding_B = 32'b0;
rs2_ex_forwarding_B = 32'b0;
rs1_mem_forwarding_B = 32'b0;
rs2_mem_forwarding_B = 32'b0;
rs1_forwarding_bit_B = 2'b0;
rs2_forwarding_bit_B = 2'b0;

wraddrA = 5'b0;
wraddrB = 5'b0;
writeDataA = 32'b0;
writeDataB = 32'b0;
updateEnA = 1'b0;
updateEnB = 1'b0;
updateAddrA = 5'b0;
updateAddrB = 5'b0;
wr_enable_A = 1'b0;
wr_enable_B = 1'b0;

#5 rst_n = 1;

#5 
instA = 32'b00010010001100000000000010010011;                 
instB = 32'b00000000001100000011000010010011;              
pc = 32'h0001_0000;

wraddrA = 5'b0;
wraddrB = 5'b0;
writeDataA = 32'b0;
writeDataB = 32'b0;
updateEnA = 1'b0;
updateEnB = 1'b0;
updateAddrA = 5'b0;
updateAddrB = 5'b0;
wr_enable_A = 1'b0;
wr_enable_B = 1'b0;

#10 
instA = 32'b00000000011000000000000010010011;                 
instB = 32'b00000000001000001000000110110011;              
pc = 32'h0001_0004;

wraddrA = 5'b0;
wraddrB = 5'b0;
writeDataA = 32'b0;
writeDataB = 32'b0;
updateEnA = 1'b0;
updateEnB = 1'b0;
updateAddrA = 5'b0;
updateAddrB = 5'b0;
wr_enable_A = 1'b0;
wr_enable_B = 1'b0;

#10 
instA = 32'b01000000001000011010001010110011;                 
instB = 32'b00000000001000001001000010110011;              
pc = 32'h0001_0008;

wraddrA = 5'b0;
wraddrB = 5'b0;
writeDataA = 32'b0;
writeDataB = 32'b0;
updateEnA = 1'b0;
updateEnB = 1'b0;
updateAddrA = 5'b0;
updateAddrB = 5'b0;
wr_enable_A = 1'b0;
wr_enable_B = 1'b0;


#20 
$finish;

end
endmodule




