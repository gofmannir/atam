.global _start

.section .text
_start:
    
    # Load the base address of the source array
    movq (Adrress), %rsi

    # Load the base address of the destination array
    movq (LittleEndianResult), %rdi

    # Load the type (size of each element) into %ecx
    movzbq Type(%rip), %rcx

    # Load the length of the array into %ebx
    movl Length(%rip), %ebx

process_elements_HW1:
    testl %ebx, %ebx             # Check if length is 0
    jz done_HW1                      # If 0, we're done

    # Reverse the bytes of the current element
    movl %ecx, %edx              # Copy type (number of bytes) to %edx
    leaq 0(%rsi), %rax           # Load the address of the current element

reverse_bytes_HW1:
    movb (%rax), %r8b             # Load a byte from the source
    
    # rdi - the destination starting address
    # rdx - the Type (size in bytes)
    subq $1, %rdx                # Move to the previous byte in the destination
    movb %r8b, (%rdi,%rdx, 1)     # Store it in reverse order in the destination
    addq $1, %rax                # Move to the next byte in the source
    testq %rdx, %rdx             # Check if we reversed all bytes
    jnz reverse_bytes_HW1            # If not, continue reversing

    # Move to the next element
    addq %rcx, %rsi              # Advance the source pointer by the size of the element
    addq %rcx, %rdi              # Advance the destination pointer by the size of the element
    decl %ebx                    # Decrease the element counter
    jmp process_elements_HW1         # Repeat for the next element

done_HW1:
