;This function prints the data present in the al register to 
;the screen

print_string_real:
pusha
.repeat_print_real:
lodsb
cmp al,0
je .done_print_real
mov ah,0x0e
int 0x10
jmp .repeat_print_real

.done_print_real:
popa
ret

