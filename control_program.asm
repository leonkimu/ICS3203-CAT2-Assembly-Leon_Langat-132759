section .data
    sensor_value db 50                ; Simulated sensor value (can be changed to test different scenarios)
    motor_status db 0                 ; Memory location to indicate motor status (0 = off, 1 = on)
    alarm_status db 0                 ; Memory location to indicate alarm status (0 = inactive, 1 = active)
    low_threshold db 30               ; Threshold for low water level (turn motor on)
    high_threshold db 70              ; Threshold for high water level (trigger alarm)
    newline db 0xA, 0                 ; Newline for formatting

section .text
    global _start

_start:
    ; Load the sensor value into AL
    mov al, [sensor_value]            ; Read the sensor value from memory

    ; Check if the water level is low
    cmp al, [low_threshold]           ; Compare the sensor value with the low threshold
    jl turn_on_motor                  ; If the sensor value is less than the low threshold, turn on the motor

    ; Check if the water level is too high
    cmp al, [high_threshold]          ; Compare the sensor value with the high threshold
    jg trigger_alarm                  ; If the sensor value is greater than the high threshold, trigger the alarm

    ; If the water level is moderate
    jmp stop_motor                    ; Otherwise, stop the motor

turn_on_motor:
    mov byte [motor_status], 1        ; Set motor status to 1 (motor on)
    mov byte [alarm_status], 0        ; Ensure alarm status is 0 (alarm off)
    jmp end_program                   ; Jump to the end of the program

trigger_alarm:
    mov byte [alarm_status], 1        ; Set alarm status to 1 (alarm active)
    mov byte [motor_status], 0        ; Turn off the motor if the alarm is active
    jmp end_program                   ; Jump to the end of the program

stop_motor:
    mov byte [motor_status], 0        ; Set motor status to 0 (motor off)
    mov byte [alarm_status], 0        ; Ensure alarm status is 0 (alarm off)
    jmp end_program                   ; Jump to the end of the program

end_program:
    ; Print statuses for verification (optional)
    ; Print motor status
    mov eax, 4                        ; sys_write syscall number
    mov ebx, 1                        ; file descriptor for stdout
    mov ecx, motor_status_msg         ; Address of motor status message
    mov edx, 16                       ; Length of the motor status message
    int 0x80                          ; Call kernel to print

    ; Print motor status value
    mov al, [motor_status]            ; Load motor status
    add al, '0'                       ; Convert to ASCII
    mov [result_buffer], al           ; Store in result buffer
    mov eax, 4                        ; sys_write syscall number
    mov ebx, 1                        ; file descriptor for stdout
    mov ecx, result_buffer            ; Address of the result buffer
    mov edx, 1                        ; Length of the result buffer
    int 0x80                          ; Call kernel to print

    ; Print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Print alarm status
    mov eax, 4                        ; sys_write syscall number
    mov ebx, 1                        ; file descriptor for stdout
    mov ecx, alarm_status_msg         ; Address of alarm status message
    mov edx, 15                       ; Length of the alarm status message
    int 0x80                          ; Call kernel to print

    ; Print alarm status value
    mov al, [alarm_status]            ; Load alarm status
    add al, '0'                       ; Convert to ASCII
    mov [result_buffer], al           ; Store in result buffer
    mov eax, 4                        ; sys_write syscall number
    mov ebx, 1                        ; file descriptor for stdout
    mov ecx, result_buffer            ; Address of the result buffer
    mov edx, 1                        ; Length of the result buffer
    int 0x80                          ; Call kernel to print

    ; Print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Exit the program
    mov eax, 1                        ; sys_exit syscall number
    xor ebx, ebx                      ; Exit code 0
    int 0x80                          ; Call kernel to exit

section .bss
    result_buffer resb 1              ; Buffer to hold one ASCII character

section .data
    motor_status_msg db "Motor status: ", 0
    alarm_status_msg db "Alarm status: ", 0
