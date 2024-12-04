.global _start

.section .data

MyArray:
    .int 10, 20, 30, 40, 50

MyArrayResult:
    .int 10, 20, 30, 40, 50

Adrress: 
	.quad MyArray

Type: 
	.byte 3

Length:
    .int 3

LittleEndianResult:
	.quad MyArrayResult



.section .text
_start:
    
    # Load the base address of the source array
    movq (Adrress), %rsi

    # Load the base address of the destination array
    leaq LittleEndianResult(%rip), %rdi

     # Load the type (size of each element) into %ecx
    movl Type(%rip), %ecx

    # Load the length of the array into %ebx
    movl Length(%rip), %ebx

process_elements:
    testl %ebx, %ebx             # Check if length is 0
    jz done                      # If 0, we're done

    # Reverse the bytes of the current element
    movl %ecx, %edx              # Copy type (number of bytes) to %edx
    leaq 0(%rsi), %rax           # Load the address of the current element

reverse_bytes:
    movb (%rax), %al             # Load a byte from the source
    movb %al, (%rdi,%rdx,-1)     # Store it in reverse order in the destination
    addq $1, %rax                # Move to the next byte in the source
    subq $1, %rdx                # Move to the previous byte in the destination
    testq %rdx, %rdx             # Check if we reversed all bytes
    jnz reverse_bytes            # If not, continue reversing

    # Move to the next element
    addq %rcx, %rsi              # Advance the source pointer by the size of the element
    addq %rcx, %rdi              # Advance the destination pointer by the size of the element
    decl %ebx                    # Decrease the element counter
    jmp process_elements         # Repeat for the next element

done:


    movq $60, %rax
    xorq %rdi, %rdi
    syscall



/**
as ex2.asm -o ex2.o && ld ex2.o -o ex2 && ./ex2

**/