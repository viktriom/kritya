
#include "kernel/lowLevel.c"

#define VIDEO_ADDRESS 0xb8000
#define MAX_ROWS 25
#define MAX_COLS 80

//Attribute byte for default colour scheme
#define WHITE_OM_BLACK 0x0f

//Screen device I/O port
#define REG_SCREEN_CTRL 0x3D4
#define REG_SCREEN_DATA 0x3D5

void printChar(char character, int col, int row, char attributeByte);
int getScreenOffset(int col, int row);
int getCursor();
int setCursor(int offset);
void printAt(char* message, int col, int row);
void print(char* message);
void clearScreen ();
void memory_copy(char* source, char* dest, int no_bytes);
int handleScrolling(int cursorOffset);

