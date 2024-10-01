#pragma once
#include "translate_2.h"
#include <windows.h>
#include <commdlg.h>  
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>

std::wstring convertToWideString(const std::string& str);
std::wstring openFileDialog();
std::wstring saveFileDialog();
std::string readFromFile(const std::wstring& filePath);
void writeToFile(const std::wstring& filePath, const std::string& content);
std::vector<std::string> splitIntoLines(const std::string& content);
int FileOPENAPI();
