
;A boot sector program that enters 32-bits projected mode.

[org 0x7c00]

KERNEL_OFFSET equ 0x1000    ;This is the memory offset to which we will load our kernel.

mov bp, 0x9000		;setting up the stack
mov sp, bp

mov si, MSG_REAL_MODE
call print_string_real

call load_kernel        ;Call routine to laod the kernel.

call switch_to_pm		;Note that we never return from here.

;jmp $

%include "includes/printString.asm"
%include "includes/gdt.asm"
%include "includes/printStringPm.asm"
%include "includes/protectedMode.asm"
%include "includes/diskLoad.asm"

;This is where we arrive after switching to and initializing protected mode.

[bits 16]

load_kernel:
    mov si, MSG_LOAD_KERNEL     ;Display loading kernel message
    call print_string_real		

    mov bx, KERNEL_OFFSET
    mov dh, 15
    mov dl, [BOOT_DRIVE]
    call disk_load

    ret

[bits 32]

BEGIN_PM:

    mov ebx, MSG_PROT_MODE
    call print_string_pm		;user our 32-bit print routine

    call KERNEL_OFFSET

    ;jmp $

;Global Variables

BOOT_DRIVE db 0
MSG_REAL_MODE: db "Started in 16 bit Real Mode",0
MSG_PROT_MODE: db "Successfully landed in 32-bit protected mode",0
MSG_TEMP: db "BEGIN PM Called",0
MSG_LOAD_KERNEL db "Loading kernel into memory.",0

;Finaly the boot loader padding (the magic number)
times 510-($-$$) db 0
dw 0xaa55