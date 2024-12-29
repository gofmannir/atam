.globl my_ili_handler

.text
.align 4, 0x90
my_ili_handler:
    # --- Save clobbered registers ---
    pushq %r8
    pushq %r9
    pushq %r10
    pushq %r11
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15
    pushq %rax
    pushq %rbx
    pushq %rcx
    pushq %rdx
    pushq %rsi
    pushq %rdi
    pushq %rbp
    pushq %rsp

	# get the opcode
	movq 128(%rsp), %rax  # RIP
	movq (%rax), %rax
    
    cmpb $0x0F, %al        # Compare the first byte (AL) with 0x0F
    je two_byte_opcode     # Jump if it starts with 0x0F (two-byte opcode)

single_byte_opcode:
    movq %rax, %rdi    # Pass RIP (pointer to opcode) to the function
    call what_to_do    
    
    testl %eax, %eax
    jz equal_zero

    movq %rax, %rdi

    # --- Restore registers ---
    popq %rsp
    popq %rbp
    popq %rsi # the orginal rdi !
    popq %rsi
    popq %rdx
    popq %rcx
    popq %rbx
    popq %rax
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %r11
    popq %r10
    popq %r9
    popq %r8

    # do more logic
    addq $1, (%rsp) # it holds the return adress, we go over it

    iretq

two_byte_opcode:
    movb %ah, %al          # Shift the opcode to the right by 8 bits
    movq %rax, %rdi        # Pass RIP (pointer to opcode) to the function
    call what_to_do        # Call your C function
    
    testl %eax, %eax
    jz equal_zero

    movq %rax, %rdi

    # --- Restore registers ---
    popq %rsp
    popq %rbp
    popq %rsi
    popq %rsi
    popq %rdx
    popq %rcx
    popq %rbx
    popq %rax
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %r11
    popq %r10
    popq %r9
    popq %r8

    # do more logic
    addq $2, (%rsp) # it holds the return adress, we go over it

    iretq

equal_zero:
    # --- Restore registers ---
    popq %rsp
    popq %rbp
    popq %rdi
    popq %rsi
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %r11
    popq %r10
    popq %r9
    popq %r8
    popq %rdx
    popq %rcx
    popq %rbx
    popq %rax

    jmpq *old_ili_handler

    iretq
    