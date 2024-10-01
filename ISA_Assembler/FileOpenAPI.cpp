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


// ��Ƽ����Ʈ ���ڿ��� �����ڵ�� ��ȯ�ϴ� �Լ�
std::wstring convertToWideString(const std::string& str) {
    int size_needed = MultiByteToWideChar(CP_ACP, 0, str.c_str(), (int)str.size(), NULL, 0);
    std::wstring wstr(size_needed, 0);
    MultiByteToWideChar(CP_ACP, 0, str.c_str(), (int)str.size(), &wstr[0], size_needed);
    return wstr;
}

// ���� ���� ��ȭ ����
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

// ���� ���� ��ȭ ����
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

// ���� ���� �б�
std::string readFromFile(const std::wstring& filePath) {
    std::ifstream inFile(filePath, std::ios::binary);
    if (!inFile) {
        std::wcerr << L"������ �� �� �����ϴ�: " << filePath << std::endl;
        return "";
    }

    std::string content((std::istreambuf_iterator<char>(inFile)),
        std::istreambuf_iterator<char>());
    inFile.close();
    return content;
}

// ���� ���� ����
void writeToFile(const std::wstring& filePath, const std::string& content) {
    std::ofstream outFile(filePath, std::ios::binary);
    if (!outFile) {
        std::wcerr << L"������ ������ �� �����ϴ�: " << filePath << std::endl;
        return;
    }

    outFile << content;
    outFile.close();
}

// ���ڿ��� �� ������ ������ vector�� ��ȯ�ϴ� �Լ�
std::vector<std::string> splitIntoLines(const std::string& content) {
    std::vector<std::string> lines;
    std::istringstream stream(content);
    std::string line;
    while (std::getline(stream, line)) {
        lines.push_back(line);
    }
    return lines;
}

// execute_translate2 �Լ� (����)
/*
void execute_translate2(std::vector<std::string>& lines) {
    for (const auto& line : lines) {
        std::cout << "Translated Line: " << line << std::endl;  // ���⼭ ������ ����� ó��
    }
}
*/
int FileOPENAPI() {
    // ���� ���� ��ȭ ���ڸ� ����� ���� ����
    std::wstring openPath = openFileDialog();
    if (openPath.empty()) {
        std::wcerr << L"������ ���õ��� �ʾҽ��ϴ�." << std::endl;
        return 1;
    }

    // ������ ���Ͽ��� ���� �б�
    std::string fileContent = readFromFile(openPath);
    if (fileContent.empty()) {
        std::wcerr << L"���� ������ ����ְų� �б� ������ �߻��߽��ϴ�." << std::endl;
        return 1;
    }

    // ���� ������ �� ������ �и��Ͽ� ���ͷ� ��ȯ
    std::vector<std::string> lines = splitIntoLines(fileContent);

    // ���� ������ execute_translate2 �Լ��� �ѱ�
    execute_translate_2(lines);

    // ȭ�鿡 ����� ������ �ٽ� ���Ͽ� ����
    std::string modifiedContent = output_translate_2.str();

   /* std::string modifiedContent;
    for (const auto& line : lines) {
        modifiedContent += line + "\n";  // ��ȯ�� ������ �ٽ� �ϳ��� ���ڿ��� ����
    }
    */

    // ���� ���� ��ȭ ���ڸ� ����� ���� ���� ��ġ ����
    std::wstring savePath = saveFileDialog();
    if (savePath.empty()) {
        std::wcerr << L"���� ���� ��ġ�� ���õ��� �ʾҽ��ϴ�." << std::endl;
        return 1;
    }

    // ���õ� ���Ͽ� ���� ����
    writeToFile(savePath, modifiedContent);

    std::wcout << L"������ ����Ǿ����ϴ�: " << savePath << std::endl;

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