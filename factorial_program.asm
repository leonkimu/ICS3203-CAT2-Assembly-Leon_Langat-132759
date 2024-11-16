section .data
    prompt_msg db "Enter a number to calculate its factorial: ", 0
    result_msg db "The factorial is: ", 0
    error_msg db "Invalid input. Enter a number between 0 and 12.", 0
    newline db 0xA, 0

section .bss
    input_buffer resb 4               ; Buffer for user input (single digit)
    result_buffer resd 1              ; Buffer to store the result
    print_buffer resb 12              ; Buffer to hold ASCII representation of integers

section .text
    global _start

_start:
    ; Print the prompt message
    mov eax, 4                        ; sys_write syscall number
    mov ebx, 1                        ; file descriptor for stdout
    mov ecx, prompt_msg               ; address of the prompt message
    mov edx, 40                       ; length of the message
    int 0x80                          ; call kernel to print

    ; Read input from the user
    mov eax, 3                        ; sys_read syscall number
    mov ebx, 0                        ; file descriptor for stdin
    mov ecx, input_buffer             ; address to store input
    mov edx, 4                        ; number of bytes to read
    int 0x80                          ; call kernel to read input

    ; Convert ASCII input to an integer
    mov esi, input_buffer             ; Load the input address
    movzx eax, byte [esi]             ; Zero-extend and load the byte into EAX
    sub eax, '0'                      ; Convert ASCII to integer

    ; Check if input is within a valid range (0 to 12)
    cmp eax, 12
    jg input_error                    ; Jump if input is greater than 12
    cmp eax, 0
    jl input_error                    ; Jump if input is negative

    ; Call the factorial subroutine
    push eax                          ; Push the number onto the stack as an argument
    call factorial                    ; Call the factorial subroutine
    add esp, 4                        ; Clean up the stack after the call

    ; Store the result in result_buffer for printing
    mov [result_buffer], eax

    ; Print the result message
    mov eax, 4                        ; sys_write syscall number
    mov ebx, 1                        ; file descriptor for stdout
    mov ecx, result_msg               ; address of the result message
    mov edx, 19                       ; length of the message
    int 0x80                          ; call kernel to print

    ; Convert result to ASCII and print
    mov eax, [result_buffer]          ; Load the result
    call integer_to_ascii             ; Convert integer to ASCII

    ; Print the result stored in print_buffer
    mov eax, 4                        ; sys_write syscall number
    mov ebx, 1                        ; file descriptor for stdout
    mov ecx, print_buffer             ; address of the print buffer
    mov edx, 12                       ; length (adjust as needed)
    int 0x80                          ; call kernel to print

    ; Print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Exit the program
    mov eax, 1                        ; sys_exit syscall number
    xor ebx, ebx                      ; exit code 0
    int 0x80                          ; call kernel to exit

input_error:
    ; Handle input error
    mov eax, 4                        ; sys_write syscall number
    mov ebx, 1                        ; file descriptor for stdout
    mov ecx, error_msg                ; Address of the error message
    mov edx, 44                       ; Length of the error message
    int 0x80                          ; Call kernel to print error message
    jmp _start                        ; Restart the program

; Subroutine: factorial
; Calculates the factorial of a number in EAX
factorial:
    ; Preserve registers
    push ebp                          ; Save base pointer
    mov ebp, esp                      ; Set up a new base pointer
    push ebx                          ; Save EBX for later use

    ; Check if the number is 0 or 1 (base case)
    cmp eax, 1                        ; Compare EAX with 1
    jle base_case                     ; If EAX <= 1, jump to base_case

    ; Recursive case: EAX = n * factorial(n - 1)
    mov ebx, eax                      ; Save EAX (n) in EBX
    dec eax                           ; Decrease EAX to (n - 1)
    push eax                          ; Push (n - 1) onto the stack
    call factorial                    ; Recursively call factorial(n - 1)
    pop eax                           ; Clean up the stack after the call

    ; Multiply EBX (n) by the result of factorial(n - 1)
    imul eax, ebx                     ; EAX = n * result of factorial(n - 1)

    jmp factorial_end                 ; Jump to the end of the subroutine

base_case:
    mov eax, 1                        ; Set EAX to 1 for 0! or 1!

factorial_end:
    ; Restore registers
    pop ebx                           ; Restore EBX
    mov esp, ebp                      ; Restore stack pointer
    pop ebp                           ; Restore base pointer
    ret                               ; Return to the caller

; Subroutine: integer_to_ascii
; Converts the integer in EAX to its ASCII representation.
; Stores the result in the 'print_buffer' and returns with ESI pointing to the start of the string.
integer_to_ascii:
    mov esi, print_buffer             ; Point ESI to the print buffer
    mov ebx, 10                       ; Divider for extracting digits
    xor ecx, ecx                      ; ECX will count the number of digits
    cmp eax, 0                        ; Check if the number is zero
    jne convert_digits_loop           ; If not zero, continue with conversion

    ; Handle zero case
    mov byte [esi], '0'               ; Store '0' in the buffer
    inc esi                           ; Move to the next position
    mov byte [esi], 0                 ; Null-terminate the string
    ret                               ; Return with ESI pointing to the start of the buffer

convert_digits_loop:
    xor edx, edx                      ; Clear remainder
    div ebx                           ; Divide EAX by 10, result in EAX, remainder in EDX
    add dl, '0'                       ; Convert remainder to ASCII
    mov [esi], dl                     ; Store the digit in the buffer
    inc esi                           ; Move to the next position
    inc ecx                           ; Increment digit count
    test eax, eax                     ; Check if EAX is zero
    jnz convert_digits_loop           ; If not, continue

    ; Reverse the digits in the buffer to correct order
    dec esi                           ; Move ESI to the last valid digit
    mov edi, print_buffer             ; Initialize EDI to point to the start of the buffer

reverse_digits_loop:
    cmp ecx, 0                        ; Check if digit count is zero
    je end_conversion                 ; If zero, end the reversal
    mov al, [esi]                     ; Load the current digit
    mov [edi], al                     ; Store AL at [EDI]
    inc edi                           ; Move EDI to the next position
    dec esi                           ; Move to the previous digit
    loop reverse_digits_loop          ; Repeat for all digits

end_conversion:
    mov byte [edi], 0                 ; Null-terminate the string
    ret                               ; Return with ESI pointing to the start of the string
