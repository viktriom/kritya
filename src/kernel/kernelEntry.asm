;exsures that we jump straight into kernel's entry function

[bits 32]           ;we are in the protected mode
[extern main]       ;Declare that we will be refrencing an external symbol 'main' 
                    ;So inliner can resolve it duing linking.

call main           ;invoke the 'main' function in our c code.

jmp $              ;hang for ever when we return from kernal
