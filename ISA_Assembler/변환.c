// 입력된 문자열을 공백을 기준으로 나눠서 각각의 부분(명령어, 레지스터 등)을 추출하고, 이를 기반으로 기계어로 변환한다

#include <iostream>
#include <sstream>
#include <unordered_map>
#include <vector>
#include <regex>
#include <string>
#include <iomanip>

// 레지스터 및 변수 테이블
std::unordered_map<std::string, int> registers = {{"R0", 0}, {"R1", 0}, {"R2", 0}, {"R3", 0}};
std::unordered_map<std::string, int> variables;

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
void processCommand(const std::string &command) {
    std::istringstream ss(command);
    std::string instruction, arg1, arg2, arg3;
    ss >> instruction >> arg1 >> arg2 >> arg3;

    if (instruction == "MOV") {
        // MOV <src> <dest>
        if (variables.find(arg1) != variables.end()) {
            registers[arg2] = variables[arg1];  // 변수에서 값을 레지스터로 복사
        } else {
            registers[arg2] = parseNumber(arg1);  // 숫자 입력
        }
        std::cout << "MOV: " << arg2 << " = " << registers[arg2] << std::endl;
    } else if (instruction == "ADD") {
        // ADD <reg1> <reg2> <dest>
        registers[arg3] = registers[arg1] + registers[arg2];
        std::cout << "ADD: " << arg3 << " = " << registers[arg3] << std::endl;
    } else if (instruction == "SUB") {
        // SUB <reg1> <reg2> <dest>
        registers[arg3] = registers[arg1] - registers[arg2];
        std::cout << "SUB: " << arg3 << " = " << registers[arg3] << std::endl;
    } else {
        std::cout << "Unknown instruction: " << instruction << std::endl;
    }
}

// 변수 선언 함수
void declareVariable(const std::string &line) {
    std::regex varDecl(R"((\w+)\s*=\s*(.*))");
    std::smatch match;
    if (std::regex_match(line, match, varDecl)) {
        std::string varName = match[1];
        std::string valueStr = match[2];
        int value = parseNumber(valueStr);
        variables[varName] = value;
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
