secstage:
    mov ah, 02h
    mov al, [filetable_ff+3]
    mov dl, [BOOT_DRIVE]
    mov ch, [filetable_ff]
    mov dh, [filetable_ff+1]
    mov cl, [filetable_ff+2]
    mov bx, main
    int 13h

    mov al, [BOOT_DRIVE]
    jc .error

    call main

    call dbg_halt_cpu
.error:
    cmp cl, 0x0
    je .notfound
    cmp cl, 0x20
    je .notfound
    jmp booterror

.notfound:
    mov ax, 1301h
    mov bx, 7
    xor dx, dx
    mov bp, .notfoundmsg
    mov cx, 22
    int 10h
    cli
    hlt

    .notfoundmsg db '"kernel.bin" not found'

times 2560-($-$$) db 0
