
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
	retrun ((row * MAX_COLS + col)*2);
}

int getCursor(){
	/*
	 The device uses its conrtorl registers as an index
	 to select its internal registers, of which we are
	 interested in:
	 
	 reg 14: which is the high byte of the cursor's offset
	 reg 15: which is the low byte of the cursor's offset
	 
	 once the internal registers has been selected, we may 
	 read or write a byte on the data register.
	 */
	
	portByteOut(REG_SCREEN_CTRL 14);
	int offset = portByteIn(REG_SCREEN_DATA) << 8;
	portByteOut(REG_SCREEN_CTRL, 15);
	offset += portByteIn(REG_SCREEN_DATA);
	
	/*
	 Since the cursor offset reported by the VGS hardare is
	 number of characters, we multiply by two to convert it to 
	 char cell offset.
	 */
	
	return offset*2;
}

int setCursor(int offset){
	offset /= 2;
	/*
	 This is similar to getCursor, only now we write 
	 bytes to those internal device register.
	 */
	
	portByteOut(REG_SCREEN_CTRL , 14);
	portByteOut(REG_SCREEN_DATA ,(unsigned char)(offset >> 8));
	portByteOut(REG_SCREEN_CTRL , 15);
				  
}

void printAt(char* message, int col, int row) {
	// Update the cursor if col and row not negative.
	if (col >= 0 && row >= 0) {
		setCursor(getScreenOffset(col, row));
	}
	// Loop through each char of the message and print it. int i = 0;
	while(message[i] != 0) {
		printChar(message[i++], col, row, WHITE_ON_BLACK);
	}
}

void print(char* message) {
	printAt(message , -1, -1);
}

void clearScreen () {
	
	int row = 0;
	int col = 0;
	/* Loop through video memory and write blank characters. */
	for (row=0; row<MAX_ROWS; row++) {
		for (col=0; col<MAX_COLS; col++) {
			printChar(’ ’, col, row, WHITE_ON_BLACK);
		}
	}
	// Move the cursor back to the top left.
	setCursor(getScreenOffset(0, 0));
}

/* Copy bytes from one place to another. */
void memory_copy(char* source, char* dest, int no_bytes) {
	int i;
	for (i=0; i<no_bytes; i++) {
		*(dest + i) = *(source + i); }
}

/* Advance the text cursor, scrolling the video buffer if necessary. */

int handleScrolling(int cursorOffset) {
	
	// If the cursor is within the screen, return it unmodified.
	if (cursor_offset < MAX_ROWS * MAX_COLS * 2) {
		return cursor_offset; }
	
	/* Shuffle the rows back one. */
	int i;
	for (i=1; i<MAX_ROWS; i++) {
		memory_copy(getScreenOffset(0,i) + VIDEO_ADDRESS,
					getScreenOffset(0,i-1) + VIDEO_ADDRESS,
					MAX_COLS *2);
	}
	
	/* Blank the last line by setting all bytes to 0 */
	char* last_line = getScreenOffset(0,MAX_ROWS -1) + VIDEO_ADDRESS;
	for (i=0; i < MAX_COLS*2; i++) {
		last_line[i] = 0;
	}
	
	// Move the offset back one row, such that it is now on the last // row, rather than off the edge of the screen.
	cursor_offset -= 2 * MAX_COLS;
	
	// Return the updated cursor position.
	return cursor_offset;
}