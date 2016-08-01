
#include "screen.h"

/*
 Prints a character on the screen.
 character : The character to be printed. 
 col, row : the position of the cahracter on the screen.
 attributeByte : the color scheme of the cahracter to be printed.
*/
void printChar(char character, int col, int row, char attributeByte){
	
	/*Pointer to the start of vide memory.*/
	unsigned char *vidmem = (unsigned char *) VIDEO_ADDRESS;
	
	/*If the attribute byte is zero, assume the default style.*/
	if(!attributeByte){
		attributeByte = WHITE_ON_BACK;
	}
	
	/*Get the video memory offset for the screen location.*/
	int offset ;
	
	/*If the column and rows are non-negative use them for offset.*/
	if (col >= 0 && row >= 0) {
		offset = getScreenOffset(col, row);
	/*Else use the current cursor position.*/
	} else{
		offset = getCursor();
	}
	
	/*
	 If we see a new line char, set offset to the end of the current row, 
	 so it will be advance to the frist col of next row.
	 */
	if(character == '\n'){
		int rows = offset / (2*MAX_COLS);
		offset = getScreenOffset(79, rows);
	} else{ /*Else write the char and its attribute byte to video mem at out calculated offset.*/
		vidmem[offset] = character;
		vidmem[offset+1] = attributeByte;
	}
	
	//Update the offset to the next character cell, which is
	//TWO bytes ahead of the curretn cell.
	
	offset += 2;
	
	offset = handleScrolling(offset);	//Make scrolling adjustment, for when we reach the bottom of the screen.
	
	setCursor(offset);		//Update the cursor position on the screen device.
	
}

int getScreenOffset(int col, int row){
	portByteOut(REG_SCREEN_CTRL, 14);
	portByteOut(REG_SCREEN_DATA, (unsigned char)( offset >> 8));
	portByteOut(REF_SCREEN_CTRL, 15);
	cursorOffset -= 2 * MAX_COLS;
	reutnr cursorOffset;
}