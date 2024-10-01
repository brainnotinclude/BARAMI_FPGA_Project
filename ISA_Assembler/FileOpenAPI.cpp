#include "translate_1.h"
#include "translate_2.h"
#include "FileOpenAPI.h"
#include <windows.h>
#include <commdlg.h>  
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>

std::ostringstream output_translate_2;


// 멀티바이트 문자열을 유니코드로 변환하는 함수
std::wstring convertToWideString(const std::string& str) {
    int size_needed = MultiByteToWideChar(CP_ACP, 0, str.c_str(), (int)str.size(), NULL, 0);
    std::wstring wstr(size_needed, 0);
    MultiByteToWideChar(CP_ACP, 0, str.c_str(), (int)str.size(), &wstr[0], size_needed);
    return wstr;
}

// 파일 열기 대화 상자
std::wstring openFileDialog() {
    OPENFILENAMEW ofn;
    wchar_t fileName[MAX_PATH] = L"";
    ZeroMemory(&ofn, sizeof(ofn));
    ofn.lStructSize = sizeof(ofn);
    ofn.hwndOwner = NULL;
    ofn.lpstrFilter = L"Text Files\0*.txt\0All Files\0*.*\0";
    ofn.lpstrFile = fileName;
    ofn.nMaxFile = MAX_PATH;
    ofn.Flags = OFN_EXPLORER | OFN_FILEMUSTEXIST | OFN_HIDEREADONLY;
    ofn.lpstrDefExt = L"txt";

    if (GetOpenFileNameW(&ofn)) {
        return std::wstring(fileName);
    }
    return L"";
}

// 파일 저장 대화 상자
std::wstring saveFileDialog() {
    OPENFILENAMEW ofn;
    wchar_t fileName[MAX_PATH] = L"";
    ZeroMemory(&ofn, sizeof(ofn));
    ofn.lStructSize = sizeof(ofn);
    ofn.hwndOwner = NULL;
    ofn.lpstrFilter = L"Text Files\0*.txt\0All Files\0*.*\0";
    ofn.lpstrFile = fileName;
    ofn.nMaxFile = MAX_PATH;
    ofn.Flags = OFN_EXPLORER | OFN_PATHMUSTEXIST | OFN_HIDEREADONLY;
    ofn.lpstrDefExt = L"txt";

    if (GetSaveFileNameW(&ofn)) {
        return std::wstring(fileName);
    }
    return L"";
}

// 파일 내용 읽기
std::string readFromFile(const std::wstring& filePath) {
    std::ifstream inFile(filePath, std::ios::binary);
    if (!inFile) {
        std::wcerr << L"파일을 열 수 없습니다: " << filePath << std::endl;
        return "";
    }

    std::string content((std::istreambuf_iterator<char>(inFile)),
        std::istreambuf_iterator<char>());
    inFile.close();
    return content;
}

// 파일 내용 쓰기
void writeToFile(const std::wstring& filePath, const std::string& content) {
    std::ofstream outFile(filePath, std::ios::binary);
    if (!outFile) {
        std::wcerr << L"파일을 저장할 수 없습니다: " << filePath << std::endl;
        return;
    }

    outFile << content;
    outFile.close();
}

// 문자열을 줄 단위로 나누어 vector로 변환하는 함수
std::vector<std::string> splitIntoLines(const std::string& content) {
    std::vector<std::string> lines;
    std::istringstream stream(content);
    std::string line;
    while (std::getline(stream, line)) {
        lines.push_back(line);
    }
    return lines;
}

// execute_translate2 함수 (가정)
/*
void execute_translate2(std::vector<std::string>& lines) {
    for (const auto& line : lines) {
        std::cout << "Translated Line: " << line << std::endl;  // 여기서 가공된 결과를 처리
    }
}
*/
int FileOPENAPI() {
    // 파일 열기 대화 상자를 사용해 파일 선택
    std::wstring openPath = openFileDialog();
    if (openPath.empty()) {
        std::wcerr << L"파일이 선택되지 않았습니다." << std::endl;
        return 1;
    }

    // 선택한 파일에서 내용 읽기
    std::string fileContent = readFromFile(openPath);
    if (fileContent.empty()) {
        std::wcerr << L"파일 내용이 비어있거나 읽기 오류가 발생했습니다." << std::endl;
        return 1;
    }

    // 파일 내용을 줄 단위로 분리하여 벡터로 변환
    std::vector<std::string> lines = splitIntoLines(fileContent);

    // 파일 내용을 execute_translate2 함수에 넘김
    execute_translate_2(lines);

    // 화면에 출력한 내용을 다시 파일에 저장
    std::string modifiedContent = output_translate_2.str();

   /* std::string modifiedContent;
    for (const auto& line : lines) {
        modifiedContent += line + "\n";  // 변환된 내용을 다시 하나의 문자열로 병합
    }
    */

    // 파일 저장 대화 상자를 사용해 파일 저장 위치 선택
    std::wstring savePath = saveFileDialog();
    if (savePath.empty()) {
        std::wcerr << L"파일 저장 위치가 선택되지 않았습니다." << std::endl;
        return 1;
    }

    // 선택된 파일에 내용 쓰기
    writeToFile(savePath, modifiedContent);

    std::wcout << L"파일이 저장되었습니다: " << savePath << std::endl;

    return 0;
}









/*#include <windows.h>
#include <commdlg.h>
#include <wchar.h>
#include <stdio.h>

void open_file_dialog(wchar_t* filename) {
    OPENFILENAMEW ofn;
    wchar_t szFile[260];

    ZeroMemory(&ofn, sizeof(ofn));
    ofn.lStructSize = sizeof(ofn);
    ofn.hwndOwner = NULL;
    ofn.lpstrFile = szFile;
    ofn.lpstrFile[0] = L'\0';
    ofn.nMaxFile = sizeof(szFile) / sizeof(szFile[0]);
    ofn.lpstrFilter = L"All Files\0*.*\0Text Files\0*.TXT\0";
    ofn.nFilterIndex = 1;
    ofn.lpstrFileTitle = NULL;
    ofn.nMaxFileTitle = 0;
    ofn.lpstrInitialDir = NULL;
    ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST;

    if (GetOpenFileNameW(&ofn) == TRUE) {
        wcscpy(filename, ofn.lpstrFile);
    }
    else {
        filename[0] = L'\0';
    }
}

int main() {
    wchar_t filename[260];
    open_file_dialog(filename);

    if (filename[0] != L'\0') {
        wprintf(L"Selected file: %s\n", filename);
        FILE* file = _wfopen(filename, L"r, ccs=UTF-8");
        if (file) {
            wchar_t line[256];
            while (fgetws(line, sizeof(line) / sizeof(line[0]), file)) {
                wprintf(L"%s", line);
            }
            fclose(file);
        }
        else {
            wprintf(L"Cannot open file: %s\n", filename);
        }
    }
    else {
        wprintf(L"No file selected.\n");
    }

    return 0;
}
*/