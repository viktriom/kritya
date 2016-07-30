[bits 16]


switch_to_pm:   ;switch to protected mode

cli 			;We must switch of interrupts until we have set-up the protected move interupt vector otherwise interrupts will run riot.

lgdt [gdt_descriptor] 	;load our global descriptor table which defines the protected mode segment (e.g. for code and data)

mov si,MSG_GDT_LOADED
call print_string_real

mov eax, cr0
or eax, 0x1
mov cr0, eax

mov ebx, MSG_ENTERED_PM
call print_string_pm

;jmp $

jmp CODE_SEG:init_pm	;Make a far jump (i.e.  to a new segment) to our 32-bit code.
                        ;This also forces the CPU to flush its cache of pre-fetched
                        ;and real-mode decoded instruction, which can cause problems.
;jmp $

[bits 32]

;initialize registes and the stack once in PM.

init_pm:

mov ax, DATA_SEG	;Now in PM, our old segments are meaningless.
mov ds, ax          ;so we point our segment registers to the
mov ss, ax          ;data we define is our GDT

mov es, ax
mov fs, ax
mov gs, ax

mov ebp, 0x90000	;Update our stack position so it is right 
mov esp, ebp 		;at the top of the free space.

call BEGIN_PM		;Finally, call some well-known label.

MSG_GDT_LOADED: db "The GDT Loaded Successfully, now attempting to switch the processor",0
MSG_ENTERED_PM: db "Successfully entered into Protected Mode",0
