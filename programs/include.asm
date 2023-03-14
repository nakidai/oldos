USE16
format binary as 'bin'

include 'programmacros.asm'

INNUM_BUFFER_SIZE equ 5
SHNUM_BUFFER_SIZE equ 3
ACTION_BUFFER_SIZE equ 3
RESULT_BUFFER_SIZE equ 7
USERINPUT_BUFFER_SIZE equ 64
ARGUMENT_BUFFER_SIZE equ 16
FILENAME_BUFFER_SIZE equ 11

FUNCTABLE EQU 7E00h
clear                EQU word [7E00h]
detect_video         EQU word [7E02h]
print_string         EQU word [7E04h]
print_symbol         EQU word [7E06h]
input_string         EQU word [7E08h]
compare_strings      EQU word [7E0Ah]
copy_string          EQU word [7E0Ch]
calculate_string_len EQU word [7E0Eh]
os_print_digit       EQU word [7E10h]
os_print_1hex        EQU word [7E12h]
os_print_2hex        EQU word [7E14h]
print_hex            EQU word [7E16h]
print_registers      EQU word [7E18h]
string_to_int        EQU word [7E1Ah]
int_to_string        EQU word [7E1Ch]
dbg_halt_cpu         EQU word [7E1Eh]
halt_cpu             EQU word [7E20h]
its                  EQU word [7E22h]
find_file            EQU word [7E24h]
remove_file          EQU word [7E26h]
write_table          EQU word [7E28h]
arg1                 EQU word [7E2Ah]
arg2                 EQU word [7E2Ch]
arg3                 EQU word [7E2Eh]
reset_buffer         EQU word [7E30h]
append_file          EQU word [7E32h]
rename_file          EQU word [7E34h]
load_file            EQU word [7E36h]
save_file            EQU word [7E38h]
wait_key             EQU word [7E3Ah]
copy_memory          EQU word [7E3Ch]
get_cursor_pos       EQU word [7E3Eh]
set_cursor_pos       EQU word [7E40h]
read_table 			 EQU word [7E42h]

org 1000h

db 0x7A
