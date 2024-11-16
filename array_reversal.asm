section .data
    prompt_msg db "Enter 5 integers separated by spaces: ", 0   ; Prompt for user input
    reversed_msg db "Reversed array: ", 0                      ; Message for reversed array
    space db " ", 0                                            ; Space character for formatting output
    newline db 0xA, 0                                          ; Newline character for formatting

section .bss
    input_buffer resb 50                                       ; Buffer to hold input (enough space for 5 integers)
    array resd 5                                               ; Reserve space for an array of 5 integers
    print_buffer resb 12                                       ; Buffer to hold ASCII representation of integers

section .text
    global _start

_start:
    ; Print the prompt message to ask the user for input
    mov eax, 4                                                  ; sys_write syscall number
    mov ebx, 1                                                  ; file descriptor for stdout
    mov ecx, prompt_msg                                         ; address of the prompt message
    mov edx, 32                                                 ; length of the message
    int 0x80                                                    ; call kernel to print

    ; Read input from the user
    mov eax, 3                                                  ; sys_read syscall number
    mov ebx, 0                                                  ; file descriptor for stdin
    mov ecx, input_buffer                                       ; address to store the input
    mov edx, 50                                                 ; number of bytes to read (adjust size as needed)
    int 0x80                                                    ; call kernel to read input

    ; Parse input buffer and convert ASCII characters to integers
    mov esi, input_buffer                                       ; ESI points to the start of the input buffer
    mov edi, array                                              ; EDI points to the start of the array to store integers
    mov ecx, 5                                                  ; We expect 5 integers

parse_input:
    ; Skip any leading spaces
skip_space_check:
    mov al, [esi]                                               ; Load the current character
    cmp al, ' '                                                 ; Check if it's a space
    jne parse_digit                                             ; If not a space, go to parse_digit
    inc esi                                                     ; Move to the next character
    jmp skip_space_check                                        ; Repeat until a non-space character is found

parse_digit:
    xor eax, eax                                                ; Clear EAX to store the integer
digit_loop:
    mov al, [esi]                                               ; Load the current character
    cmp al, ' '                                                 ; Check if it's a space (end of number)
    je store_integer                                            ; If it's a space, store the integer and break
    cmp al, 0xA                                                 ; Check for newline (end of input)
    je store_integer                                            ; If newline, store the last number
    sub al, '0'                                                 ; Convert ASCII to integer by subtracting '0'
    imul eax, eax, 10                                           ; Shift left by one decimal place (multiply EAX by 10)
    add eax, ebx                                                ; Add the current digit to EAX
    inc esi                                                     ; Move to the next character
    jmp digit_loop                                              ; Repeat until we hit a space or newline


store_integer:
    mov [edi], eax                                              ; Store the integer in the array
    add edi, 4                                                  ; Move EDI to the next 4-byte space in the array
    inc esi                                                     ; Move to the next character after space
    loop parse_input                                            ; Repeat until all 5 integers are parsed

    ; Print newline for formatting
    mov eax, 4                                                  ; sys_write syscall number
    mov ebx, 1                                                  ; file descriptor for stdout
    mov ecx, newline                                            ; Address of newline character
    mov edx, 1                                                  ; Length of the newline
    int 0x80                                                    ; Call kernel to print newline

    ; Reverse the array in place
    mov esi, array                                              ; ESI points to the start of the array
    mov edi, array                                              ; EDI points to the end of the array
    add edi, 16                                                 ; Move EDI to the last element (4 * (5 - 1))

    mov ecx, 2                                                  ; We need 2 swaps (5/2 = 2 full swaps)
