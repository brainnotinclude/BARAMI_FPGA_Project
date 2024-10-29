// 입력된 문자열을 공백을 기준으로 나눠서 각각의 부분(명령어, 레지스터 등)으로 구분하고 기계어로 변환한다
#include "translate_1.h"
#include "translate_2.h"
#include "FileOpenAPI.h"
#include <iostream>
#include <sstream>
#include <vector>
#include <regex>
#include <string>
#include <iomanip>
#include <bitset>


// 레지스터 배열 (R0 ~ R7)
int registers[8] = {0, 0, 0, 0, 0, 0, 0, 0};

// 변수 배열
std::vector<std::string> variableNames;
std::vector<int> variableValues;

// 레지스터 인덱스 반환 함수 (R0 -> 0, R1 -> 1, ...) RV1은 레지스터 내부 값 반환.
int getRegisterIndex(const std::string &reg) {
    if (reg == "R0") return 0;
    if (reg == "R1") return 1;
    if (reg == "R2") return 2;
    if (reg == "R3") return 3;
    if (reg == "R4") return 4;
    if (reg == "R5") return 5;
    if (reg == "R6") return 6;
    if (reg == "R7") return 7;
    if (reg == "RV0") return 8;
    if (reg == "RV1") return 9;
    if (reg == "RV2") return 10;
    if (reg == "RV3") return 11;
    if (reg == "RV4") return 12;
    if (reg == "RV5") return 13;
    if (reg == "RV6") return 14;
    if (reg == "RV7") return 15;
    return -1;  // 오류 처리: 존재하지 않는 레지스터
}

// 변수 이름으로 값 찾기
int getVariableValue(const std::string &varName) {
    for (size_t i = 0; i < variableNames.size(); ++i) {
        if (variableNames[i] == varName) {
            return variableValues[i];
        }
    }
    return 0;  // 오류 처리: 변수 찾지 못함 (기본값 0)
}

// 숫자 변환 함수 (다양한 진법 지원)
int parseNumber(const std::string &str) {
    if (str.find("0x") == 0 || str.find("0X") == 0) {
        // 16진수 처리
        return std::stoi(str, nullptr, 16);
    } else if (str.find("0b") == 0 || str.find("0B") == 0) {
        // 2진수 처리
        return std::stoi(str.substr(2), nullptr, 2);
    } else if (str.find("0o") == 0 || str.find("0O") == 0) {
        // 8진수 처리
        return std::stoi(str.substr(2), nullptr, 8);
    } else {
        // 10진수 처리
        return std::stoi(str);
    }
}

int getValue(const std::string& arg) {
    // If arg is a register, return its value, otherwise treat it as a variable or number
    int regIndex = getRegisterIndex(arg);
    if (regIndex != -1) {
        if (regIndex >= 8) return registers[regIndex-8];
        return regIndex;
    }
    else if (isdigit(arg[0]) || arg[0] == '-' || arg[0] == '0') {
        return parseNumber(arg);
    }
    else {
        return getVariableValue(arg);
    }
}


