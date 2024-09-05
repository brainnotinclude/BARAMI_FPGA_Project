// 입력된 문자열을 공백을 기준으로 나눠서 각각의 부분(명령어, 레지스터 등)을 추출하고, 이를 기반으로 기계어로 변환한다

#include <iostream>
#include <sstream>
#include <vector>
#include <unordered_map>

// 기계어로 변환할 명령어 매핑 테이블
std::unordered_map<std::string, int> instructionSet = {
    {"ADD", 1},  // ADD 명령어에 기계어 1을 할당
    {"SUB", 2},  // SUB 명령어에 기계어 2를 할당
    {"MOV", 3},  // MOV 명령어에 기계어 3을 할당
    {"MUL", 4}   // MUL 명령어에 기계어 4를 할당
};

// 레지스터 매핑 테이블
std::unordered_map<std::string, int> registerSet = {
    {"R0", 0},
    {"R1", 1},
    {"R2", 2},
    {"R3", 3}
};

// 공백을 기준으로 문자열을 나누는 함수
std::vector<std::string> split(const std::string& str) {
    std::vector<std::string> tokens;
    std::stringstream ss(str);
    std::string token;

    // 공백을 기준으로 문자열을 나눔
    while (ss >> token) {
        tokens.push_back(token);
    }
    return tokens;
}

// 어셈블리 명령어를 기계어로 변환하는 함수
void assemble(const std::string& assemblyCode) {
    // 문자열을 공백을 기준으로 나누기
    std::vector<std::string> tokens = split(assemblyCode);

    if (tokens.size() < 2) {
        std::cerr << "잘못된 명령어입니다!" << std::endl;
        return;
    }

    // 명령어 추출 및 기계어 변환
    std::string instruction = tokens[0];
    if (instructionSet.find(instruction) == instructionSet.end()) {
        std::cerr << "알 수 없는 명령어: " << instruction << std::endl;
        return;
    }

    int machineCode = instructionSet[instruction]; // 명령어를 기계어로 변환

    // 레지스터들 추출 및 기계어 변환
    for (size_t i = 1; i < tokens.size(); ++i) {
        std::string reg = tokens[i];
        if (registerSet.find(reg) == registerSet.end()) {
            std::cerr << "알 수 없는 레지스터: " << reg << std::endl;
            return;
        }
        machineCode = (machineCode << 4) | registerSet[reg]; // 기계어에 레지스터 추가
    }

    // 최종 기계어 출력
    std::cout << "기계어: " << std::hex << machineCode << std::endl;
}

int main() {
    std::string assemblyCode;

    // 어셈블리 코드 입력 받기
    std::cout << "어셈블리 코드를 입력하세요 (예: ADD R1 R2 R3): ";
    std::getline(std::cin, assemblyCode);

    // 어셈블리 코드를 기계어로 변환
    assemble(assemblyCode);

    return 0;
}
