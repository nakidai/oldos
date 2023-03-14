; main:
;     call clear
;     print greetings
; mainloop:
;     print parol

;     input input_data, BUFFER_SIZE

;     cmp_strs right_password, input_data
;     jnc correct
;     print incorrect_password, ln

;     jmp mainloop

; correct:
;     print password_done
;     jmp dbg_halt_cpu

main:
    call clear
    print greetings, ln
mainloop:
    push ax
    xor ax, ax
    mov al, [BOOT_DRIVE]
    call its
    pop ax
    print cmd.prefix

    input cmd.userinput_buf, USERINPUT_BUFFER_SIZE
    cmp al, 03h
    je mainret
    call split_str_4_space

    cmp_strs cmd.userinput_com, cmd.cmd_help
    jnc command.help

    cmp_strs cmd.userinput_com, cmd.cmd_mrun
    jnc command.mrun

    cmp_strs cmd.userinput_com, cmd.cmd_stdfuncs
    jnc command.stdfuncs

    cmp_strs cmd.userinput_com, cmd.cmd_showmem
    jnc command.showmem

    cmp_strs cmd.userinput_com, cmd.cmd_writemem
    jnc command.writemem

    cmp_strs cmd.userinput_com, cmd.cmd_loadmem
    jnc command.loadmem

    cmp_strs cmd.userinput_com, cmd.cmd_exit
    jnc command.shutdown

    cmp_strs cmd.userinput_com, cmd.cmd_rfd
    jnc command.rfd

    cmp_strs cmd.userinput_com, cmd.cmd_dir
    jnc command.dir

    cmp_strs cmd.userinput_com, cmd.cmd_rm
    jnc command.rm

    cmp_strs cmd.userinput_buf, cmd.cmd_reboot 
    jnc command.reboot

    ; cmp_strs cmd.userinput_com, cmd.cmd_addlink
    ; jnc command.addlink

    len cmd.userinput_com
    cmp ax, 0
    je mainloop.continue

    mov bx, cmd.userinput_com
    call find_file
    jnc command.run

    mainloop.continue:

    print cmd.inc_com

    jmp mainloop
mainret:
    ret

command.help:
    print cmd.cmd_help_desc, ln
    jmp mainloop


command.mrun:
    print cmd.cmd_mrun_desc
    input cmd.cmd_mrun_buf, INNUM_BUFFER_SIZE
    cmp al, 03h
    je mainloop

    str_to_i cmd.cmd_mrun_buf
    add ax, 7C00h
    mov word [cmd.cmd_mrun_offset], ax
    call ax

    jmp mainloop


command.stdfuncs:
    print cmd.cmd_stdfuncs_desc, ln
    mov si, functable
    push si
command.stdfuncs.lp:
    pop si
    mov ax, [si]
    add si, 2
    push si
    cmp ax, 0
    je command.stdfuncsret
    sub ax, 7C00h
    call its
    print space

    pop si
    mov ax, [si]
    add si, 2
    push si
    cmp ax, 0
    je command.stdfuncsret_med
    sub ax, 7C00h
    call its
    print space

    pop si
    mov ax, [si]
    add si, 2
    push si
    cmp ax, 0
    je command.stdfuncsret_med
    sub ax, 7C00h
    call its
    print ln
    jmp command.stdfuncs.lp
command.stdfuncsret_med:
    print ln
    pop si
    jmp mainloop
command.stdfuncsret:
    pop si
    jmp mainloop


command.showmem:
    len cmd.userinput_arg2
    cmp ax, 0
    je command.showmem_usageret
    str_to_i cmd.userinput_arg1
    add ax, 7C00h
    mov si, ax
    push si

    str_to_i cmd.userinput_arg2
    mov cx, ax

