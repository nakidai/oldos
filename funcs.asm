; Clear the screen and set cursor position to (0, 0)
clear:
    push ax
    mov ax, 03h
    int 10h
    mov ax, 200h
    xor dx, dx
    int 10h
    pop ax
    ret

; Detect display. Video mode 0 if no display,
; 1 if monochrome display, 2 if colour display
detect_video:
    push ax

    mov ax, 30h
    and ax, DETECTED_HARDWARE

    cmp ax, 20h
    mov [VIDEO_MODE], 2

    cmp ax, 30h
    mov [VIDEO_MODE], 1

    pop ax
    ret

; Print terminated string
;
; DS:SI - Pointer on string
print_string:
    pusha
    mov cx, 1
    mov bh, 0Fh
print_string.print:
    lodsb

    cmp al, 0
    je print_string.finish

    call print_symbol
    jmp print_string.print
print_string.finish:
    popa
    ret

; Split user input on 4 parts by space
split_str_4_space:
    push ax
    push bx
    push cx
    push dx
    push si
    reset_buf cmd.userinput_com, ARGUMENT_BUFFER_SIZE
    reset_buf cmd.userinput_arg1, ARGUMENT_BUFFER_SIZE
    reset_buf cmd.userinput_arg2, ARGUMENT_BUFFER_SIZE
    reset_buf cmd.userinput_arg3, ARGUMENT_BUFFER_SIZE
    mov bx, cmd.userinput_com
    mov si, cmd.userinput_buf

split_str_4_space.lp:
    mov al, [si]
    mov [bx], al

    inc bx
    inc si

    cmp byte [si], ' '
    je split_str_4_space.change_part
    cmp byte [si], 0
    je split_str_4_space.rtt

    jmp split_str_4_space.lp
split_str_4_space.rtt:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    mov byte [split_str_4_space.part], 1
    ret
split_str_4_space.change_part:
    cmp byte [split_str_4_space.part], 1
    je split_str_4_space.change_part.part1
    cmp byte [split_str_4_space.part], 2
    je split_str_4_space.change_part.part2
    cmp byte [split_str_4_space.part], 3
    je split_str_4_space.change_part.part3
    cmp byte [split_str_4_space.part], 4
    je split_str_4_space.change_part.part4

        split_str_4_space.part db 1

split_str_4_space.change_part.part1:
    inc [split_str_4_space.part]
    mov bx, cmd.userinput_arg1
    inc si
    jmp split_str_4_space.lp
split_str_4_space.change_part.part2:
    inc [split_str_4_space.part]
    mov bx, cmd.userinput_arg2
    inc si
    jmp split_str_4_space.lp
split_str_4_space.change_part.part3:
    inc [split_str_4_space.part]
    mov bx, cmd.userinput_arg3
    inc si
    jmp split_str_4_space.lp
split_str_4_space.change_part.part4:
    jmp split_str_4_space.rtt

; Print symbol
;
; AL - symbol
print_symbol:
    pusha

    xor bx, bx
    mov cx, 1
    mov ah, 0Eh
    int 10h

    popa
    ret


; Reset buffer
; DS:SI - buffer
; CX - Length
reset_buffer:
    push si
    push cx
reset_buffer.lp:
    mov byte [ds:si], 0
    inc si

    dec cx
    cmp cx, 0
    jne reset_buffer.lp
reset_buffer.nd:
    pop cx
    pop si
    ret

; Input string
;
; DS:SI - Pointer on buffer
; CX - Buffer length
; ---
; AX - Last pressed key
input_string:
    push bx
    mov bx, 0

    input_string.reset_buffer:
        push si
        push cx
    input_string.reset_buffer.lp:
        mov byte [ds:si], 0
        inc si

        dec cx
        cmp cx, 0
        jne input_string.reset_buffer.lp
    input_string.reset_buffer.nd:
        pop cx
        pop si

input_string.processing:
    xor ah, ah
    int 16h

    cmp al, 0Dh
    je input_string.ent

    cmp al, 08h
    je input_string.backspace

    cmp al, 03h
    je input_string.ctrlc

    call print_symbol

    mov [ds:si+bx], al
    inc bx

    cmp bx, cx
    je input_string.ent

    jmp input_string.processing
input_string.backspace:
    cmp bx, 0
    je input_string.processing

    mov ah, 0Eh
    int 10h

    mov al, ' '
    int 10h

    mov al, 08h
    int 10h

    dec bx
    mov byte [ds:si+bx], 0

    jmp input_string.processing
