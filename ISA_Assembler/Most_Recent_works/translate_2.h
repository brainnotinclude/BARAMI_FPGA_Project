#pragma once  // �ߺ� ���� ����
#include "translate_1.h"
#include <iostream>
#include <sstream>
#include <vector>
#include <regex>
#include <string>
#include <iomanip>
#include <bitset>
//#include <stdexcept>




// �Լ� ���� ���� (������Ÿ��)
void processCommand2(const std::string& command);
void declareVariable2(const std::string& line);
void execute_translate_2(std::vector<std::string>& lines);

extern std::ostringstream output_translate_2;

// �������� �迭 (R0 ~ R7)
extern int registers[8];

// ���� �迭
extern std::vector<std::string> variableNames;
extern std::vector<int> variableValues;

