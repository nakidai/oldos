greetings db "Welcome to the Command Line 2022-2024.", 0Dh, 0Ah, \
             "Originally made by plaza521.", 0Dh, 0Ah, \
             "Write help to see list of commands.", 0

goodbye db "Uhadi!", 0

zx db "0x", 0
ln db 0Dh, 0Ah, 0
space db " ", 0

print_registers.axd db "AX: 0x", 0
print_registers.bxd db "BX: 0x", 0
print_registers.cxd db "CX: 0x", 0
print_registers.dxd db "DX: 0x", 0
print_registers.sid db "SI: 0x", 0
print_registers.did db "DI: 0x", 0
print_registers.esd db "ES: 0x", 0
print_registers.dsd db "DS: 0x", 0
print_registers.ssd db "SS: 0x", 0
print_registers.fd  db "FLAGS: 0x", 0
print_registers.h db " ", 0

cmd.prefix db ">", 0
cmd.inc_com db "Invalid command or filename. Type 'help' to see more.", 0Dh, 0Ah, 0
cmd.file_notfound_err db "There are no files with this filename.", 0

cmd.cmd_help db "help", 0
cmd.cmd_help_desc db "Commands:", 0Dh, 0Ah, \
                     "mrun - Run program on user offset", 0Dh, 0Ah, \
                     "stdfuncs - show standart functions", 0Dh, 0Ah, \
                     "showmem <offset> <number of lines> - show memory on offset", 0Dh, 0Ah, \
                     "writemem - write byte to memory", 0Dh, 0Ah, \
                     "loadmem - load from disk to memory with offset", 0Dh, 0Ah, \
                     "shutdown - turn off the computer", 0Dh, 0Ah, \
                     "rfd - run program from disk", 0Dh, 0Ah, \
                     "dir - show files on disk", 0Dh, 0Ah, \
                     "rm <file> - remove file", 0Dh, 0Ah, \
                     "help - Show this menu", 0

cmd.cmd_mrun db "mrun", 0
cmd.cmd_mrun_desc db "Enter offset>", 0

cmd.cmd_stdfuncs db "stdfuncs", 0
cmd.cmd_stdfuncs_desc db "System functions:", 0

cmd.cmd_showmem db "showmem", 0
cmd.cmd_showmem_usage db "Usage: showmem <offset> <number of lines>", 0
; cmd.cmd_showmem_desc db "Enter offset>", 0
; cmd.cmd_showmem_desc1 db "Enter number of lines(16 bytes) to read>", 0

cmd.cmd_writemem db "writemem", 0
cmd.cmd_writemem_desc db "Enter offset>", 0
cmd.cmd_writemem_desc1 db "Enter value>", 0

cmd.cmd_addlink db "addlink", 0
cmd.cmd_addlink_desc db "Enter size>", 0
cmd.cmd_addlink_desc1 db "Enter filename>", 0
cmd.cmd_addlink_usage db "Usage: addlink <cylinder> <head> <sector>", 0
cmd.cmd_addlink_size db 0

cmd.cmd_loadmem db "loadmem", 0
cmd.cmd_loadmem_desc db "Enter numbers of sectors to read>", 0
cmd.cmd_loadmem_desc1 db "Enter drive to read>", 0
cmd.cmd_loadmem_desc2 db "Enter cylinder>", 0
cmd.cmd_loadmem_desc3 db "Enter head>", 0
cmd.cmd_loadmem_desc4 db "Enter number from which sector read>", 0
cmd.cmd_loadmem_desc5 db "Enter offset to load>", 0
cmd.cmd_loadmem_sectors db 0
cmd.cmd_loadmem_drive db 0
cmd.cmd_loadmem_cylinder db 0
cmd.cmd_loadmem_head db 0
cmd.cmd_loadmem_loadoffset db 0
cmd.cmd_loadmem_saveoffset dw 0
cmd.cmd_loadmem_loaderr db "Error while reading. See error code in AL", 0

cmd.cmd_run_nonex db "File is not executable or link is broken", 0

cmd.cmd_rfd db "rfd", 0
cmd.cmd_rfd_desc db "Enter len of program>", 0
cmd.cmd_rfd_desc1 db "Enter drive>", 0
cmd.cmd_rfd_desc4 db "Enter first sector>", 0
cmd.cmd_rfd_locateerr db "There are no any programs at your address", 0

cmd.cmd_dir db "dir", 0

cmd.cmd_rm db "rm", 0
cmd.cmd_rm_usage db "Usage: rm <file>", 0

; cmd.cmd_cf db "cf", 0

cmd.cmd_exit db "shutdown", 0

cmd.cmd_reboot db "reboot", 0

cmd.userinput_buf:
    times USERINPUT_BUFFER_SIZE db 0
db 0

cmd.userinput_com:
    times ARGUMENT_BUFFER_SIZE db 0
db 0

cmd.userinput_arg1:
    times ARGUMENT_BUFFER_SIZE db 0
db 0

cmd.userinput_arg2:
    times ARGUMENT_BUFFER_SIZE db 0
db 0

cmd.userinput_arg3:
    times ARGUMENT_BUFFER_SIZE db 0
db 0

cmd.cmd_mrun_buf:
    times INNUM_BUFFER_SIZE db 0
db 0
cmd.cmd_mrun_offset dw 0