/*
// 명령어 처리 함수 원본
void processCommand(const std::string& command) {
    std::istringstream ss(command);
    std::string instruction, arg1, arg2, arg3;
    ss >> instruction >> arg1 >> arg2 >> arg3;

    // Determine if arg1 is a register or a number/variable
    int value = getValue(arg1);
    int destIndex = getRegisterIndex(arg2);

    if (instruction == "MOV") {
        registers[destIndex] = value;
        std::cout << "MOV: " << arg2 << " = " << registers[destIndex] << std::endl;
    }
    else if (instruction == "ADD") {
        int reg2Value = getValue(arg2);
        registers[getRegisterIndex(arg3)] = value + reg2Value;
        std::cout << "ADD: " << arg3 << " = " << registers[getRegisterIndex(arg3)] << "\n" << std::endl;
        std::cout << "Result: " << "0110011_" << std::bitset<5>(getValue2(arg3)) << "_000_" << std::bitset<5>(getValue2(arg1)) << "_" << std::bitset<5>(getValue2(arg2)) << "_0000000" << std::endl;
    }
    else if (instruction == "SUB") {
        int reg2Value = getValue(arg2);
        registers[getRegisterIndex(arg3)] = value - reg2Value;
        std::cout << "SUB: " << arg3 << " = " << registers[getRegisterIndex(arg3)] << std::endl;
    }
    else {
        std::cout << "Unknown instruction: " << instruction << std::endl;
    }
}
*/
// 명령어 처리 함수
void processCommand(const std::string& command) {
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
        std::cout << "mov: " << arg2 << " = " << registers[getRegisterIndex(arg2)] << "\n" << std::endl;
        return;
    } 


    if (instruction == "add") {
        int reg2Value = getValue(arg2);
        registers[getRegisterIndex(arg3)] = value1 + reg2Value;
        std::cout << "ADD: " << arg3 << " = " << registers[getRegisterIndex(arg3)] << std::endl;
        std::cout << "Result: " << "0110011" << std::bitset<5>(value3) << "000" << std::bitset<5>(value1) << "" << std::bitset<5>(value2) << "0000000\n" << std::endl;
        return;
    }
    if (instruction == "sub") {
        int reg2Value = getValue(arg2);
        registers[getRegisterIndex(arg3)] = value1 - reg2Value;
        std::cout << "SUB: " << arg3 << " = " << registers[getRegisterIndex(arg3)] << std::endl;
        std::cout << "Result: " << "0110011" << std::bitset<5>(value3) << "000" << std::bitset<5>(value1) << "" << std::bitset<5>(value2) << "0100000\n" << std::endl;
        return;
    }
    if (instruction == "and") {
        registers[destIndex] = value1 & value2;
        std::cout << "AND: " << arg3 << " = " << registers[destIndex] << std::endl;
        std::cout << "Result: " << "0110011" << std::bitset<5>(value3) << "111" << std::bitset<5>(value1) << "" << std::bitset<5>(value2) << "0000000\n" << std::endl;
    }
    else if (instruction == "or") {
        registers[destIndex] = value1 | value2;
        std::cout << "OR: " << arg3 << " = " << registers[destIndex] << std::endl;
        std::cout << "Result: " << "0110011" << std::bitset<5>(value3) << "110" << std::bitset<5>(value1) << "" << std::bitset<5>(value2) << "0000000\n" << std::endl;
    }
    else if (instruction == "xor") {
        registers[destIndex] = value1 ^ value2;
        std::cout << "XOR: " << arg3 << " = " << registers[destIndex] << std::endl;
        std::cout << "Result: " << "0110011" << std::bitset<5>(value3) << "100" << std::bitset<5>(value1) << "" << std::bitset<5>(value2) << "0000000\n" << std::endl;
    }
    else if (instruction == "sll") {
        registers[destIndex] = value1 << value2;
        std::cout << "SLL: " << arg3 << " = " << registers[destIndex] << std::endl;
        std::cout << "Result: " << "0110011" << std::bitset<5>(value3) << "001" << std::bitset<5>(value1) << "" << std::bitset<5>(value2) << "0000000\n" << std::endl;
    }
    else if (instruction == "srl") {
        registers[destIndex] = static_cast<unsigned int>(value1) >> value2;
        std::cout << "SRL: " << arg3 << " = " << registers[destIndex] << std::endl;
        std::cout << "Result: " << "0110011" << std::bitset<5>(value3) << "101" << std::bitset<5>(value1) << "" << std::bitset<5>(value2) << "0000000\n" << std::endl;
    }
    else if (instruction == "sra") {
        registers[destIndex] = value1 >> value2;
        std::cout << "SRA: " << arg3 << " = " << registers[destIndex] << std::endl;
        std::cout << "Result: " << "0110011" << std::bitset<5>(value3) << "101" << std::bitset<5>(value1) << "" << std::bitset<5>(value2) << "0100000\n" << std::endl;
    }
    else if (instruction == "slt") {
        registers[destIndex] = (value1 < value2) ? 1 : 0;
        std::cout << "SLT: " << arg3 << " = " << registers[destIndex] << std::endl;
        std::cout << "Result: " << "0110011" << std::bitset<5>(value3) << "010" << std::bitset<5>(value1) << "" << std::bitset<5>(value2) << "0000000\n" << std::endl;
    }
    else if (instruction == "sltu") {
        registers[destIndex] = (static_cast<unsigned int>(value1) < static_cast<unsigned int>(value2)) ? 1 : 0;
        std::cout << "SLTU: " << arg3 << " = " << registers[destIndex] << std::endl;
        std::cout << "Result: " << "0110011" << std::bitset<5>(value3) << "011" << std::bitset<5>(value1) << "" << std::bitset<5>(value2) << "0000000\n" << std::endl;
    }
    else if (instruction == "addi") {
        int imm = parseNumber(arg2);  // Immediate value
        registers[destIndex] = value1 + imm;
        std::cout << "ADDI: " << arg3 << " = " << registers[destIndex] << std::endl;
        std::cout << "Result: " << "0010011" << std::bitset<5>(value3) << "000" << std::bitset<5>(value1) << "" << std::bitset<12>(imm) << "\n" << std::endl;
    }
    else if (instruction == "andi") {
        int imm = parseNumber(arg2);
        registers[destIndex] = value1 & imm;
        std::cout << "ANDI: " << arg3 << " = " << registers[destIndex] << std::endl;
        std::cout << "Result: " << "0010011" << std::bitset<5>(value3) << "111" << std::bitset<5>(value1) << "" << std::bitset<12>(imm) << "\n" << std::endl;
    }
    else if (instruction == "ori") {
        int imm = parseNumber(arg2);
        registers[destIndex] = value1 | imm;
        std::cout << "ORI: " << arg3 << " = " << registers[destIndex] << std::endl;
        std::cout << "Result: " << "0010011" << std::bitset<5>(value3) << "110" << std::bitset<5>(value1) << "" << std::bitset<12>(imm) << "\n" << std::endl;
    }
    else if (instruction == "xori") {
        int imm = parseNumber(arg2);
        registers[destIndex] = value1 ^ imm;
        std::cout << "XORI: " << arg3 << " = " << registers[destIndex] << std::endl;
        std::cout << "Result: " << "0010011" << std::bitset<5>(value3) << "100" << std::bitset<5>(value1) << "" << std::bitset<12>(imm) << "\n" << std::endl;
    }
    else if (instruction == "slli") {
        int imm = parseNumber(arg2);
        registers[destIndex] = value1 << imm;
        std::cout << "SLLI: " << arg3 << " = " << registers[destIndex] << std::endl;
        std::cout << "Result: " << "0010011" << std::bitset<5>(value3) << "001" << std::bitset<5>(value1) << "" << std::bitset<5>(imm) << "0000000\n" << std::endl;
    }
    else if (instruction == "srli") {
        int imm = parseNumber(arg2);
        registers[destIndex] = static_cast<unsigned int>(value1) >> imm;
        std::cout << "SRLI: " << arg3 << " = " << registers[destIndex] << std::endl;
        std::cout << "Result: " << "0010011" << std::bitset<5>(value3) << "101" << std::bitset<5>(value1) << "" << std::bitset<5>(imm) << "0000000\n" << std::endl;
    }
    else if (instruction == "srai") {
        int imm = parseNumber(arg2);
        registers[destIndex] = value1 >> imm;
        std::cout << "SRAI: " << arg3 << " = " << registers[destIndex] << std::endl;
        std::cout << "Result: " << "0010011" << std::bitset<5>(value3) << "101" << std::bitset<5>(value1) << "" << std::bitset<5>(imm) << "0100000\n" << std::endl;
    }
    else if (instruction == "slti") {
        int imm = parseNumber(arg2);
        registers[destIndex] = (value1 < imm) ? 1 : 0;
        std::cout << "SLTI: " << arg3 << " = " << registers[destIndex] << std::endl;
        std::cout << "Result: " << "0010011" << std::bitset<5>(value3) << "010" << std::bitset<5>(value1) << "" << std::bitset<12>(imm) << "\n" << std::endl;
    }
    else if (instruction == "sltiu") { // sltiu에서 얻은 언사인드 값이 bitset 통과할 때는 어찌되는지?
        int imm = parseNumber(arg2);
        registers[destIndex] = (static_cast<unsigned int>(value1) < static_cast<unsigned int>(imm)) ? 1 : 0;
        std::cout << "SLTIU: " << arg3 << " = " << registers[destIndex] << std::endl;
        std::cout << "Result: " << "0010011" << std::bitset<5>(value3) << "011" << std::bitset<5>(value1) << "" << std::bitset<12>(imm) << "\n" << std::endl;
    }
    else if (instruction == "lw") {
        int offset = parseNumber(arg2);
        int baseRegisterIndex = getRegisterIndex(arg3);
        //registers[destIndex] = memory[registers[baseRegisterIndex] + offset];
        std::cout << "LW: " << arg3 << " = " << registers[destIndex] << std::endl;
        std::cout << "Result: " << "0000011" << std::bitset<5>(value3) << "010" << std::bitset<5>(value1) << "" << std::bitset<12>(offset) << "\n" << std::endl;
    }
    else if (instruction == "jalr") {
        int offset = parseNumber(arg2);
        int baseRegisterIndex = getRegisterIndex(arg3);
        registers[destIndex] = registers[baseRegisterIndex] + offset;
        std::cout << "JALR: " << arg1 << " = " << registers[destIndex] << std::endl;
        std::cout << "Result: " << "1100111" << std::bitset<5>(value3) << "000" << std::bitset<5>(value1) << "" << std::bitset<12>(offset) << "\n" << std::endl;
    }
    else if (instruction == "beq") {
        if (value1 == value2) {
            std::cout << "BEQ: Branching if equal" << std::endl;
            std::cout << "Result: " << "1100011" << std::bitset<5>(value1) << "000" << std::bitset<5>(value2) << std::bitset<12>(value3) << "\n" << std::endl;
        }
    }
    else if (instruction == "bne") {
        if (value1 != value2) {
            std::cout << "BNE: Branching if not equal" << std::endl;
            std::cout << "Result: " << "1100011" << std::bitset<5>(value1) << "001" << std::bitset<5>(value2) << std::bitset<12>(value3) << "\n" << std::endl;
        }
    }
    else if (instruction == "bge") {
        if (value1 >= value2) {
            std::cout << "BGE: Branching if greater than or equal" << std::endl;
            std::cout << "Result: " << "1100011" << std::bitset<5>(value1) << "101" << std::bitset<5>(value2) << std::bitset<12>(value3) << "\n" << std::endl;
        }
    }
    else if (instruction == "bgeu") {
        if (static_cast<unsigned int>(value1) >= static_cast<unsigned int>(value2)) {
            std::cout << "BGEU: Branching if greater than or equal unsigned" << std::endl;
            std::cout << "Result: " << "1100011" << std::bitset<5>(value1) << "111" << std::bitset<5>(value2) << std::bitset<12>(value3) << "\n" << std::endl;
        }
    }
    else if (instruction == "blt") {
        if (value1 < value2) {
            std::cout << "BLT: Branching if less than" << std::endl;
            std::cout << "Result: " << "1100011" << std::bitset<5>(value1) << "100" << std::bitset<5>(value2) << std::bitset<12>(value3) << "\n" << std::endl;
        }
    }
    else if (instruction == "bltu") {
        if (static_cast<unsigned int>(value1) < static_cast<unsigned int>(value2)) {
            std::cout << "BLTU: Branching if less than unsigned" << std::endl;
            std::cout << "Result: " << "1100011" << std::bitset<5>(value1) << "110" << std::bitset<5>(value2) << std::bitset<12>(value3) << "\n" << std::endl;
        }
    }
    else {
        std::cout << "Unknown instruction: " << instruction << std::endl;
    }
}

