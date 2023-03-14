; USE16
; format binary as 'bin'

; include "include.asm"

; INNUM_BUFFER_SIZE equ 5
; ACTION_BUFFER_SIZE equ 3
; RESULT_BUFFER_SIZE equ 7
; USERINPUT_BUFFER_SIZE equ 10

; include 'programmacros.asm'

; org 1000h

; db 0x7A

; FUNCTABLE EQU 7E00h
; clear                EQU word [7E00h]
; detect_video         EQU word [7E02h]
; print_string         EQU word [7E04h]
; print_symbol         EQU word [7E06h]
; input_string         EQU word [7E08h]
; compare_strings      EQU word [7E0Ah]
; copy_string          EQU word [7E0Ch]
; calculate_string_len EQU word [7E0Eh]
; os_print_digit       EQU word [7E10h]
; os_print_1hex        EQU word [7E12h]
; os_print_2hex        EQU word [7E14h]
; print_hex            EQU word [7E16h]
; print_registers      EQU word [7E18h]
; string_to_int        EQU word [7E1Ah]
; int_to_string        EQU word [7E1Ch]
; dbg_halt_cpu         EQU word [7E1Eh]
; halt_cpu             EQU word [7E20h]


;     print calcgreetings
;     pusha
; calcloop:
;     print firstn
;     input first_num_buf, INNUM_BUFFER_SIZE
;     cmp al, 03h
;     je calcret

;     print secondn
;     input second_num_buf, INNUM_BUFFER_SIZE
;     cmp al, 03h
;     je calcret

;     str_to_i first_num_buf
;     mov word [first_num], ax

;     str_to_i second_num_buf
;     mov word [second_num], ax

;     print actionn
;     input action_buf, ACTION_BUFFER_SIZE
;     cmp_strs action_buf, action_add
;     jnc do_add

;     cmp_strs action_buf, action_sub
;     jnc go_sub

;     cmp_strs action_buf, action_and
;     jnc go_and

;     cmp_strs action_buf, action_or
;     jnc go_or

;     cmp_strs action_buf, action_xor
;     jnc go_xor

;     print inc_act, ln

;     jmp calcloop
; calcret:
;     popa
;     ret

; do_add:
;     mov ax, word [first_num]
;     mov bx, word [second_num]
;     add ax, bx

;     mov si, result_buf
;     call int_to_string
;     jmp print_res

; go_sub:
;     mov ax, word [first_num]
;     mov bx, word [second_num]
;     sub ax, bx

;     mov si, result_buf
;     call int_to_string
;     jmp print_res

; go_and:
;     mov ax, word [first_num]
;     mov bx, word [second_num]
;     and ax, bx

;     mov si, result_buf
;     call int_to_string
;     jmp print_res

; go_or:
;     mov ax, word [first_num]
;     mov bx, word [second_num]
;     or  ax, bx

;     mov si, result_buf
;     call int_to_string
;     jmp print_res

; go_xor:
;     mov ax, word [first_num]
;     mov bx, word [second_num]
;     xor ax, bx

;     mov si, result_buf
;     call int_to_string
;     jmp print_res

; print_res:
;     print resultn, result_buf, ln
;     jmp calcloop

; Sdata:
;     calcgreetings db "Welcome to the calculator", 0Dh, 0Ah, 0
;     goodbye db "Uhadi!", 0

;     firstn db "Enter first number:", 0
;     secondn db "Enter second number:", 0
;     actionn db "Enter action:", 0
;     inc_act db "Incrorrect action!", 0
;     resultn db "Result - ", 0

;     action_add db "add", 0
;     action_sub db "sub", 0
;     action_and db "and", 0
;     action_or  db "or" , 0
;     action_xor db "xor", 0

;     zx db "0x", 0
;     ln db 0Dh, 0Ah, 0

;     first_num_buf:
;         times INNUM_BUFFER_SIZE db 0
;     db 0
;     first_num dw 0

;     second_num_buf:
;         times INNUM_BUFFER_SIZE db 0
;     db 0
;     second_num dw 0

;     action_buf:
;         times ACTION_BUFFER_SIZE db 0
;     db 0

;     result_buf:
;         times RESULT_BUFFER_SIZE db 0
;     db 0

include 'include.asm'

program:
    print greetings, ln
.loop:
    print prefix_1
    input innum_buffer, INNUM_BUFFER_SIZE
    cmp al, 03h
    je .end
    str_to_i innum_buffer
    push ax

    print prefix_2
    input innum_buffer, INNUM_BUFFER_SIZE
    cmp al, 03h
    je .end
    str_to_i innum_buffer
    push ax

    print prefix_act
    input innum_buffer, INNUM_BUFFER_SIZE
    cmp al, 03h
    je .end

    cmp_strs innum_buffer, act_add
    jnc do_add
    cmp_strs innum_buffer, act_sub
    jnc do_sub
    cmp_strs innum_buffer, act_div
    jnc do_div
    cmp_strs innum_buffer, act_mul
    jnc do_mul

    pop ax
    pop ax

    print inc_act, ln

    jmp .loop
.end:
    ret

do_add:
    jmp print_result
do_sub:
    jmp print_result
do_div:
    jmp print_result
do_mul:
    jmp print_result
print_result:
    jmp program.loop

    greetings db "Welcome to the calculator. List of actions - +-/*", 0
    prefix_1 db "First number>", 0
    prefix_2 db "Second number>", 0
    prefix_act db "Action>", 0
    inc_act db "Incorrect action!", 0
    ln db 0Dh, 0Ah, 0
    act_add db "+", 0
    act_sub db "-", 0
    act_div db "/", 0
    act_mul db "*", 0

    innum_buffer:
        times INNUM_BUFFER_SIZE db 0
    db 0
