
# ICS3203 CAT 2 - Assembly Programming

## Overview
This repository contains assembly programs for ICS3203 CAT 2. Each program demonstrates various assembly language concepts such as control flow, subroutine usage, and port-based simulation.

### Task 1: Control Flow and Conditional Logic
**Purpose**: This program reads a number from the user and classifies it as "POSITIVE," "NEGATIVE," or "ZERO."

### Task 2: Array Manipulation
**Purpose**: This program reads an array of integers provided by the user and reverses the array in place.

### Task 3: Factorial Calculation
**Purpose**: This program computes the factorial of a number using a subroutine. It demonstrates register preservation using the stack and recursion.

### Task 4: Data Monitoring Simulation
**Purpose**: This program simulates reading a sensor value and performs actions such as controlling a motor and triggering an alarm based on the input.

## Compiling and Running Instructions
**To compile and link a program**, use the following commands:

```bash
nasm -f elf32 <filename>.asm -o <filename>.o
ld -m elf_i386 <filename>.o -o <filename>
./<filename>
```

### Example
```bash
nasm -f elf32 control_program.asm -o control_program.o
ld -m elf_i386 control_program.o -o control_program
./control_program
```

## Insights and Challenges
- **Task 1: Control Flow and Conditional Logic**
  - **Insight**: Handling control flow in assembly requires precise use of jump instructions (`JE`, `JL`, `JG`, etc.) to evaluate conditions correctly.
  - **Challenge**: Ensuring that all edge cases (such as zero input) were correctly managed without overlapping conditions. Debugging these logical branches required careful tracing of register states to validate the flow.

- **Task 2: Array Manipulation**
  - **Insight**: Implementing in-place array reversal highlighted the importance of using registers efficiently and handling memory operations correctly without auxiliary space.
  - **Challenge**: Managing pointer arithmetic and ensuring that array boundaries were respected to avoid segmentation faults or incorrect memory access. Debugging involved stepping through the code to ensure data integrity during swaps.

- **Task 3: Factorial Calculation**
  - **Insight**: Using recursion in assembly required a clear understanding of how the stack works for saving return addresses and local variables. This task illustrated the power of subroutines and recursive calls in assembly.
  - **Challenge**: Preserving registers (`EAX`, `EBX`, `EBP`) and ensuring stack balance to avoid stack corruption during recursion. Ensuring that the base case stopped recursion effectively and testing large inputs to prevent stack overflow were significant parts of the development process.

- **Task 4: Data Monitoring Simulation**
  - **Insight**: Simulating a control program with memory-mapped I/O operations provided a practical understanding of how hardware-level simulations can be performed in assembly.
  - **Challenge**: Designing logical checks for turning on the motor, triggering alarms, and stopping the motor based on the sensor value required careful conditional checking and memory handling. Implementing this involved managing memory locations as control registers and ensuring that the program's flow respected priority conditions without unintended overlaps.
