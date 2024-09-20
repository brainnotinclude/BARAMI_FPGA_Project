#pragma once  // �ߺ� ���� ����

#include <iostream>
#include <sstream>
#include <vector>
#include <regex>
#include <string>
#include <iomanip>
#include <bitset>




// �Լ� ���� ���� (������Ÿ��)
void processCommand(const std::string& command);
void declareVariable(const std::string& line);
int getRegisterIndex(const std::string& reg);
int getVariableValue(const std::string& varName);
int parseNumber(const std::string& str);
int getValue(const std::string& arg);
void execute_translate_1(std::vector<std::string>& lines);