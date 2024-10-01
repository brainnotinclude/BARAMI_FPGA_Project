#pragma once  // 중복 포함 방지
#include <iostream>
#include <sstream>
#include <vector>
#include <regex>
#include <string>
#include <iomanip>
#include <bitset>




// 함수 원형 선언 (프로토타입)
int getValue(const std::string& arg);
int getRegisterIndex(const std::string& reg);
int parseNumber(const std::string& str);
int getVariableValue(const std::string& varName);
void processCommand(const std::string& command);
void declareVariable(const std::string& line);
void execute_translate_1(std::vector<std::string>& lines);