macro print [pointer]
{
    mov si, pointer
    call print_string
}

macro printh [num]
{
    mov ax, num
    call print_hex
}

macro printi [num]
{
    mov ax, num
    call its
}

macro cmp_strs ptr1, ptr2
{
    mov si, ptr1
    mov bx, ptr2
    call compare_strings
}

macro cp_str ptr1, ptr2
{
    mov si, ptr1
    mov bx, ptr2
    call copy_string
}

macro input pointer, length
{
    mov si, pointer
    mov cx, length
    call input_string
}

macro len pointer
{
    mov si, pointer
    call calculate_string_len
}

macro muln num1, num2
{
    mov ax, num1
    mov bx, num2
    mul bx
}

macro str_to_i pointer
{
    mov si, pointer
    call string_to_int
}

macro i_to_str pointer, number
{
    mov si, pointer
    mov ax, number
    call int_to_string
}

macro reset_buf pointer, length
{
    mov si, pointer
    mov cx, length
    call reset_buffer
}
