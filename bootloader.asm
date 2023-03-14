USE16
format binary as 'bin'

include 'macros.asm'
include 'constants.asm'

org 7C00h

start:
    mov byte [BOOT_DRIVE], dl
    mov ax, [0410h]
    mov word [DETECTED_HARDWARE], ax

    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 1000h
    sti

    mov ax, 3
    int 10h

    mov ax, 1301h
    mov cx, 10
    mov bp, loadingdb
    xor dx, dx
    mov bx, 7
    int 10h

    mov ah, 02h
    ; Number of sectors to load
    ; mov al, PROGRAM_LENGTH
    mov al, 4
    mov dl, [BOOT_DRIVE]
    ; Cylinder
    mov ch, 0
    ; Head
    mov dh, 0
    ; Start sector number
    mov cl, 2
    ; Where load
    mov bx, functable
    int 13h

    jc booterror

    ; call main
    jmp secstage

    ; call dbg_halt_cpu

loadingdb db "Loading..."

; Print unsigned int
;
; AX - Num to convert
; SI - Where save string
; ---
; SI - Pointer to string with converted num
its:
    push cx
    push bx
    push di
    push ax

    mov cx, 0
    mov bx, 10
    mov di, si

its.push:
    mov dx, 0
    div bx
    inc cx
    push dx
    test ax, ax
    jnz its.push
its.pop:
    pop dx
    add dl, '0'
    push ax
    mov ah, 0Eh
    mov al, dl
    int 10h
    pop ax
    inc di
    dec cx
    jnz its.pop

    pop ax
    pop di
    pop bx
    pop cx
    ret

errcode db 0
booterror:
    mov [errcode], ah
    mov ax, 3
    int 10h
    mov ax, 1301h
    mov bx, 7
    xor dx, dx
    mov cx, 13
    mov bp, booterror.message
    int 10h
    xor ax, ax
    mov al, [errcode]
    call its
    cli
    hlt

booterror.message db "Error! Code: "

; times 507-($-$$) db 0
; MBR partition table starting at byte 446
times 443-($-$$) db 0
DETECTED_HARDWARE dw 0
BOOT_DRIVE db 0

; partition 1 (contains the kernel code)
boot_indicator: db 0x80 ; mark as bootable
starting_head: db 0x0
starting_sector: db 0x1 ; bits 5-0 for sector and bits 7-6 are upper bits of cylinder
starting_cylinder: db 0x0
system_id: db 0x7f ; just some ID that has not been used for anything else by standard
; the last sector of the partition should be 2880
ending_head: db 1 ; here I assume the maximum number of heads as 255
ending_sector: db 4
ending_cylinder: db 0x0
first_sector_lba: dd 0x1 ; first sector after the bootsector
total_sectors_in_partition: dd 21 ; 2880-1 because first sector is bootsector

; partitions 2-4 are unused and therefore set to 0
times 16 db 0
times 16 db 0
times 16 db 0

db 0x55, 0xAA


include 'functable.asm'

include 'filetable.asm'

include 'secstage.asm'

include 'kernel.asm'

include 'funcs.asm'

include 'data.asm'

VIDEO_MODE db 0

times 8192-($-$$) db 0
; times 8400h-($-$$) db 0

; include 'programs/calculator.asm'
