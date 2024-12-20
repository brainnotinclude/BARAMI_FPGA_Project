#define NOMINMAX
#include "translate_1.h"
#include "FileOpenAPI.h"
#include "translate_2.h"
#include <stdio.h>
#include <windows.h>

extern int registers[8];
extern int pc;

// 변수 배열
extern std::vector<std::string> variableNames;
extern std::vector<int> variableValues;

void gotoxy(int x, int y)
{
	//가로: 0~79 세로 0~24
	
	COORD Pos = { x, y };
	SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), Pos);

}

void BlankPage()
{
	for (int i = 0; i <= 24; i++)
	{
		gotoxy(0, i);
		for (int j = 0; j <= 79; j++)
		printf(" ");
	}
}

void mainPage()
{
	gotoxy(0, 0);
	for (int i = 0; i <= 79; i++)
	{
		printf("=");
	}

	gotoxy(0, 24);
	for (int i = 0; i <= 79; i++)
	{
		printf("=");
	}


	gotoxy(10, 6);
	printf("Barami FPGA Assembler");
	gotoxy(10, 7);
	printf("Enter the mode code you want.");
	gotoxy(10, 9);
	printf("1. Assemble each code instant.");
	gotoxy(10, 10);
	printf("2. Assemble the text file.");
	gotoxy(10, 11);
	printf("3. Exit the Assembler.");

};

void FirstPage()
{
	gotoxy(0, 0);
	for (int i = 0; i <= 79; i++)
	{
		printf("=");
	}

	gotoxy(10, 6);
	printf("Barami FPGA Assembler: Instant Assembler");
	gotoxy(10, 7);
	printf("Enter the single code/declare variable you want.");

	gotoxy(10, 13);
};

int main()
{
	int modeCode = 0;
	std::string line;
	std::vector<std::string> lines(0);
	mainPage();
	do {
		gotoxy(10, 13);
		printf("Enter the code:");
		scanf("%d", &modeCode);
		switch (modeCode) {
		case 1: // 단일 즉시 번역
		{
			gotoxy(10, 15);
			printf("Executing instant Assembler...");
			Sleep(1000);
			//단일 실행 함수
			BlankPage();
			FirstPage();
			std::cin.ignore();
			while (1) {
				getline(std::cin,line);
				lines = { line };
				execute_translate_1(lines);
			}
			break;
		}
		case 2: // 텍스트 파일 번역
		{
			gotoxy(10, 15);
			printf("Executing Text File Assembler...");
			Sleep(1000);
			BlankPage();
			gotoxy(0, 0);
			FileOPENAPI();
			mainPage();
			break;
		}
		case 3:
		{
			gotoxy(10, 15);
			printf("Exiting BARAMI FPGA Assembler...");
			Sleep(100);
			return 0;
			break;
		}
		default:
			BlankPage();
			mainPage();
			gotoxy(10, 14);
			printf("Wrong mode code. Enter again correctly.");
			while (getchar() != '\n');
			break;
		}

	} while (1);


	


	return 0;
}