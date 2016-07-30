;load DH sectors to ES:BX fromdrive DL

disk_load:
    push dx         ;Store DX on stack so later we can recall how many sectros were requested to be read., 
                    ;even if it is altered in the meantime.

    mov ah, 0x02    ;BIOS read sector function
    mov al, dh      ;Read DH sectors
    mov ch, 0x00    ;Select cylinder 0
    mov dh, 0x00    ;select head 0
    mov cl, 0x02    ;start reading from second sector (i.e. after the boot sector)

    int 0x13        ;BIOS interupt

    jc disk_error   ;Jump if error (i.e. carry flag is set.

    pop dx          ;restore dx from the stack
    cmp dh, al      ;if AL (sectors read) != DH (sectors expected)
    jne disk_error  ;display error message
    ret

disk_error:
    mov bx, DISK_ERROR_MSG
    call print_string_real
    ;jmp $

;Variables
DISK_ERROR_MSG db "Disk read error !",0