input_string.ent:
    pop bx
    xor ah, ah
    print ln
    ret
input_string.ctrlc:
    jmp input_string.ent

; Compare strings
;
; DS:SI - Pointer on first string
; DS:BX - Pointer on second string
; ---
; Carry flag - 1 if strings are not equal
compare_strings:
    push ax
    push bx
    push si
compare_strings.comp:
    lodsb

    cmp [bx], al
    jne compare_strings.not_equal
    cmp al, 0
    je compare_strings.equal

    inc bx

    jmp compare_strings.comp
compare_strings.equal:
    clc
    jmp compare_strings.return
compare_strings.not_equal:
    stc
    jmp compare_strings.return
compare_strings.return:
    pop si
    pop bx
    pop ax
    ret

; Copies string
;
; DS:SI - Pointer on memory from where copy
; DS:BX - Pointer on memory where copy
copy_string:
    push si
    push bx
    push ax
copy_string.lp:
    lodsb

    cmp al, 0
    je copy_string.ed

    mov byte [bx], al

    inc bx

    jmp copy_string.lp
copy_string.ed:
    pop ax
    pop bx
    pop si
    ret

; Calculate len of string
;
; DS:SI - Pointer on string
; ---
; AX - Len of string
calculate_string_len:
    push si
    xor ax, ax
    push ax
calculate_string_len.lp:
    lodsb
    cmp al, 0
    je calculate_string_len.ed

    pop ax
    inc ax
    push ax

    jmp calculate_string_len.lp
calculate_string_len.ed:
    pop ax
    pop si
    ret

; ------------------------------------------------------------------
; os_print_digit -- Displays contents of AX as a single digit
; Works up to base 37, ie digits 0-Z
; IN: AX = "digit" to format and print

os_print_digit:
    pusha

    cmp ax, 9                       ; There is a break in ASCII table between 9 and A
    jle .digit_format

    add ax, 'A'-'9'-1       ; Correct for the skipped punctuation

.digit_format:
    add ax, "0"         ; 0 will display as '0', etc.   

    mov ah, 0Eh         ; May modify other registers
    int 10h

    popa
    ret


; ------------------------------------------------------------------
; os_print_1hex -- Displays low nibble of AL in hex format
; IN: AL = number to format and print

os_print_1hex:
    pusha

    and ax, 0Fh         ; Mask off data to display
    call os_print_digit

    popa
    ret

; Print AL in hex
;
; AL - Number to print
os_print_2hex:
    pusha

    push ax             ; Output high nibble
    shr ax, 4
    call os_print_1hex

    pop ax              ; Output low nibble
    call os_print_1hex

    popa
    ret


; Print AX in hex
;
; AX - Number to print
print_hex:
    pusha

    push ax             ; Output high byte
    mov al, ah
    call os_print_2hex

    pop ax              ; Output low byte
    call os_print_2hex

    popa
    ret

; Print values of registers to screen
;
; AX, BX, CX, DX, SI, DI, ES, DS, SS, FLAGS - Registers to print
print_registers:
    pushf
    push ss
    push ds
    push es
    push di
    push si
    push dx
    push cx
    push bx

    print print_registers.axd
    call print_hex
    print print_registers.h

    pop ax
    print print_registers.bxd
    call print_hex
    print print_registers.h, ln

    pop ax
    print print_registers.cxd
    call print_hex
    print print_registers.h

    pop ax
    print print_registers.dxd
    call print_hex
    print print_registers.h, ln

    pop ax
    print print_registers.sid
    call print_hex
    print print_registers.h

    pop ax
    print print_registers.did
    call print_hex
    print print_registers.h, ln

    pop ax
    print print_registers.esd
    call print_hex
    print print_registers.h

    pop ax
    print print_registers.dsd
    call print_hex
    print print_registers.h, ln

    pop ax
    print print_registers.ssd
    call print_hex
    print print_registers.h

    pop ax
    print print_registers.fd
    call print_hex
    print print_registers.h, ln

    ret