command.showmem.lp:
    pop si
    mov ax, [si]
    xchg ah, al
    add si, 2
    push si
    call print_hex
    print space

    pop si
    mov ax, [si]
    xchg ah, al
    add si, 2
    push si
    call print_hex
    print space

    pop si
    mov ax, [si]
    xchg ah, al
    add si, 2
    push si
    call print_hex
    print space

    pop si
    mov ax, [si]
    xchg ah, al
    add si, 2
    push si
    call print_hex
    print space

    pop si
    mov ax, [si]
    xchg ah, al
    add si, 2
    push si
    call print_hex
    print space

    pop si
    mov ax, [si]
    xchg ah, al
    add si, 2
    push si
    call print_hex
    print space

    pop si
    mov ax, [si]
    xchg ah, al
    add si, 2
    push si
    call print_hex
    print space

    pop si
    mov ax, [si]
    xchg ah, al
    add si, 2
    push si
    call print_hex
    print ln

    dec cx
    cmp cx, 0
    je mainloop

    jmp command.showmem.lp
command.showmem_usageret:
    print cmd.cmd_showmem_usage, ln
    jmp mainloop


command.writemem:
    print cmd.cmd_writemem_desc
    input cmd.userinput_buf, INNUM_BUFFER_SIZE
    cmp al, 03h
    je mainloop
    str_to_i cmd.userinput_buf
    add ax, 7C00h
    push ax

    print cmd.cmd_writemem_desc1
    input cmd.userinput_buf, INNUM_BUFFER_SIZE
    cmp al, 03h
    je mainloop
    str_to_i cmd.userinput_buf
    pop si

    mov [si], ax
    jmp mainloop


command.loadmem:
    print cmd.cmd_loadmem_desc
    input cmd.userinput_buf, SHNUM_BUFFER_SIZE
    cmp al, 03h
    je mainloop
    str_to_i cmd.userinput_buf
    mov byte [cmd.cmd_loadmem_sectors], al

    print cmd.cmd_loadmem_desc1
    input cmd.userinput_buf, SHNUM_BUFFER_SIZE
    cmp al, 03h
    je mainloop
    str_to_i cmd.userinput_buf
    mov byte [cmd.cmd_loadmem_drive], al

    print cmd.cmd_loadmem_desc2
    input cmd.userinput_buf, SHNUM_BUFFER_SIZE
    cmp al, 03h
    je mainloop
    str_to_i cmd.userinput_buf
    mov byte [cmd.cmd_loadmem_cylinder], al

    print cmd.cmd_loadmem_desc3
    input cmd.userinput_buf, SHNUM_BUFFER_SIZE
    cmp al, 03h
    je mainloop
    str_to_i cmd.userinput_buf
    mov byte [cmd.cmd_loadmem_head], al

    print cmd.cmd_loadmem_desc4
    input cmd.userinput_buf, SHNUM_BUFFER_SIZE
    cmp al, 03h
    je mainloop
    str_to_i cmd.userinput_buf
    mov byte [cmd.cmd_loadmem_loadoffset], al

    print cmd.cmd_loadmem_desc5
    input cmd.userinput_buf, INNUM_BUFFER_SIZE
    cmp al, 03h
    je mainloop
    str_to_i cmd.userinput_buf
    mov word [cmd.cmd_loadmem_saveoffset], ax

    mov ah, 02h
    mov al, byte [cmd.cmd_loadmem_sectors]
    mov dl, byte [cmd.cmd_loadmem_drive]
    mov ch, byte [cmd.cmd_loadmem_cylinder]
    mov dh, byte [cmd.cmd_loadmem_head]
    mov cl, byte [cmd.cmd_loadmem_loadoffset]
    mov bx, word [cmd.cmd_loadmem_saveoffset]
    add bx, 7C00h
    int 13h
    jc command.loadmem_err
    jmp mainloop
command.loadmem_err:
    call print_registers
    print cmd.cmd_loadmem_loaderr, ln
    jmp mainloop

command.shutdown:
    mov ax, 5307h
    mov bx, 01h
    mov cx, 03h
    int 15h
    ret

