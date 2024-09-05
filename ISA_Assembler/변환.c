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

// 명령어 처리 함수
void processCommand(const std::string& command) {
    std::istringstream ss(command);
    std::string instruction, arg1, arg2, arg3;
    ss >> instruction >> arg1 >> arg2 >> arg3;

    int reg1Index = getRegisterIndex(arg1);
    int reg2Index = getRegisterIndex(arg2);
    int destIndex = getRegisterIndex(arg3);

    if (instruction == "MOV") {
        // MOV <value/var> <dest>
        int value = (reg1Index != -1) ? registers[reg1Index] : getVariableValueOrNumber(arg1);
        registers[reg2Index] = value;
        std::cout << "MOV: " << arg2 << " = " << registers[reg2Index] << std::endl;
    }
    else if (instruction == "ADD") {
        // ADD <reg1> <reg2> <dest>
        registers[destIndex] = registers[reg1Index] + registers[reg2Index];
        std::cout << "ADD: " << arg3 << " = " << registers[destIndex] << std::endl;
    }
    else if (instruction == "SUB") {
        // SUB <reg1> <reg2> <dest>
        registers[destIndex] = registers[reg1Index] - registers[reg2Index];
        std::cout << "SUB: " << arg3 << " = " << registers[destIndex] << std::endl;
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

int main() {
    // 테스트 입력
    std::vector<std::string> lines = {
        "VAR_A = 0x1A",  // 변수 선언
        "MOV VAR_A R1",  // 변수 값을 레지스터로 이동
        "MOV 0b1010 R2",  // 2진수로 레지스터 값 설정
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