; ------------------------------------------------------------------
; os_string_to_int -- Convert decimal string to integer value
; IN: SI = string location (max 5 chars, up to '65536')
; OUT: AX = number
string_to_int:
    pusha

    mov ax, si          ; First, get length of string
    call os_string_length

    add si, ax          ; Work from rightmost char in string
    dec si

    mov cx, ax          ; Use string length as counter

    mov bx, 0           ; BX will be the final number
    mov ax, 0


    ; As we move left in the string, each char is a bigger multiple. The
    ; right-most character is a multiple of 1, then next (a char to the
    ; left) a multiple of 10, then 100, then 1,000, and the final (and
    ; leftmost char) in a five-char number would be a multiple of 10,000

    mov word [.multiplier], 1   ; Start with multiples of 1

.loop:
    mov ax, 0
    mov byte al, [si]       ; Get character
    sub al, 48          ; Convert from ASCII to real number

    mul word [.multiplier]      ; Multiply by our multiplier

    add bx, ax          ; Add it to BX

    push ax             ; Multiply our multiplier by 10 for next char
    mov word ax, [.multiplier]
    mov dx, 10
    mul dx
    mov word [.multiplier], ax
    pop ax

    dec cx              ; Any more chars?
    cmp cx, 0
    je .finish
    dec si              ; Move back a char in the string
    jmp .loop

.finish:
    mov word [.tmp], bx
    popa
    mov word ax, [.tmp]

    ret


    .multiplier dw 0
    .tmp        dw 0

    os_string_length:
        pusha

        mov bx, ax          ; Move location of string to BX

        mov cx, 0           ; Counter

    .more:
        cmp byte [bx], 0        ; Zero (end of string) yet?
        je .done
        inc bx              ; If not, keep adding
        inc cx
        jmp .more


    .done:
        mov word [.tmp_counter], cx ; Store count before restoring other registers
        popa

        mov ax, [.tmp_counter]      ; Put count back into AX before returning
        ret

        .tmp_counter    dw 0

; Convert unsigned int to string
;
; AX - Num to convert
; SI - Where save string
; ---
; SI - Pointer to string with converted num
int_to_string:
    push cx
    push bx
    push di
    push ax

    mov cx, 0
    mov bx, 10          ; Set BX 10, for division and mod
    mov di, si         ; Get our pointer ready

int_to_string.push:
    mov dx, 0
    div bx              ; Remainder in DX, quotient in AX
    inc cx              ; Increase pop loop counter
    push dx             ; Push remainder, so as to reverse order when popping
    test ax, ax         ; Is quotient zero?
    jnz int_to_string.push           ; If not, loop again
int_to_string.pop:
    pop dx              ; Pop off values in reverse order, and add 48 to make them digits
    add dl, '0'         ; And save them in the string, increasing the pointer each time
    mov [di], dl
    inc di
    dec cx
    jnz int_to_string.pop

    mov byte [di], 0        ; Zero-terminate string

    mov si, di
    pop ax
    pop di
    pop bx
    pop cx
    ret

; Find file on disk from filename
; BX - filename
; ---
; SI - filename position in table
; CF - 1 if file not exist
find_file:
    push bx
    push ax
    push cx
    mov cx, TABLE_SIZE
    mov si, filetable
    add si, 4
    mov [find_file.fn_offset], bx
find_file.lp:

    mov bx, [find_file.fn_offset]
    call compare_strings
    jnc find_file.found

    dec cx
    cmp cx, 0
    je find_fileret

    mov bx, 12
    ; len si
    xor ax, ax
    sub bx, ax
    xchg ax, bx
    add si, ax
    add si, 4
    ; mov al, [si]
    ; cmp al, 0
    je find_fileret
    jmp find_file.lp
find_file.found:
    sub si, 4
    pop cx
    pop ax
    pop bx
    clc
    ret
find_fileret:
    xor si, si
    pop cx
    pop ax
    pop bx
    stc
    ret

    find_file.fn_offset dw 0

; Remove file
; BX - filename
; ---
; CF - 1 if file not exist
remove_file:
    push ax
    push si
    push bx

    call find_file
    jc remove_file.rtt

    mov dword [si], 0
    add si, 2
    mov dword [si], 0
    add si, 2
    mov dword [si], 0
    add si, 2
    mov dword [si], 0
    add si, 2
    mov dword [si], 0
    add si, 2
    mov dword [si], 0
    add si, 2
    mov dword [si], 0
    add si, 2
    mov dword [si], 0

    pop bx
    pop si
    pop ax
    ret
remove_file.rtt:
    pop bx
    pop si
    pop ax
    ret