array_reverse_loop:
    ; Swap elements at ESI and EDI
    mov eax, [esi]                                              ; Load the element at ESI into EAX
    mov ebx, [edi]                                              ; Load the element at EDI into EBX
    mov [esi], ebx                                              ; Store EBX (end element) at ESI (start position)
    mov [edi], eax                                              ; Store EAX (start element) at EDI (end position)

    ; Move pointers towards the center
    add esi, 4                                                  ; Move ESI to the next element (right)
    sub edi, 4                                                  ; Move EDI to the previous element (left)

    loop array_reverse_loop                                     ; Repeat until all swaps are done

    ; Print the reversed array
    mov eax, 4                                                  ; sys_write syscall number
    mov ebx, 1                                                  ; file descriptor for stdout
    mov ecx, reversed_msg                                       ; Address of the reversed array message
    mov edx, 17                                                 ; Length of the message
    int 0x80                                                    ; Call kernel to print

    ; Print each integer in the array
    mov esi, array                                              ; ESI points to the start of the array
    mov ecx, 5                                                  ; Loop counter for 5 integers

print_loop:
    ; Load the current integer from the array
    mov eax, [esi]                                              ; Load the integer into EAX
    call integer_to_ascii                                       ; Convert the integer to ASCII

    ; Print the converted integer (stored in print_buffer)
    mov eax, 4                                                  ; sys_write syscall number
    mov ebx, 1                                                  ; file descriptor for stdout
    mov ecx, print_buffer                                       ; Address of the print buffer
    mov edx, 12                                                 ; Length (adjust based on integer length)
    int 0x80                                                    ; Call kernel to print

    ; Print space between numbers
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80

    ; Move to the next integer in the array
    add esi, 4                                                  ; Move to the next integer
    loop print_loop                                             ; Repeat until all integers are printed

    ; Print a final newline for formatting
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Exit the program gracefully
    mov eax, 1                                                  ; sys_exit syscall number
    xor ebx, ebx                                                ; Exit code 0
    int 0x80                                                    ; Call kernel to exit

; Subroutine: integer_to_ascii
; Converts the integer in EAX to its ASCII representation.
; Stores the result in the 'print_buffer' and returns with ESI pointing to the start of the string.
integer_to_ascii:
    mov esi, print_buffer                             ; Point ESI to the print buffer
    mov ebx, 10                                       ; Divider for extracting digits
    xor ecx, ecx                                      ; ECX will count the number of digits
    cmp eax, 0                                        ; Check if the number is zero
    jne convert_digits_loop                           ; If not zero, continue with conversion

    ; Handle zero case
    mov byte [esi], '0'                               ; Store '0' in the buffer
    inc esi                                           ; Move to the next position
    mov byte [esi], 0                                 ; Null-terminate the string
    ret                                               ; Return with ESI pointing to the start of the buffer

convert_digits_loop:
    ; Handle negative numbers
    cmp eax, 0                                        ; Check if the number is negative
    jge positive_number                               ; If positive, skip to positive_number
    neg eax                                           ; Make EAX positive
    mov byte [esi], '-'                               ; Store the negative sign in the buffer
    inc esi                                           ; Move to the next position

positive_number:
    ; Convert each digit to ASCII
    xor edx, edx                                      ; Clear remainder (needed for division)
    div ebx                                           ; Divide EAX by 10, result in EAX, remainder in EDX
    add dl, '0'                                       ; Convert the remainder to ASCII
    mov [esi], dl                                     ; Store the digit in the buffer
    inc esi                                           ; Move to the next position
    inc ecx                                           ; Increment digit count
    test eax, eax                                     ; Check if EAX is zero
    jnz convert_digits_loop                           ; If not, continue with the next digit

    ; Reverse the digits in the buffer to correct order
    dec esi                                           ; Move ESI to the last valid digit
reverse_digits_loop:
    cmp ecx, 0                                        ; Check if digit count is zero
    je end_conversion                                 ; If zero, end the reversal
    mov al, [esi]                                     ; Load the current digit
    stosb                                             ; Store AL at [EDI] and increment EDI
    dec esi                                           ; Move to the previous digit
    loop reverse_digits_loop                          ; Repeat for all digits

end_conversion:
    mov byte [esi], 0                                 ; Null-terminate the string
    ret                                               ; Return with ESI pointing to the start of the string
