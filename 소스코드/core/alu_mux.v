module alu_mux(
    input [1:0]mux1,           //control signal
    input [1:0]mux2,
    input [31:0]rs1,            //rs1 data value
    input [31:0]rs2, 
    input [31:0]pc,             // pc value for auipc
    input [11:0]imm,            // imm for i type inst 
    input [4:0]shamt,           // shamt bit for shift
    input [19:0]imm_20,         // imm for lui, auipc
    
    output reg [31:0] aluin1,       // aluin value 
    output reg [31:0] aluin2
    );
    
    wire [31:0]sign_imm;
    wire [31:0]sign_imm_20;
    assign sign_imm = {20*{imm[11]},imm};
    assign sign_imm_20 = {imm_20, 12'b0};
    
    wire [31:0]shamt_temp;
    assign shamt_temp = {27'b0, shamt};
   
    
    always @(*) begin
    case(mux1)
        2'b00: aluin1 = rs1;
        2'b01: aluin1 = pc;
        2'b10: aluin1 = 32'b0;
    endcase
    
    case(mux2) 
        2'b00: aluin2 = rs2;
        2'b01: aluin2 = shamt_temp;
        2'b10: aluin2 = sign_imm;
        2'b11: aluin2 = sign_imm_20;
    endcase
    end
endmodule
    