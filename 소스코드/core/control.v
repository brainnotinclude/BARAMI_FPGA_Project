`timescale 1ns/1ps
module control(
    input [6:0]opcode_A,
    input [2:0]funct3_A,
    input [6:0]funct7_A,
    input ebreak,
    /*input [6:0]opcode_B,
    input [2:0]funct3_B,
    input [6:0]funct7_B,
    //input clk,
    //input rst_n,
    */
    output reg [5:0]aluop_A,
    output reg [1:0]aluin1_mux,          //mux 00 -> rs1, 01 -> pc, 10 -> 0 for lui
    //output reg [4:0]aluop_B,
    output reg [1:0]aluin2_mux,           //mux 00 -> rs2, 01 -> shamt 10-> imm_12 11->imm_20
    output reg map_en,
    output reg [1:0] dispatch_control,     //11: Both simple/complex, 01: Complex only, 10:FP only
    output reg memwrite,
    output reg memread,
    output reg memtoreg,
    output reg branch,
    output reg regwrite,
    output reg jump,
    output reg fp,
    output reg fence,
    output reg ebreak_out,
    output reg ecall
    );
    reg [4:0] funct5;
    
    
    always@(*) begin
    funct5 = funct7_A[6:2];
    case(opcode_A) 
        7'b0110011:
        begin
        if (funct7_A != 7'b0000001) begin
        aluin1_mux = 2'b00;
        aluin2_mux = 2'b00;
        map_en = 1;
        dispatch_control = 2'b11;
        memwrite = 0;
        memread = 0;
        memtoreg = 0;
        branch = 0;
        regwrite =1;
        jump = 0;
        fp = 0;
        fence = 0;
        // 공통된 control 신호 넣기
        case(funct3_A)                         // add, sub 등 r형 명령어에 대한 aluop 값
            3'b000:
            begin
            aluop_A = (funct7_A == 7'b0100000 ? 6'b00001 : 6'b00000);
            end
            3'b001:
            begin
            aluop_A = 6'b00010;
            end
            3'b010:
            begin
            aluop_A = 6'b01000;
            end
            3'b011:
            begin
            aluop_A = 6'b01001;
            end
            3'b100:
            begin
            aluop_A = 6'b00011;
            end
            3'b101:
            begin
            aluop_A = (funct7_A == 7'b0100000 ? 6'b00100: 6'b00101);
            end
            3'b110:
            begin
            aluop_A = 6'b00110;
            end
            3'b111:
            begin
            aluop_A = 6'b00111;
            end
            
            default:
            begin
            aluop_A= 6'b0;
            aluin1_mux = 2'b0;          
            aluin2_mux = 2'b0;          
            map_en= 0;
            dispatch_control= 2'b0;    
            memwrite= 0;
            memread= 0;
            memtoreg= 0;
            branch= 0;
            regwrite = 0;
            jump = 0;
            fp = 0;
            fence = 0;
        end
        endcase
        end
        
        else begin    // mul divide
        map_en = 1;
        aluin1_mux = 2'b00;
        aluin2_mux = 2'b00; 
        dispatch_control = 2'b11;
        memwrite = 0;
        memread = 0;
        memtoreg = 0;
        branch = 0;
        regwrite =1;
        jump = 0;
        fp = 0;
        fence = 0;
        case(funct3_A)                // mul divide
            3'b000:
            begin
            aluop_A = 6'b10110;
            end
            3'b001:
            begin
            aluop_A = 6'b10010;
            end
            3'b010:
            begin
            aluop_A = 6'b10001;
            end
            3'b011:
            begin
            aluop_A = 6'b10000;
            end
            3'b100:
            begin
            aluop_A = 6'b11000;
            end
            3'b101:
            begin
            aluop_A = 6'b11010;
            end
            3'b110:
            begin
            aluop_A = 6'b11100;
            end
            3'b111:
            begin
            aluop_A = 6'b11110;
            end
            default:
            begin
            aluop_A= 6'b0;
            aluin1_mux = 2'b0;          
            aluin2_mux = 2'b0;          
            map_en= 0;
            dispatch_control= 2'b0;    
            memwrite= 0;
            memread= 0;
            memtoreg= 0;
            branch= 0;
            regwrite = 0;
            jump = 0;
            fp = 0;
            fence = 0;
        end
        endcase
        end
        end
        
        7'b0010011: // i type
        begin 
        aluin1_mux = 2'b00;
        map_en = 1;
        dispatch_control = 2'b11;
        memwrite = 0;
        memread = 0;     
        memtoreg = 0;
        branch = 0;
        regwrite =1;
        jump = 0;
        fp = 0;
        fence = 0;
        case(funct3_A)                         // addi, subi 등 i형 명령어에 대한 aluop 값
            3'b000:
            begin
            aluop_A = 6'b00000;
            aluin2_mux = 2'b10;
            end
            3'b001:
            begin
            aluop_A = 6'b00010;
            aluin2_mux = 2'b01;
            end
            3'b010:
            begin
            aluop_A = 6'b01000;
            aluin2_mux = 2'b10;
            end
            3'b011:
            begin
            aluop_A = 6'b01001;
            aluin2_mux = 2'b10;
            end
            3'b100:
            begin
            aluop_A = 6'b00011;
            aluin2_mux = 2'b10;
            end
            3'b101:
            begin
            aluop_A = (funct7_A == 7'b0100000 ? 6'b00101: 6'b00100);
            aluin2_mux = 2'b01;
            end
            3'b110:
            begin
            aluop_A = 6'b00110;
            aluin2_mux = 2'b10;
            end
            3'b111:
            begin
            aluop_A = 6'b00111;
            aluin2_mux = 2'b10;
            end
            
            default:
            begin
            aluop_A= 6'b0;
            aluin1_mux = 2'b0;          
            aluin2_mux = 2'b0;          
            map_en= 0;
            dispatch_control= 2'b0;    
            memwrite= 0;
            memread= 0;
            memtoreg= 0;
            branch= 0;
            regwrite = 0;
            jump = 0;
            fp = 0;
            fence = 0;
        end
        endcase
        end
                
        7'b0110111:
        begin                //lui
        aluop_A = 6'b00000;
        map_en = 1;
        aluin1_mux = 2'b10;  
        aluin2_mux = 2'b11; 
        dispatch_control = 2'b11;
        memwrite = 0;
        memread = 0;
        memtoreg = 0;
        branch = 0;
        regwrite =1;
        jump = 0;
        fp = 0;
        fence = 0;
        end
        
        7'b0010111:
        begin                 //auipc
        aluop_A = 6'b00000;
        map_en = 1;
        aluin1_mux = 2'b01;
        aluin2_mux = 2'b11;   
        dispatch_control = 2'b11;    
        memwrite = 0;
        memread = 0;
        memtoreg = 0;
        branch = 0;
        regwrite =1;
        jump = 0;
        fp = 0;
        fence = 0;
        
        end
        
        7'b0000011:        // lw 
        begin
        aluop_A= 6'b100000;
        aluin1_mux = 2'b0;          
        aluin2_mux = 2'b10;          
        map_en= 1;
        dispatch_control= 2'b01;    
        memwrite= 0;
        memread= 1;
        memtoreg= 1;
        branch= 0;
        regwrite = 1;
        jump = 0;
        fp = 0;
        fence = 0;
        end
        
        7'b1100111:     // jalr
        begin
        aluop_A= 6'b100001;
        aluin1_mux = 2'b01;          
        aluin2_mux = 2'b10;          
        map_en= 1;
        dispatch_control= 2'b11;    
        memwrite= 0;
        memread= 0;
        memtoreg= 0;
        branch= 0;
        regwrite = 1;
        jump = 1;
        fp = 0;
        fence = 0;
        end
        
        7'b1101111:         // jal
        begin
        aluop_A= 6'b100010;
        aluin1_mux = 2'b01;          
        aluin2_mux = 2'b11;          
        map_en= 1;
        dispatch_control= 2'b11;    
        memwrite= 0;
        memread= 0;
        memtoreg= 0;
        branch= 0;
        regwrite = 1;
        jump = 1;
        fp = 0;
        fence = 0;
        end
        
        7'b0100011: //sw
        begin
        aluop_A= 6'b100011;
        aluin1_mux = 2'b00;          
        aluin2_mux = 2'b10;          
        map_en= 1;
        dispatch_control= 2'b01;    
        memwrite= 1;
        memread= 0;
        memtoreg= 0;
        branch= 0;
        regwrite = 0;
        jump = 0;
        fp = 0;
        fence = 0;
        end
        
        7'b1100011:  //branch 공통
        begin
        aluin1_mux = 2'b00;          
        aluin2_mux = 2'b00;          
        map_en= 1;
        dispatch_control= 2'b01;    
        memwrite= 0;
        memread= 0;
        memtoreg= 0;
        branch= 1;
        regwrite = 0;
        jump = 0;
        fp = 0;
        fence = 0;
        
        case(funct3_A)
        3'b000: 
        aluop_A = 6'b101000;     //beq
        3'b001: 
        aluop_A = 6'b101001;     //bne
        3'b100: 
        aluop_A = 6'b101010;     // blt 
        3'b101: 
        aluop_A = 6'b101011;     //bge
        3'b110: 
        aluop_A = 6'b101100;     // bltu
        3'b111: 
        aluop_A = 6'b101101;    //bgeu
        default: 
        begin
            aluop_A= 6'b0;
            aluin1_mux = 2'b0;          
            aluin2_mux = 2'b0;          
            map_en= 0;
            dispatch_control= 2'b0;    
            memwrite= 0;
            memread= 0;
            memtoreg= 0;
            branch= 0;
            regwrite = 0;
            jump = 0;
            fp = 0;
            fence = 0;
        end
        endcase
        end
         
        7'b1010011:            //fp
        begin
            aluin1_mux = 2'b0;          
            aluin2_mux = 2'b0;          
            map_en= 1;
            dispatch_control= 2'b10;    
            memwrite= 0;
            memread= 0;
            memtoreg= 0;
            branch= 0;
            regwrite = 1;
            jump = 0;
            fp = 1;
            fence = 0;
            case(funct7_A)
            7'b0000000: 
            aluop_A = 6'b110100;
            7'b0000100: 
            aluop_A = 6'b110101;
            7'b0001000: 
            aluop_A = 6'b110110;
            7'b0001100: 
            aluop_A = 6'b110111;
            7'b0010100: 
            aluop_A = (funct3_A == 3'b000) ? 6'b111000 : 6'b111001;
            7'b1110000: 
            aluop_A = 6'b111010;
            7'b1111000: 
            aluop_A = 6'b111011;
            default:
            begin
            aluop_A= 6'b0;
            aluin1_mux = 2'b0;          
            aluin2_mux = 2'b0;          
            map_en= 0;
            dispatch_control= 2'b0;    
            memwrite= 0;
            memread= 0;
            memtoreg= 0;
            branch= 0;
            regwrite = 0;
            jump = 0;
            fp = 0;
            fence = 0;
            end
            endcase
        end
        
        /* atomic 7'b0101111:
        begin 
        case(funct5)
        5'b00001: 
        begin
        aluop_A= 6'b100100;
        aluin1_mux = 2'b00;          
        aluin2_mux = 2'b00;          
        map_en= 0;
        dispatch_control= 2'b01;    
        memwrite= 1;
        memread= 0;
        memtoreg= 1;
        branch= 0;
        regwrite = 1;
        jump = 0;
        fp = 0;
        fence = 0;
        end 
        5'b00010:
        begin 
        aluop_A= 6'b100101;
        aluin1_mux = 2'b0;          
        aluin2_mux = 2'b0;          
        map_en= 1;
        dispatch_control= 2'b01;    
        memwrite= 0;
        memread= 1;
        memtoreg= 1;
        branch= 0;
        regwrite = 1;
        jump = 0;
        fp = 0;
            fence = 0;
        end 
        5'b00011:
        begin 
        aluop_A= 6'b100110;
        aluin1_mux = 2'b0;          
        aluin2_mux = 2'b0;          
        map_en= 1;
        dispatch_control= 2'b01;    
        memwrite= 1;
        memread= 0;
        memtoreg= 0;
        branch= 0;
        regwrite = 0;
        jump = 0;
        fp = 0;
            fence = 0;
        end
        endcase
        end
        */
        
        7'b1110011:     //csr
        begin 
        aluin1_mux = 2'b0;          
        aluin2_mux = 2'b10;          
        map_en= 0;
        dispatch_control= 2'b01;    
        memwrite= 0;
        memread= 0;
        memtoreg= 0;
        branch= 0;
        regwrite = 1;
        jump = 0;
        fp = 0;
        fence = 0;
        case(funct3_A)
        3'b001: 
        aluop_A = 6'b110000;
        3'b010:
        aluop_A = 6'b110001;
        3'b011:
        aluop_A = 6'b110010;
        default:
        begin
        aluop_A= 6'b0;
        aluin1_mux = 2'b0;          
        aluin2_mux = 2'b0;          
        map_en= 0;
        dispatch_control= 2'b0;    
        memwrite= 0;
        memread= 0;
        memtoreg= 0;
        branch= 0;
        regwrite = 0;
        jump = 0;
        fp = 0;
        fence = 0;
        end
        endcase 
        end
        
        7'b0001111: begin        //fence.i
        aluop_A= 6'b0;
        aluin1_mux = 2'b0;          
        aluin2_mux = 2'b0;          
        map_en= 0;
        dispatch_control= 2'b0;    
        memwrite= 0;
        memread= 0;
        memtoreg= 0;
        branch= 0;
        regwrite = 0;
        jump = 0;
        fp = 0;
        fence = 1;
        end
        
        7'b1110011:
        begin
        ebreak_out = ebreak ? 1 : 0;
        ecall = ebreak ? 0 : 1;
        end 
        
        default: begin
        aluop_A= 6'b0;
        aluin1_mux = 2'b0;          
        aluin2_mux = 2'b0;          
        map_en= 0;
        dispatch_control= 2'b0;    
        memwrite= 0;
        memread= 0;
        memtoreg= 0;
        branch= 0;
        regwrite = 0;
        jump = 0;
        fp = 0;
            fence = 0;
        end
    endcase
    end
    
    
   
endmodule