; Append file to FS table
; AL - Cylinder
; AH - Head
; BL - sector
; BH - Size
; SI - Pointer on name (Max 11 chars)
append_file:
    pusha
    mov [append_file.cylinder], al
    mov [append_file.head], ah
    mov [append_file.sector], bl
    mov [append_file.size], bh
    mov word [append_file.name_os], si
    mov cx, TABLE_SIZE
    mov si, filetable+4
append_file.lp:
    cmp byte [si], 0
    je append_file.write
    add si, 16
    dec cx
    cmp cx, 0
    je append_file.cannot
    jmp append_file.lp
append_file.nd:
    popa
    ret
append_file.write:
    sub si, 4
    mov al, [append_file.cylinder]
    mov ah, [append_file.head]
    mov bl, [append_file.sector]
    mov bh, [append_file.size]
    mov byte [si], al
    mov byte [si+1], ah
    mov byte [si+2], bl
    mov byte [si+3], bh
    add si, 4
    mov bx, si
    mov si, word [append_file.name_os]
    call copy_string
    clc
    call write_table
    jmp append_file.nd
append_file.cannot:
    stc
    jmp append_file.nd

    append_file.cylinder db 0
    append_file.head     db 0
    append_file.sector   db 0
    append_file.size     db 0
    append_file.name_os  dw 0

; Rename file in FS table
; SI - Filename
; BX - To what filename change
rename_file:
    pusha
    mov word [rename_file.fst], si
    mov word [rename_file.snd], bx
    mov bx, si
    call find_file
    jc rename_file.notfound
    add si, 4
    push si
    reset_buf si, 12
    pop si
    mov bx, si
    mov si, word [rename_file.snd]
    call copy_string
    rename_file.notfound:
    popa
    ret

    rename_file.fst dw 0
    rename_file.snd dw 0

; Read file and load to memory
; SI - File in FS table
; BX - Where load
load_file:
    pusha
    mov ah, 02h
    mov al, [si+3]
    mov dl, [BOOT_DRIVE]
    mov ch, [si]
    mov dh, [si+1]
    mov cl, [si+2]
    int 13h
    popa
    ret

    ; loadoffset dw 0

; Write file and load to memory
; SI - File in FS table
; CX - Where
save_file:
    pusha
    popa
    ret

; Read FS table from disk
read_table:
    pusha
    mov ah, 02h
    mov al, 2
    mov dl, [BOOT_DRIVE]
    mov ch, 0
    mov dh, 0
    mov cl, 3
    mov bx, filetable
    int 13h
    popa
    ret

; Write FS table to disk
write_table:
    pusha
    mov ah, 03h 
    mov al, 2
    mov dl, [BOOT_DRIVE]
    mov ch, 0
    mov dh, 0
    mov cl, 3
    mov bx, filetable
    int 13h
    popa
    ret

; Change table
; SI - table in FS table (0 - return to previous table)
change_table:
    pusha
    mov ah, 02h
    mov al, 4
    mov dl, [BOOT_DRIVE]
    mov ch, [si]
    mov dh, [si+1]
    mov cl, [si+2]
    mov bx, 0x8000
    int 13h
    popa
    ret



wait_key:
    mov ah, 11h
    int 16h

    jnz wait_key.key_pressed

    hlt
    jmp wait_key

wait_key.key_pressed:
    mov ah, 10h
    int 16h
    ret

; Copy memory from A to B
; SI - A
; BX - B
; CX - Number of bytes to copy
copy_memory:
    pusha
copy_memory.lp:
    cmp cx, 0
    je copy_memory.nd
    lodsb
    mov [bx], al
    inc bx
    dec cx
    jmp copy_memory.lp
copy_memory.nd:
    popa
    ret

; Get cursor position
; ---
; DL - X
; DH - Y
get_cursor_pos:
    push ax
    push cx
    push bx
    mov ah, 03h
    xor bx, bx
    int 10h
    pop bx
    pop cx
    pop ax
    ret

; Set cursor position
; DL - X
; DH - Y
set_cursor_pos:
    push ax
    push bx
    mov ah, 02h
    xor bx, bx
    int 10h
    pop bx
    pop ax
    ret

; Print values of registers and halt cpu
dbg_halt_cpu:
    call print_registers
    call halt_cpu

; Shows goodbye message and stops the CPU
halt_cpu:
    print ln, goodbye
    cli
    hlt
