#pragma once  // �ߺ� ���� ����
#include <iostream>
#include <sstream>
#include <vector>
#include <regex>
#include <string>
#include <iomanip>
#include <bitset>




// �Լ� ���� ���� (������Ÿ��)
int getValue(const std::string& arg);
int getRegisterIndex(const std::string& reg);
int parseNumber(const std::string& str);
int getVariableValue(const std::string& varName);
void processCommand(const std::string& command);
void declareVariable(const std::string& line);
void execute_translate_1(std::vector<std::string>& lines);