`timescale 1ns/1ps
module control(
    input [6:0]opcode_A,
    input [2:0]funct3_A,
    input [6:0]funct7_A,
    input [6:0]opcode_B,
    input [2:0]funct3_B,
    input [6:0]funct7_B,
    //input clk,
    //input rst_n,
    
    output reg [4:0]aluop_A,
    output reg [1:0]aluin1_mux,          //mux 00 -> rs1, 01 -> pc, 10 -> 0 for lui
    output reg [4:0]aluop_B,
    output reg [1:0]aluin2_mux           //mux 00 -> rs2, 01 -> shamt 10-> imm_12 11->imm_20
    );
    
    
    
    always@(*) begin
    case(opcode_A) 
        7'b0110011:
        begin
        aluin1_mux = 2'b00;
        // 공통된 control 신호 넣기
        case(funct3_A)                         // add, sub 등 r형 명령어에 대한 aluop 값
            3'b000:
            begin
            aluop_A = (funct7_A == 7'b0100000 ? 5'b00001 : 5'b00000);
            end
            3'b001:
            begin
            aluop_A = 5'b00010;
            end
            3'b010:
            begin
            aluop_A = 5'b01000;
            end
            3'b011:
            begin
            aluop_A = 5'b01000;
            end
            3'b100:
            begin
            aluop_A = 5'b00011;
            end
            3'b101:
            begin
            aluop_A = (funct7_A == 7'b0100000 ? 5'b00100: 5'b00101);
            end
            3'b110:
            begin
            aluop_A = 5'b00110;
            end
            3'b111:
            begin
            aluop_A = 5'b00111;
            end
        endcase
        end
        
        7'b0010011:
        begin 
        aluin1_mux = 2'b00;
        case(funct3_A)                         // addi, subi 등 i형 명령어에 대한 aluop 값
            3'b000:
            begin
            aluop_A = 5'b00000;
            end
            3'b001:
            begin
            aluop_A = 5'b00010;
            end
            3'b010:
            begin
            aluop_A = 5'b01000;
            end
            3'b011:
            begin
            aluop_A = 5'b01000;
            end
            3'b100:
            begin
            aluop_A = 5'b00011;
            end
            3'b101:
            begin
            aluop_A = (funct7_A == 7'b0100000 ? 5'b00101: 5'b00100);
            end
            3'b110:
            begin
            aluop_A = 5'b00110;
            end
            3'b111:
            begin
            aluop_A = 5'b00111;
            end
        endcase
        end
                
        7'b0110111:
        begin                //lui
        aluop_A = 5'b00000;
        aluin1_mux = 2'b10;   
        end
        
        7'b0010111:
        begin                 //auipc
        aluop_A = 5'b00000;
        aluin1_mux = 2'b01;
        end
        
        7'b0110011:
        begin
        aluin1_mux = 2'b00;
        case(funct3_A)                // mul divide
            3'b000:
            begin
            aluop_A = 5'b10110;
            end
            3'b001:
            begin
            aluop_A = 5'b10010;
            end
            3'b010:
            begin
            aluop_A = 5'b10001;
            end
            3'b011:
            begin
            aluop_A = 5'b10000;
            end
            3'b100:
            begin
            aluop_A = 5'b11000;
            end
            3'b101:
            begin
            aluop_A = 5'b11010;
            end
            3'b110:
            begin
            aluop_A = 5'b11100;
            end
            3'b111:
            begin
            aluop_A = 5'b11110;
            end
        endcase
        end
    endcase
    end
    
    // 명령어 두 개니까 둘 나눠서 동시에? 음 같은 always에 둬야할까요
    
    always@(*) begin
    case(opcode_B) 
        7'b0110011:
        begin
        aluin2_mux = 2'b00;
        // 공통된 control 신호 넣기
        case(funct3_B)                         // add, sub 등 r형 명령어에 대한 aluop 값
            3'b000:
            begin
            aluop_B = (funct7_B == 7'b0100000 ? 5'b00001 : 5'b00000);
            end
            3'b001:
            begin
            aluop_B = 5'b00010;
            end
            3'b010:
            begin
            aluop_B = 5'b01000;
            end
            3'b011:
            begin
            aluop_B = 5'b01000;
            end
            3'b100:
            begin
            aluop_B = 5'b00011;
            end
            3'b101:
            begin
            aluop_B = (funct7_B == 7'b0100000 ? 5'b00100: 5'b00101);
            end
            3'b110:
            begin
            aluop_B = 5'b00110;
            end
            3'b111:
            begin
            aluop_B = 5'b00111;
            end
        endcase
        end
        
        7'b0010011:
        begin 
        case(funct3_B)                         // addi, subi 등 i형 명령어에 대한 aluop 값
            3'b000:
            begin
            aluop_B = 5'b00000;
            aluin2_mux = 2'b10;
            end
            3'b001:
            begin
            aluop_B = 5'b00010;
            aluin2_mux = 2'b01;
            end
            3'b010:
            begin
            aluop_B = 5'b01000;
            aluin2_mux = 2'b10;
            end
            3'b011:
            begin
            aluop_B = 5'b01000;
            aluin2_mux = 2'b10;
            end
            3'b100:
            begin
            aluop_B = 5'b00011;
            aluin2_mux = 2'b10;
            end
            3'b101:
            begin
            aluop_B = (funct7_B == 7'b0100000 ? 5'b00101: 5'b00100);
            aluin2_mux = 2'b01;
            end
            3'b110:
            begin
            aluop_B = 5'b00110;
            aluin2_mux = 2'b10;
            end
            3'b111:
            begin
            aluop_B = 5'b00111;
            aluin2_mux = 2'b10;
            end
        endcase
        end
                
        7'b0110111:
        begin                //lui
        aluop_B = 5'b00000;
        aluin2_mux = 2'b11;   
        end
        
        7'b0010111:
        begin                 //auipc
        aluop_B = 5'b00000;
        aluin2_mux = 2'b11;
        end
        
        7'b0110011:
        begin
        aluin2_mux = 2'b00;
        case(funct3_B)                // mul divide
            3'b000:
            begin
            aluop_B = 5'b10110;
            end
            3'b001:
            begin
            aluop_B = 5'b10010;
            end
            3'b010:
            begin
            aluop_B = 5'b10001;
            end
            3'b011:
            begin
            aluop_B = 5'b10000;
            end
            3'b100:
            begin
            aluop_B = 5'b11000;
            end
            3'b101:
            begin
            aluop_B = 5'b11010;
            end
            3'b110:
            begin
            aluop_B = 5'b11100;
            end
            3'b111:
            begin
            aluop_B = 5'b11110;
            end
        endcase
        end
    endcase
    end
    
    
   
endmodule