section .data
    prompt_msg db "Enter a number: ", 0       ; Prompt for user input
    positive_msg db "POSITIVE", 0             ; Message for positive number
    negative_msg db "NEGATIVE", 0             ; Message for negative number
    zero_msg db "ZERO", 0                     ; Message for zero
    newline db 0xA, 0                         ; Newline character for formatting

section .bss
    num resb 4                                ; Reserve space for user input

section .text
    global _start

_start:
    ; Print the prompt message to ask the user for input
    mov eax, 4                                ; sys_write syscall number
    mov ebx, 1                                ; file descriptor for stdout
    mov ecx, prompt_msg                       ; address of the prompt message
    mov edx, 15                               ; length of the message
    int 0x80                                  ; call kernel to print

    ; Read user input from the standard input (stdin)
    mov eax, 3                                ; sys_read syscall number
    mov ebx, 0                                ; file descriptor for stdin
    mov ecx, num                              ; address to store input
    mov edx, 4                                ; number of bytes to read
    int 0x80                                  ; call kernel to read input

    ; Check if the input is negative and set up for integer conversion
    mov esi, num                              ; Load the address of the input into ESI
    mov ebx, 0                                ; Clear EBX (will hold the integer value)
    mov bl, [esi]                             ; Load the first byte (character) into BL

    cmp bl, '-'                               ; Check if the first character is a negative sign
    jne convert_positive                      ; If not a negative sign, jump to convert_positive

    ; Handle negative number case
    inc esi                                   ; Move to the next character after the negative sign
    call convert_to_integer                   ; Call subroutine to convert the number part to integer
    neg eax                                   ; Negate EAX to make the number negative
    jmp check_value                           ; Skip to value check to classify the number

convert_positive:
    ; Convert the input to an integer (positive case)
    call convert_to_integer                   ; Call subroutine to convert the number part to integer

check_value:
    ; Check if the converted number is zero
    cmp eax, 0                                ; Compare EAX with zero
    je zero_label                             ; Jump to zero_label if EAX == 0
    ; Explanation: 'JE' (Jump if Equal) directs the flow to zero_label if the input is zero.

    ; Check if the converted number is positive
    cmp eax, 0                                ; Compare EAX with zero again
    jg positive_label                         ; Jump to positive_label if EAX > 0
    ; Explanation: 'JG' (Jump if Greater) ensures the program jumps to positive_label if EAX is positive.

    ; If the number is neither zero nor positive, it must be negative
negative_label:
    ; Print "NEGATIVE" message
    mov eax, 4                                ; sys_write syscall number
    mov ebx, 1                                ; file descriptor for stdout
    mov ecx, negative_msg                     ; Address of the negative message
    mov edx, 8                                ; Length of the message
    int 0x80                                  ; Call kernel to print "NEGATIVE"
    jmp end_program                           ; Unconditional jump to end_program after printing
    ; Explanation: 'JMP' ensures the program exits after printing "NEGATIVE".

positive_label:
    ; Print "POSITIVE" message
    mov eax, 4                                ; sys_write syscall number
    mov ebx, 1                                ; file descriptor for stdout
    mov ecx, positive_msg                     ; Address of the positive message
    mov edx, 8                                ; Length of the message
    int 0x80                                  ; Call kernel to print "POSITIVE"
    jmp end_program                           ; Unconditional jump to end_program after printing
    ; Explanation: 'JMP' ensures the program exits after printing "POSITIVE".

zero_label:
    ; Print "ZERO" message
    mov eax, 4                                ; sys_write syscall number
    mov ebx, 1                                ; file descriptor for stdout
    mov ecx, zero_msg                         ; Address of the zero message
    mov edx, 4                                ; Length of the message
    int 0x80                                  ; Call kernel to print "ZERO"
    ; Explanation: No 'JMP' needed here as the program naturally falls to the end after printing.

end_program:
    ; Print a newline for formatting output
    mov eax, 4                                ; sys_write syscall number
    mov ebx, 1                                ; file descriptor for stdout
    mov ecx, newline                          ; Address of the newline character
    mov edx, 1                                ; Length of the newline
    int 0x80                                  ; Call kernel to print newline

    ; Exit the program gracefully
    mov eax, 1                                ; sys_exit syscall number
    xor ebx, ebx                              ; Exit code 0
    int 0x80                                  ; Call kernel to exit

; Subroutine to convert ASCII string to integer
convert_to_integer:
    ; Assumes ESI points to the start of the number string
    ; Result is stored in EAX
    xor eax, eax                              ; Clear EAX (holds the final integer value)
    mov ecx, 10                               ; Multiplier for decimal places (base 10)

convert_loop:
    mov bl, [esi]                             ; Load the current character into BL
    cmp bl, 0xA                               ; Check for newline character (end of input)
    je end_convert                            ; If newline, end the conversion process
    sub bl, '0'                               ; Convert ASCII character to integer by subtracting '0'
    imul eax, ecx                             ; Multiply current EAX value by 10 (shift left by one decimal place)
    add eax, ebx                              ; Add the current digit value to EAX
    inc esi                                   ; Move to the next character in the string
    jmp convert_loop                          ; Repeat the loop for the next character

end_convert:
    ret                                       ; Return from subroutine with result in EAX
