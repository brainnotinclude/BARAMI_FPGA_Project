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
void processCommand2(const std::string& command) {
    std::istringstream ss(command);
    std::string instruction, arg1, arg2, arg3;
    ss >> instruction >> arg1 >> arg2 >> arg3;

    // Determine if arg1 is a register or a number/variable
    int value1 = getValue(arg1);
    int value2 = getValue(arg2);
    int value3 = getValue(arg3);
    int destIndex = getRegisterIndex(arg3);

    if (instruction == "mov") {
        registers[getRegisterIndex(arg2)] = value1;
        return;
    } 


    if (instruction == "add") {
        int reg2Value = getValue(arg2);
        registers[getRegisterIndex(arg3)] = value1 + reg2Value;
        output_translate_2 << "0110011_" << std::bitset<5>(value3) << "_000_" << std::bitset<5>(value1) << "_" << std::bitset<5>(value2) << "_0000000\n" << std::endl;
        return;
    }

    if (instruction == "sub") {
        int reg2Value = getValue(arg2);
        registers[getRegisterIndex(arg3)] = value1 - reg2Value;
        output_translate_2 << "0110011_" << std::bitset<5>(value3) << "_000_" << std::bitset<5>(value1) << "_" << std::bitset<5>(value2) << "_0100000\n" << std::endl;
        return;
    }

    if (instruction == "and") {
        registers[destIndex] = value1 & value2;
        output_translate_2 << "0110011_" << std::bitset<5>(value3) << "_111_" << std::bitset<5>(value1) << "_" << std::bitset<5>(value2) << "_0000000\n" << std::endl;
    }
    else if (instruction == "or") {
        registers[destIndex] = value1 | value2;
        output_translate_2 << "0110011_" << std::bitset<5>(value3) << "_110_" << std::bitset<5>(value1) << "_" << std::bitset<5>(value2) << "_0000000\n" << std::endl;
    }
    else if (instruction == "xor") {
        registers[destIndex] = value1 ^ value2;
        output_translate_2 << "0110011_" << std::bitset<5>(value3) << "_100_" << std::bitset<5>(value1) << "_" << std::bitset<5>(value2) << "_0000000\n" << std::endl;
    }
    else if (instruction == "sll") {
        registers[destIndex] = value1 << value2;
        output_translate_2 << "0110011_" << std::bitset<5>(value3) << "_001_" << std::bitset<5>(value1) << "_" << std::bitset<5>(value2) << "_0000000\n" << std::endl;
    }
    else if (instruction == "srl") {
        registers[destIndex] = static_cast<unsigned int>(value1) >> value2;
        output_translate_2 <<  "0110011_" << std::bitset<5>(value3) << "_101_" << std::bitset<5>(value1) << "_" << std::bitset<5>(value2) << "_0000000\n" << std::endl;
    }
    else if (instruction == "sra") {
        registers[destIndex] = value1 >> value2;
        output_translate_2 <<  "0110011_" << std::bitset<5>(value3) << "_101_" << std::bitset<5>(value1) << "_" << std::bitset<5>(value2) << "_0100000\n" << std::endl;
    }
    else if (instruction == "slt") {
        registers[destIndex] = (value1 < value2) ? 1 : 0;
        output_translate_2 <<  "0110011_" << std::bitset<5>(value3) << "_010_" << std::bitset<5>(value1) << "_" << std::bitset<5>(value2) << "_0000000\n" << std::endl;
    }
    else if (instruction == "sltu") {
        registers[destIndex] = (static_cast<unsigned int>(value1) < static_cast<unsigned int>(value2)) ? 1 : 0;
        output_translate_2 <<  "0110011_" << std::bitset<5>(value3) << "_011_" << std::bitset<5>(value1) << "_" << std::bitset<5>(value2) << "_0000000\n" << std::endl;
    }
    else if (instruction == "addi") {
        int imm = parseNumber(arg2);  // Immediate value
        registers[destIndex] = value1 + imm;
        output_translate_2 <<  "0010011_" << std::bitset<5>(value3) << "_000_" << std::bitset<5>(value1) << "_" << std::bitset<12>(imm) << "\n" << std::endl;
    }
    else if (instruction == "andi") {
        int imm = parseNumber(arg2);
        registers[destIndex] = value1 & imm;
        output_translate_2 <<  "0010011_" << std::bitset<5>(value3) << "_111_" << std::bitset<5>(value1) << "_" << std::bitset<12>(imm) << "\n" << std::endl;
    }
    else if (instruction == "ori") {
        int imm = parseNumber(arg2);
        registers[destIndex] = value1 | imm;
        output_translate_2 << "0010011_" << std::bitset<5>(value3) << "_110_" << std::bitset<5>(value1) << "_" << std::bitset<12>(imm) << "\n" << std::endl;
    }
    else if (instruction == "xori") {
        int imm = parseNumber(arg2);
        registers[destIndex] = value1 ^ imm;
        output_translate_2 << "0010011_" << std::bitset<5>(value3) << "_100_" << std::bitset<5>(value1) << "_" << std::bitset<12>(imm) << "\n" << std::endl;
    }
    else if (instruction == "slli") {
        int imm = parseNumber(arg2);
        registers[destIndex] = value1 << imm;
        output_translate_2 << "0010011_" << std::bitset<5>(value3) << "_001_" << std::bitset<5>(value1) << "_" << std::bitset<5>(imm) << "_0000000\n" << std::endl;
    }
    else if (instruction == "srli") {
        int imm = parseNumber(arg2);
        registers[destIndex] = static_cast<unsigned int>(value1) >> imm;
        output_translate_2 << "0010011_" << std::bitset<5>(value3) << "_101_" << std::bitset<5>(value1) << "_" << std::bitset<5>(imm) << "_0000000\n" << std::endl;
    }
    else if (instruction == "srai") {
        int imm = parseNumber(arg2);
        registers[destIndex] = value1 >> imm;
        output_translate_2 << "0010011_" << std::bitset<5>(value3) << "_101_" << std::bitset<5>(value1) << "_" << std::bitset<5>(imm) << "_0100000\n" << std::endl;
    }
    else if (instruction == "slti") {
        int imm = parseNumber(arg2);
        registers[destIndex] = (value1 < imm) ? 1 : 0;
        output_translate_2 << "0010011_" << std::bitset<5>(value3) << "_010_" << std::bitset<5>(value1) << "_" << std::bitset<12>(imm) << "\n" << std::endl;
    }
    else if (instruction == "sltiu") { // sltiu에서 얻은 언사인드 값이 bitset 통과할 때는 어찌되는지?
        int imm = parseNumber(arg2);
        registers[destIndex] = (static_cast<unsigned int>(value1) < static_cast<unsigned int>(imm)) ? 1 : 0;
        output_translate_2 << "0010011_" << std::bitset<5>(value3) << "_011_" << std::bitset<5>(value1) << "_" << std::bitset<12>(imm) << "\n" << std::endl;
    }
    else if (instruction == "lw") {
        int offset = parseNumber(arg2);
        int baseRegisterIndex = getRegisterIndex(arg3);
        //registers[destIndex] = memory[registers[baseRegisterIndex] + offset];
        output_translate_2 <<"0000011_" << std::bitset<5>(value3) << "_010_" << std::bitset<5>(value1) << "_" << std::bitset<12>(offset) << "\n" << std::endl;
    }
    else if (instruction == "jalr") {
        int offset = parseNumber(arg2);
        int baseRegisterIndex = getRegisterIndex(arg3);
        registers[destIndex] = registers[baseRegisterIndex] + offset;
        output_translate_2 <<"1100111_" << std::bitset<5>(value3) << "_000_" << std::bitset<5>(value1) << "_" << std::bitset<12>(offset) << "\n" << std::endl;
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
    } else {
        output_translate_2 << "Invalid variable declaration: " << line << std::endl;
    }
}

void execute_translate_2(std::vector<std::string>& lines) {
    // 각 명령어 처리
    for (const auto& line : lines) {
        if (line.find('=') != std::string::npos) {
            declareVariable2(line);  // 변수 선언 처리
        }
        else {
            processCommand2(line);   // 명령어 처리
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