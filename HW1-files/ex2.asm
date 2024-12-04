.global _start

.section .text
_start:
    # Load the base address of the source
    movq (Adrress), %rsi
    testq %rsi, %rsi           # Check if the address is 0
    jz done_HW1                # If the address is 0, jump to done 

    # Load the base address of the destination 
    movq (LittleEndianResult), %rdi

    # Load the type into %ecx
    movzbq (Type), %rcx

    # Load the length into %ebx
    movl (Length), %ebx

main_loop_HW1:
    testl %ebx, %ebx             # Check if length is 0
    jz done_HW1                  # If 0, we're done main loop

    # Reverse the bytes of the current element
    movl %ecx, %edx              # Copy type to %edx
    
    # Load the address of the current element
    movq %rsi, %rax

reverse_bytes_HW1:
    movb (%rax), %r8b             # Load a byte from the source
    
    # rdi - the destination starting address
    # rdx - the Type (size in bytes)
    decq %rdx                     # Move to the previous byte in the destination
    movb %r8b, (%rdi,%rdx, 1)     # Store it in reverse order in the destination
    incq %rax                     # Move to the next byte in the source
    testq %rdx, %rdx              # Check if we reversed all bytes in the inner loop
    jnz reverse_bytes_HW1         # If not, continue reversing

    # Move to the next element
    addq %rcx, %rsi              # Advance the source pointer by the type
    addq %rcx, %rdi              # Advance the destination pointer by the type
    decl %ebx                    # Decrease the length
    jmp main_loop_HW1            # Repeat for the next element

done_HW1:
