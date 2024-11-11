// 입력된 문자열을 공백을 기준으로 나눠서 각각의 부분(명령어, 레지스터 등)으로 구분하고 기계어로 변환한다
#include "FileOpenAPI.h"
#include "translate_2.h"
#include <iostream>
#include <sstream>
#include <vector>
#include <regex>
#include <string>
#include <iomanip>
#include <bitset>

// 명령어 처리 함수
void processCommand2(const std::string& command) {
    std::istringstream ss(command);
    std::string instruction, arg1, arg2, arg3;
    ss >> instruction >> arg3 >> arg1 >> arg2;

    // Determine if arg1 is a register or a number/variable
    int value1 = getValue(arg1);
    int value2 = getValue(arg2);
    int value3 = getValue(arg3);
    int destIndex = getRegisterIndex(arg3);

    if (instruction == "mov") {
        registers[getRegisterIndex(arg2)] = value1;
        output_translate_2 << "mov: " << arg2 << " = " << registers[getRegisterIndex(arg2)] << "\n" << std::endl;
        return;
    } 
    else if (instruction == "add") {
        int reg2Value = getValue(arg2);
        registers[getRegisterIndex(arg3)] = value1 + reg2Value;
        output_translate_2 << "ADD: " << arg3 << " = " << registers[getRegisterIndex(arg3)] << std::endl;
        output_translate_2 << "Result: " << "0110011" << std::bitset<5>(value3) << "000" << std::bitset<5>(value1) << "" << std::bitset<5>(value2) << "0000000\n" << std::endl;
        return;
    }
    else if (instruction == "sub") {
        int reg2Value = getValue(arg2);
        registers[getRegisterIndex(arg3)] = value1 - reg2Value;
        output_translate_2 << "SUB: " << arg3 << " = " << registers[getRegisterIndex(arg3)] << std::endl;
        output_translate_2 << "Result: " << "0110011" << std::bitset<5>(value3) << "000" << std::bitset<5>(value1) << "" << std::bitset<5>(value2) << "0100000\n" << std::endl;
        return;
    }
    else if (instruction == "and") {
        registers[destIndex] = value1 & value2;
        output_translate_2 << "AND: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0110011" << std::bitset<5>(value3) << "111" << std::bitset<5>(value1) << "" << std::bitset<5>(value2) << "0000000\n" << std::endl;
    }
    else if (instruction == "or") {
        registers[destIndex] = value1 | value2;
        output_translate_2 << "OR: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0110011" << std::bitset<5>(value3) << "110" << std::bitset<5>(value1) << "" << std::bitset<5>(value2) << "0000000\n" << std::endl;
    }
    else if (instruction == "xor") {
        registers[destIndex] = value1 ^ value2;
        output_translate_2 << "XOR: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0110011" << std::bitset<5>(value3) << "100" << std::bitset<5>(value1) << "" << std::bitset<5>(value2) << "0000000\n" << std::endl;
    }
    else if (instruction == "sll") {
        registers[destIndex] = value1 << value2;
        output_translate_2 << "SLL: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0110011" << std::bitset<5>(value3) << "001" << std::bitset<5>(value1) << "" << std::bitset<5>(value2) << "0000000\n" << std::endl;
    }
    else if (instruction == "srl") {
        registers[destIndex] = static_cast<unsigned int>(value1) >> value2;
        output_translate_2 << "SRL: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0110011" << std::bitset<5>(value3) << "101" << std::bitset<5>(value1) << "" << std::bitset<5>(value2) << "0000000\n" << std::endl;
    }
    else if (instruction == "sra") {
        registers[destIndex] = value1 >> value2;
        output_translate_2 << "SRA: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0110011" << std::bitset<5>(value3) << "101" << std::bitset<5>(value1) << "" << std::bitset<5>(value2) << "0100000\n" << std::endl;
    }
    else if (instruction == "slt") {
        registers[destIndex] = (value1 < value2) ? 1 : 0;
        output_translate_2 << "SLT: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0110011" << std::bitset<5>(value3) << "010" << std::bitset<5>(value1) << "" << std::bitset<5>(value2) << "0000000\n" << std::endl;
    }
    else if (instruction == "sltu") {
        registers[destIndex] = (static_cast<unsigned int>(value1) < static_cast<unsigned int>(value2)) ? 1 : 0;
        output_translate_2 << "SLTU: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0110011" << std::bitset<5>(value3) << "011" << std::bitset<5>(value1) << "" << std::bitset<5>(value2) << "0000000\n" << std::endl;
    }
    else if (instruction == "addi") {
        int imm = parseNumber(arg2);  // Immediate value
        registers[destIndex] = value1 + imm;
        output_translate_2 << "ADDI: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0010011" << std::bitset<5>(value3) << "000" << std::bitset<5>(value1) << "" << std::bitset<12>(imm) << "\n" << std::endl;
    }
    else if (instruction == "andi") {
        int imm = parseNumber(arg2);
        registers[destIndex] = value1 & imm;
        output_translate_2 << "ANDI: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0010011" << std::bitset<5>(value3) << "111" << std::bitset<5>(value1) << "" << std::bitset<12>(imm) << "\n" << std::endl;
    }
    else if (instruction == "ori") {
        int imm = parseNumber(arg2);
        registers[destIndex] = value1 | imm;
        output_translate_2 << "ORI: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0010011" << std::bitset<5>(value3) << "110" << std::bitset<5>(value1) << "" << std::bitset<12>(imm) << "\n" << std::endl;
    }
    else if (instruction == "xori") {
        int imm = parseNumber(arg2);
        registers[destIndex] = value1 ^ imm;
        output_translate_2 << "XORI: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0010011" << std::bitset<5>(value3) << "100" << std::bitset<5>(value1) << "" << std::bitset<12>(imm) << "\n" << std::endl;
    }
    else if (instruction == "slli") {
        int imm = parseNumber(arg2);
        registers[destIndex] = value1 << imm;
        output_translate_2 << "SLLI: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0010011" << std::bitset<5>(value3) << "001" << std::bitset<5>(value1) << "" << std::bitset<5>(imm) << "0000000\n" << std::endl;
    }
    else if (instruction == "srli") {
        int imm = parseNumber(arg2);
        registers[destIndex] = static_cast<unsigned int>(value1) >> imm;
        output_translate_2 << "SRLI: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0010011" << std::bitset<5>(value3) << "101" << std::bitset<5>(value1) << "" << std::bitset<5>(imm) << "0000000\n" << std::endl;
    }
    else if (instruction == "srai") {
        int imm = parseNumber(arg2);
        registers[destIndex] = value1 >> imm;
        output_translate_2 << "SRAI: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0010011" << std::bitset<5>(value3) << "101" << std::bitset<5>(value1) << "" << std::bitset<5>(imm) << "0100000\n" << std::endl;
    }
    else if (instruction == "slti") {
        int imm = parseNumber(arg2);
        registers[destIndex] = (value1 < imm) ? 1 : 0;
        output_translate_2 << "SLTI: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0010011" << std::bitset<5>(value3) << "010" << std::bitset<5>(value1) << "" << std::bitset<12>(imm) << "\n" << std::endl;
    }
    else if (instruction == "sltiu") { // sltiu에서 얻은 언사인드 값이 bitset 통과할 때는 어찌되는지?
        int imm = parseNumber(arg2);
        registers[destIndex] = (static_cast<unsigned int>(value1) < static_cast<unsigned int>(imm)) ? 1 : 0;
        output_translate_2 << "SLTIU: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0010011" << std::bitset<5>(value3) << "011" << std::bitset<5>(value1) << "" << std::bitset<12>(imm) << "\n" << std::endl;
    }
    else if (instruction == "lw") {
        int offset = parseNumber(arg2);
        int baseRegisterIndex = getRegisterIndex(arg3);
        //registers[destIndex] = memory[registers[baseRegisterIndex] + offset];
        output_translate_2 << "LW: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0000011" << std::bitset<5>(value3) << "010" << std::bitset<5>(value1) << "" << std::bitset<12>(offset) << "\n" << std::endl;
    }
    else if (instruction == "jalr") {
        int offset = parseNumber(arg2);
        int baseRegisterIndex = getRegisterIndex(arg3);
        registers[destIndex] = registers[baseRegisterIndex] + offset;
        output_translate_2 << "JALR: " << arg1 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "1100111" << std::bitset<5>(value3) << "000" << std::bitset<5>(value1) << "" << std::bitset<12>(offset) << "\n" << std::endl;
    }
    else if (instruction == "beq") {
        if (value1 == value2) {
            output_translate_2 << "BEQ: Branching if equal" << std::endl;
            output_translate_2 << "Result: " << "1100011" << std::bitset<5>(value1) << "000" << std::bitset<5>(value2) << std::bitset<12>(value3) << "\n" << std::endl;
        }
    }
    else if (instruction == "bne") {
        if (value1 != value2) {
            output_translate_2 << "BNE: Branching if not equal" << std::endl;
            output_translate_2 << "Result: " << "1100011" << std::bitset<5>(value1) << "001" << std::bitset<5>(value2) << std::bitset<12>(value3) << "\n" << std::endl;
        }
    }
    else if (instruction == "bge") {
        if (value1 >= value2) {
            output_translate_2 << "BGE: Branching if greater than or equal" << std::endl;
            output_translate_2 << "Result: " << "1100011" << std::bitset<5>(value1) << "101" << std::bitset<5>(value2) << std::bitset<12>(value3) << "\n" << std::endl;
        }
    }
    else if (instruction == "bgeu") {
        if (static_cast<unsigned int>(value1) >= static_cast<unsigned int>(value2)) {
            output_translate_2 << "BGEU: Branching if greater than or equal unsigned" << std::endl;
            output_translate_2 << "Result: " << "1100011" << std::bitset<5>(value1) << "111" << std::bitset<5>(value2) << std::bitset<12>(value3) << "\n" << std::endl;
        }
    }
    else if (instruction == "blt") {
        if (value1 < value2) {
            output_translate_2 << "BLT: Branching if less than" << std::endl;
            output_translate_2 << "Result: " << "1100011" << std::bitset<5>(value1) << "100" << std::bitset<5>(value2) << std::bitset<12>(value3) << "\n" << std::endl;
        }
    }
    else if (instruction == "bltu") {
        if (static_cast<unsigned int>(value1) < static_cast<unsigned int>(value2)) {
            output_translate_2 << "BLTU: Branching if less than unsigned" << std::endl;
            output_translate_2 << "Result: " << "1100011" << std::bitset<5>(value1) << "110" << std::bitset<5>(value2) << std::bitset<12>(value3) << "\n" << std::endl;
        }
    }
    else if (instruction == "lui") {
        int imm = parseNumber(arg1);
        registers[destIndex] = imm << 12;
        output_translate_2 << "LUI: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0110111" << std::bitset<5>(value3) << std::bitset<20>(imm) << "\n" << std::endl;
    }
    else if (instruction == "auipc") {
        int imm = parseNumber(arg2); 
        registers[getRegisterIndex(arg1)] = pc + (imm << 12);
        output_translate_2 << "AUIPC: " << arg1 << " = " << registers[getRegisterIndex(arg1)] << std::endl;
        output_translate_2 << "Result: " << "0010111" << std::bitset<5>(getRegisterIndex(arg1)) << std::bitset<20>(imm) << "\n" << std::endl;
    }
    else if (instruction == "jal") {
        int imm = parseNumber(arg2); 
        registers[getRegisterIndex(arg1)] = pc + 4;
        pc = pc + imm; 
        output_translate_2 << "JAL: " << arg1 << " = " << registers[getRegisterIndex(arg1)] << " (Return Address)" << std::endl;
        output_translate_2 << "PC updated to: " << pc << std::endl;
        output_translate_2 << "Result: " << "1101111" << std::bitset<5>(getRegisterIndex(arg1)) << std::bitset<20>(imm) << "\n" << std::endl;
    }
    else if (instruction == "ecall") {
        output_translate_2 << "ECALL: Environment Call\n" << std::endl;
    }
    else if (instruction == "ebreak") {
        output_translate_2 << "EBREAK: Environment Break\n" << std::endl;
    }
    else if (instruction == "mul") {
        registers[destIndex] = value1 * value2;
        output_translate_2 << "MUL: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0110011" << std::bitset<5>(value3) << "000" << std::bitset<5>(value1) << std::bitset<5>(value2) << "0000001\n" << std::endl;
    }
    else if (instruction == "mulh") {
        registers[destIndex] = ((int64_t)value1 * (int64_t)value2) >> 32;
        output_translate_2 << "MULH: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0110011" << std::bitset<5>(value3) << "001" << std::bitset<5>(value1) << std::bitset<5>(value2) << "0000001\n" << std::endl;
    }
    else if (instruction == "mulhsu") {
        registers[destIndex] = ((int64_t)value1 * (uint64_t)value2) >> 32;
        output_translate_2 << "MULHSU: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0110011" << std::bitset<5>(value3) << "010" << std::bitset<5>(value1) << std::bitset<5>(value2) << "0000001\n" << std::endl;
    }
    else if (instruction == "mulhu") {
        registers[destIndex] = ((uint64_t)value1 * (uint64_t)value2) >> 32;
        output_translate_2 << "MULHU: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0110011" << std::bitset<5>(value3) << "011" << std::bitset<5>(value1) << std::bitset<5>(value2) << "0000001\n" << std::endl;
    }
    else if (instruction == "div") {
        registers[destIndex] = value2 != 0 ? value1 / value2 : 0; // Division by zero check
        output_translate_2 << "DIV: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0110011" << std::bitset<5>(value3) << "100" << std::bitset<5>(value1) << std::bitset<5>(value2) << "0000001\n" << std::endl;
    }
    else if (instruction == "divu") {
        registers[destIndex] = value2 != 0 ? (unsigned)value1 / (unsigned)value2 : 0;
        output_translate_2 << "DIVU: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0110011" << std::bitset<5>(value3) << "101" << std::bitset<5>(value1) << std::bitset<5>(value2) << "0000001\n" << std::endl;
    }
    else if (instruction == "rem") {
        registers[destIndex] = value2 != 0 ? value1 % value2 : 0;
        output_translate_2 << "REM: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0110011" << std::bitset<5>(value3) << "110" << std::bitset<5>(value1) << std::bitset<5>(value2) << "0000001\n" << std::endl;
    }
    else if (instruction == "remu") {
        registers[destIndex] = value2 != 0 ? (unsigned)value1 % (unsigned)value2 : 0;
        output_translate_2 << "REMU: " << arg3 << " = " << registers[destIndex] << std::endl;
        output_translate_2 << "Result: " << "0110011" << std::bitset<5>(value3) << "111" << std::bitset<5>(value1) << std::bitset<5>(value2) << "0000001\n" << std::endl;
    }
    else if (instruction == "fadd.s") {
        float reg2Value = getFloatValue(arg2);
        float reg1Value = getFloatValue(arg1);
        registers[getRegisterIndex(arg3)] = reg1Value + reg2Value;
        output_translate_2 << "FADD.S: " << arg3 << " = " << registers[getRegisterIndex(arg3)] << std::endl;
    }
    else if (instruction == "fsub.s") {
        float reg2Value = getFloatValue(arg2);
        float reg1Value = getFloatValue(arg1);
        registers[getRegisterIndex(arg3)] = reg1Value - reg2Value;
        output_translate_2 << "FSUB.S: " << arg3 << " = " << registers[getRegisterIndex(arg3)] << std::endl;
    }
    else if (instruction == "fmul.s") {
        float reg2Value = getFloatValue(arg2);
        float reg1Value = getFloatValue(arg1);
        registers[getRegisterIndex(arg3)] = reg1Value * reg2Value;
        output_translate_2 << "FMUL.S: " << arg3 << " = " << registers[getRegisterIndex(arg3)] << std::endl;
    }
    else if (instruction == "fdiv.s") {
        float reg2Value = getFloatValue(arg2);
        float reg1Value = getFloatValue(arg1);
        registers[getRegisterIndex(arg3)] = (reg2Value != 0) ? reg1Value / reg2Value : 0; // Division by zero check
        output_translate_2 << "FDIV.S: " << arg3 << " = " << registers[getRegisterIndex(arg3)] << std::endl;
    }
    else if (instruction == "fmin.s") {
        float reg2Value = getFloatValue(arg2);
        float reg1Value = getFloatValue(arg1);
        registers[getRegisterIndex(arg3)] = std::min(reg1Value, reg2Value);
        output_translate_2 << "FMIN.S: " << arg3 << " = " << registers[getRegisterIndex(arg3)] << std::endl;
    }
    else if (instruction == "fmax.s") {
        float reg2Value = getFloatValue(arg2);
        float reg1Value = getFloatValue(arg1);
        registers[getRegisterIndex(arg3)] = std::max(reg1Value, reg2Value);
        output_translate_2 << "FMAX.S: " << arg3 << " = " << registers[getRegisterIndex(arg3)] << std::endl;
    }
    else if (instruction == "fmadd.s") {
        float reg1Value = getFloatValue(arg1);
        float reg2Value = getFloatValue(arg2);
        float reg3Value = getFloatValue(arg3);
        registers[getRegisterIndex(arg4)] = (reg1Value * reg2Value) + reg3Value;
        output_translate_2 << "FMADD.S: " << arg4 << " = " << registers[getRegisterIndex(arg4)] << std::endl;
    }
    else if (instruction == "fmv.x.w") {
        int intValue = static_cast<int>(getFloatValue(arg1));
        registers[getRegisterIndex(arg2)] = intValue;
        output_translate_2 << "FMV.X.W: " << arg2 << " = " << registers[getRegisterIndex(arg2)] << std::endl;
    }
    else if (instruction == "fmv.w.x") {
        float floatValue = static_cast<float>(getIntValue(arg1));
        registers[getRegisterIndex(arg2)] = floatValue;
        output_translate_2 << "FMV.W.X: " << arg2 << " = " << registers[getRegisterIndex(arg2)] << std::endl;
    }
    else {
        output_translate_2 << "Unknown instruction: " << instruction << std::endl;
    }
}

// 변수 선언 함수
void declareVariable2(const std::string& line) {
    std::istringstream ss(line);
    std::string varName, equalsSign, valueStr;
    ss >> varName >> equalsSign >> valueStr;

    if (equalsSign == "=") {
        int value = parseNumber(valueStr);
        variableNames.push_back(varName);
        variableValues.push_back(value);
        output_translate_2 << "Variable " << varName << " declared with value " << value << std::endl;
    } else {
        output_translate_2 << "Invalid variable declaration: " << line << std::endl;
    }
}

void execute_translate_2(std::vector<std::string>& lines) {
    // 각 명령어 처리
    for (const auto& line : lines) {
        if (line.find('=') != std::string::npos) {
            declareVariable(line);  // 변수 선언 처리
        }
        else if (line.find('!') != std::string::npos) {
            printf("Declared Variables: ");
            for (int i = 0; i < variableNames.size(); i++) {
                output_translate_2 << variableNames.at(i) << " = " << variableValues.at(i) << ", ";
            }
            printf("\n");
            printf("Register Status: {");
            for (int i = 0; i < 8; i++) {
                printf(" %d", registers[i]);
            }
            printf(" }");
            printf("\n");
        }
        else {
            processCommand(line);   // 명령어 처리
        }
    }

}
