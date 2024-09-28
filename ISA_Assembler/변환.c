// 입력된 문자열을 공백을 기준으로 나눠서 각각의 부분(명령어, 레지스터 등)으로 구분하고 기계어로 변환한다

#include <iostream>
#include <sstream>
#include <vector>
#include <regex>
#include <string>
#include <iomanip>

// 레지스터 배열 (R0 ~ R3)
int registers[4] = {0, 0, 0, 0};

// 변수 배열
std::vector<std::string> variableNames;
std::vector<int> variableValues;

// 레지스터 인덱스 반환 함수 (R0 -> 0, R1 -> 1, ...)
int getRegisterIndex(const std::string &reg) {
    if (reg == "R0") return 0;
    if (reg == "R1") return 1;
    if (reg == "R2") return 2;
    if (reg == "R3") return 3;
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

// 숫자 변환 함수
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

// 명령어 처리 함수
void processCommand(const std::string& command) {
    std::istringstream ss(command);
    std::string instruction, arg1, arg2, arg3;
    ss >> instruction >> arg1 >> arg2 >> arg3;

    int value1 = getValue(arg1);  // Get value from the first argument (register or variable)
    int destIndex = getRegisterIndex(arg2);  // Get the destination register index
    
    if (instruction == "ADD") {
        int value2 = getValue(arg3);
        registers[destIndex] = value1 + value2;
        std::cout << "ADD: " << arg2 << " = " << registers[destIndex] << std::endl;
    } 
    else if (instruction == "SUB") {
        int value2 = getValue(arg3);
        registers[destIndex] = value1 - value2;
        std::cout << "SUB: " << arg2 << " = " << registers[destIndex] << std::endl;
    } 
    else if (instruction == "AND") {
        int value2 = getValue(arg3);
        registers[destIndex] = value1 & value2;
        std::cout << "AND: " << arg2 << " = " << registers[destIndex] << std::endl;
    } 
    else if (instruction == "OR") {
        int value2 = getValue(arg3);
        registers[destIndex] = value1 | value2;
        std::cout << "OR: " << arg2 << " = " << registers[destIndex] << std::endl;
    } 
    else if (instruction == "XOR") {
        int value2 = getValue(arg3);
        registers[destIndex] = value1 ^ value2;
        std::cout << "XOR: " << arg2 << " = " << registers[destIndex] << std::endl;
    } 
    else if (instruction == "SLL") {
        int value2 = getValue(arg3);
        registers[destIndex] = value1 << value2;
        std::cout << "SLL: " << arg2 << " = " << registers[destIndex] << std::endl;
    }
    else if (instruction == "SRL") {
        int value2 = getValue(arg3);
        registers[destIndex] = static_cast<unsigned int>(value1) >> value2;
        std::cout << "SRL: " << arg2 << " = " << registers[destIndex] << std::endl;
    }
    else if (instruction == "SRA") {
        int value2 = getValue(arg3);
        registers[destIndex] = value1 >> value2;
        std::cout << "SRA: " << arg2 << " = " << registers[destIndex] << std::endl;
    }
    else if (instruction == "SLT") {
        int value2 = getValue(arg3);
        registers[destIndex] = (value1 < value2) ? 1 : 0;
        std::cout << "SLT: " << arg2 << " = " << registers[destIndex] << std::endl;
    }
    else if (instruction == "SLTU") {
        int value2 = getValue(arg3);
        registers[destIndex] = (static_cast<unsigned int>(value1) < static_cast<unsigned int>(value2)) ? 1 : 0;
        std::cout << "SLTU: " << arg2 << " = " << registers[destIndex] << std::endl;
    }
    else if (instruction == "ADDI") {
        int imm = parseNumber(arg3);  // Immediate value
        registers[destIndex] = value1 + imm;
        std::cout << "ADDI: " << arg2 << " = " << registers[destIndex] << std::endl;
    }
    else if (instruction == "ANDI") {
        int imm = parseNumber(arg3);
        registers[destIndex] = value1 & imm;
        std::cout << "ANDI: " << arg2 << " = " << registers[destIndex] << std::endl;
    }
    else if (instruction == "ORI") {
        int imm = parseNumber(arg3);
        registers[destIndex] = value1 | imm;
        std::cout << "ORI: " << arg2 << " = " << registers[destIndex] << std::endl;
    }
    else if (instruction == "XORI") {
        int imm = parseNumber(arg3);
        registers[destIndex] = value1 ^ imm;
        std::cout << "XORI: " << arg2 << " = " << registers[destIndex] << std::endl;
    }
    else if (instruction == "SLLI") {
        int imm = parseNumber(arg3);
        registers[destIndex] = value1 << imm;
        std::cout << "SLLI: " << arg2 << " = " << registers[destIndex] << std::endl;
    }
    else if (instruction == "SRLI") {
        int imm = parseNumber(arg3);
        registers[destIndex] = static_cast<unsigned int>(value1) >> imm;
        std::cout << "SRLI: " << arg2 << " = " << registers[destIndex] << std::endl;
    }
    else if (instruction == "SRAI") {
        int imm = parseNumber(arg3);
        registers[destIndex] = value1 >> imm;
        std::cout << "SRAI: " << arg2 << " = " << registers[destIndex] << std::endl;
    }
    else if (instruction == "SLTI") {
        int imm = parseNumber(arg3);
        registers[destIndex] = (value1 < imm) ? 1 : 0;
        std::cout << "SLTI: " << arg2 << " = " << registers[destIndex] << std::endl;
    }
    else if (instruction == "SLTIU") {
        int imm = parseNumber(arg3);
        registers[destIndex] = (static_cast<unsigned int>(value1) < static_cast<unsigned int>(imm)) ? 1 : 0;
        std::cout << "SLTIU: " << arg2 << " = " << registers[destIndex] << std::endl;
    }
    else if (instruction == "LW") {
        int offset = parseNumber(arg3);
        int baseRegisterIndex = getRegisterIndex(arg2);
        registers[destIndex] = memory[registers[baseRegisterIndex] + offset];
        std::cout << "LW: " << arg2 << " = " << registers[destIndex] << std::endl;
    }
    else if (instruction == "JALR") {
        int baseRegisterIndex = getRegisterIndex(arg2);
        registers[destIndex] = registers[baseRegisterIndex] + parseNumber(arg3);
        std::cout << "JALR: " << arg2 << " = " << registers[destIndex] << std::endl;
    }
    else {
        std::cout << "Unknown instruction: " << instruction << std::endl;
    }
}

int getValue(const std::string& arg) {
    // If arg is a register, return its value, otherwise treat it as a variable or number
    int regIndex = getRegisterIndex(arg);
    if (regIndex != -1) {
        return registers[regIndex];
    } else if (isdigit(arg[0]) || arg[0] == '-' || arg[0] == '0') {
        return parseNumber(arg);
    } else {
        return getVariableValue(arg);
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

int main() {
    // 테스트 입력
    std::vector<std::string> lines = {
        "VAR_A = 0x1A",  // 변수 선언
        "ADD R1 R2 R3",   // 레지스터 간 더하기
        "SUB R1 R2 R0"    // 레지스터 간 빼기
    };

    // 각 명령어 처리
    for (const auto &line : lines) {
        if (line.find('=') != std::string::npos) {
            declareVariable(line);  // 변수 선언 처리
        } else {
            processCommand(line);   // 명령어 처리
        }
    }

    return 0;
}
