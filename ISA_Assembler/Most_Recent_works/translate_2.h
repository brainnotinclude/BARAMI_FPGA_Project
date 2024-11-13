#pragma once  // 중복 포함 방지
#include "translate_1.h"
#include <iostream>
#include <sstream>
#include <vector>
#include <regex>
#include <string>
#include <iomanip>
#include <bitset>
//#include <stdexcept>




// 함수 원형 선언 (프로토타입)
void processCommand2(const std::string& command);
void declareVariable2(const std::string& line);
void execute_translate_2(std::vector<std::string>& lines);

extern std::ostringstream output_translate_2;

// 레지스터 배열 (R0 ~ R7)
extern int registers[8];

// 변수 배열
extern std::vector<std::string> variableNames;
extern std::vector<int> variableValues;