// 변수 선언 함수
void declareVariable(const std::string& line) {
    std::istringstream ss(line);
    std::string varName, equalsSign, valueStr;
    ss >> varName >> equalsSign >> valueStr;

    if (equalsSign == "=") {
        int value = parseNumber(valueStr);
        variableNames.push_back(varName);
        variableValues.push_back(value);
        std::cout << "Variable " << varName << " declared with value " << value << std::endl;
    } else {
        std::cout << "Invalid variable declaration: " << line << std::endl;
    }
}

void execute_translate_1(std::vector<std::string>& lines) {
    // 각 명령어 처리
    for (const auto& line : lines) {
        if (line.find('=') != std::string::npos) {
            declareVariable(line);  // 변수 선언 처리
        }
        else if (line.find('!') != std::string::npos) {
            printf("Declared Variables: ");
            for (int i = 0; i < variableNames.size(); i++) {
                std::cout << variableNames.at(i) << " = " << variableValues.at(i) << ", ";
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
/*
int main() {
    // 테스트 입력
    std::vector<std::string> lines = {
        "VAR_A = 0x1A",  // 변수 선언
        "mov VAR_A R1",  // 변수 값을 레지스터로 이동
        "mov 0b1010 R2",  // 2진수로 레지스터 값 설정
        "add R1 R2 R3",   // 레지스터 간 더하기
        "sub R1 R2 R0"    // 레지스터 간 빼기
    };
    //execute_translate_1( lines );


    return 0;
}
*/