command.rfd:
    print cmd.cmd_rfd_desc
    input cmd.userinput_buf, SHNUM_BUFFER_SIZE
    cmp al, 03h
    je mainloop
    str_to_i cmd.userinput_buf
    mov byte [cmd.cmd_loadmem_sectors], al

    print cmd.cmd_rfd_desc1
    input cmd.userinput_buf, SHNUM_BUFFER_SIZE
    cmp al, 03h
    je mainloop
    str_to_i cmd.userinput_buf
    mov byte [cmd.cmd_loadmem_drive], al

    print cmd.cmd_loadmem_desc2
    input cmd.userinput_buf, SHNUM_BUFFER_SIZE
    cmp al, 03h
    je mainloop
    str_to_i cmd.userinput_buf
    mov byte [cmd.cmd_loadmem_cylinder], al

    print cmd.cmd_loadmem_desc3
    input cmd.userinput_buf, SHNUM_BUFFER_SIZE
    cmp al, 03h
    je mainloop
    str_to_i cmd.userinput_buf
    mov byte [cmd.cmd_loadmem_head], al

    print cmd.cmd_rfd_desc4
    input cmd.userinput_buf, SHNUM_BUFFER_SIZE
    cmp al, 03h
    je mainloop
    str_to_i cmd.userinput_buf
    mov byte [cmd.cmd_loadmem_loadoffset], al

    mov ah, 02h
    mov al, byte [cmd.cmd_loadmem_sectors]
    mov dl, byte [cmd.cmd_loadmem_drive]
    mov ch, byte [cmd.cmd_loadmem_cylinder]
    mov dh, byte [cmd.cmd_loadmem_head]
    mov cl, byte [cmd.cmd_loadmem_loadoffset]
    mov bx, PROGRAM_ADDRESS
    int 13h
    jnc command.rfd_ok
    jc command.loadmem_err

command.rfd_ok:
    mov al, byte [PROGRAM_ADDRESS]
    cmp al, 0
    je command.rfd_noprog
    call PROGRAM_ADDRESS
    jmp mainloop
command.rfd_noprog:
    print cmd.cmd_rfd_locateerr, ln
    jmp mainloop

command.dir:

    call read_table

    mov si, filetable_ff
    mov cx, 64
    add si, 4
command.dir.lp:
    mov al, [si]
    cmp al, 0
    jne command.dir.printstring
    ; push si
    ; call print_string
    ; print space
    ; pop si
    command.dir.continue:

    dec cx
    cmp cx, 0
    je command.dirret

    cmp si, 8380h
    ja command.dirret

    mov bx, 12
    xor ax, ax
    sub bx, ax
    xchg ax, bx
    add si, ax
    add si, 4
    ; mov al, [si]
    ; cmp al, 0
    ; je command.dirret

    jmp command.dir.lp
command.dirret:
    print ln
    jmp mainloop
command.dir.printstring:
    push si
    call print_string
    print space
    pop si
    jmp command.dir.continue

command.run:
    mov bx, cmd.userinput_com
    call find_file

    mov bx, PROGRAM_ADDRESS
    call load_file
    jc command.loadmem_err

    cmp byte [PROGRAM_ADDRESS], 0x7A
    je command.run.run

    print cmd.cmd_run_nonex, ln

    jmp mainloop
command.run.run:
    call PROGRAM_ADDRESS+1
    jmp mainloop

command.rm:
    len cmd.userinput_arg1
    cmp ax, 0
    je command.rm.usage

    mov bx, cmd.userinput_arg1

    call remove_file

    jc command.rm.notfound

    call write_table

    jmp mainloop
command.rm.notfound:
    print cmd.file_notfound_err, ln
    jmp mainloop
command.rm.usage:
    print cmd.cmd_rm_usage, ln
    jmp mainloop

; command.addlink:
;     len cmd.userinput_arg3
;     cmp ax, 0
;     je command.addlink.usage
;     print cmd.cmd_addlink_desc
;     input cmd.userinput_buf, SHNUM_BUFFER_SIZE
;     str_to_i cmd.userinput_buf
;     mov [cmd.cmd_addlink_size], al
;     print cmd.cmd_addlink_desc1
;     input cmd.userinput_buf, FILENAME_BUFFER_SIZE
;     jmp mainloop
; command.addlink.usage:
;     print usage, ln
;     jmp mainloop

command.reboot:
    jmp 0xFFFF:0