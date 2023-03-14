include 'include.asm'

start:
    len arg1
    cmp ax, 0
    je progret.usage
    mov bx, arg1
    call find_file
    jc progret.fnf
    mov word [file_FS_offset], si
    mov si, file_offset
    jmp view_text.prt
progret.usage:
    print usage, ln
    jmp progret
progret.fnf:
    print fnf, ln
    jmp progret
progret:
    ret

view_text.prt:
    mov word [xpos], 0
    jmp print_symb
    view_text.prt.continue:
    inc si
    jmp view_text.prt
view_text.waiting:
    call wait_key
    cmp al, 'q'
    je progret
    jmp view_text.prt

print_symb:
    mov dl, [xpos]
    mov dh, [ypos]
    cmp dl, 0
    je print_symb.mb_end
    print_symb.continue:
    mov al, [si]
    call print_symbol
    pusha
    cmp [xpos], 24
    je print_symb.mov_ln
    mov al, [xpos]
    inc al
    mov [xpos], al
    print_symb.continue2:
    popa
    printh word [xpos]
    jmp view_text.prt.continue
print_symb.mov_ln:
    mov al, [ypos]
    inc al
    mov [ypos], al
    mov byte [xpos], 0
    jmp print_symb.continue2
print_symb.mb_end:
    cmp dh, 25
    je view_text.waiting
    jmp print_symb.continue

    usage db "Usage: viewer.bin <filename>", 0
    fnf   db "File not found.", 0
    ln db 0Dh, 0Ah, 0
    file_FS_offset dw 0
    xpos db 0
    ypos db 0

times 1024-($-$$) db 0
file_offset:
times 2000 db "A"