.global _start

.section .text
_start:

    movq (root), %rdi
    movq (node), %rsi
    movl 8(%rsi), %edx # Save data - node->data

search_HW1:
    # Load data to eax / root data
    movl 8(%rdi), %eax

    cmpl %eax, %edx
    jl less_then_HW1
    
greater_eq_then_HW1:
    # Need to check that the pointer is valid    
    movq 12(%rdi), %rcx  # right pointer into %rcx

    testq %rcx, %rcx # if Zero flag is 0 then rcx not 0
    jz insert_right_HW1

    # has another node in left
    movq %rcx, %rdi
    jmp search_HW1


less_then_HW1:
    # Need to check that the pointer is valid    
    movq 0(%rdi), %rcx  # left pointer into %rcx

    testq %rcx, %rcx # if Zero flag is 0 then rcx not 0
    jz insert_left_HW1

    # has another node in left
    movq %rcx, %rdi
    jmp search_HW1

insert_left_HW1:
    movq %rsi, 0(%rdi) # set the pointer of the child to rsi (new node)
    jmp done_HW1

insert_right_HW1:
    movq %rsi, 12(%rdi) # set the pointer of the child to rsi (new node)

done_HW1:
