.section .data
# Define the list in memory: each node contains `val` (4 bytes) and `next` (8 bytes).
A:
    .long 2               # Node 1: val = 2
    .quad B               # Node 1: next = address of Node 2
B:
    .long 3               # Node 2: val = 3
    .quad C               # Node 2: next = address of Node 3
C:
    .long 4               # Node 3: val = 4
    .quad D               # Node 3: next = address of Node 4
D:
    .long 12              # Node 4: val = 12
    .quad E               # Node 4: next = address of Node 5
E:
    .long 5               # Node 5: val = 5
    .quad F               # Node 5: next = address of Node 6
F:
    .long 5               # Node 6: val = 5
    .quad G               # Node 6: next = address of Node 7
G:
    .long 9               # Node 7: val = 9
    .quad 0               # Node 7: next = NULL

.section .text
.global _start, sod

# Entry point
_start:
    movq $0x600151, %rdi       # Load address of the head of the list (A)
    movq $7, %rsi            # Length of the list
    call sod                 # Call sod to process the list

    # Exit system call
    movq $60, %rax           # syscall: exit
    xorq %rdi, %rdi          # status: 0
    syscall

# sod function
sod:
    pushq %rbp               # Save base pointer
    movq %rsp, %rbp          # Set new base pointer
    subq $32, %rsp           # Allocate 32 bytes on the stack

    movq %rdi, -24(%rbp)     # Store head pointer in local variable
    movl %esi, -28(%rbp)     # Store len in local variable

    cmpq $0, -24(%rbp)       # Check if head == NULL
    jne .L2                  # If not NULL, go to .L2
    movl $0, %eax            # Base case: return NULL (0)
    jmp .L3                  # Jump to the end

.L2:
    movq -24(%rbp), %rax     # Load head into %rax
    movq %rax, -8(%rbp)      # Copy head to newHead

    movq -24(%rbp), %rax     # Load head
    movq 4(%rax), %rax       # Load head->next
    testq %rax, %rax         # Check if next is NULL
    je .L4                   # If next is NULL, skip recursion

    movl -28(%rbp), %eax     # Load len
    leal -1(%eax), %edx      # len - 1
    movq -24(%rbp), %rax     # Load head
    movq 4(%rax), %rax       # Load head->next
    movl %edx, %esi          # Pass len - 1
    movq %rax, %rdi          # Pass head->next
    call sod                 # Recursive call
    movq %rax, -8(%rbp)      # Store result in newHead
    movq -24(%rbp), %rax     # Load head
    movq 4(%rax), %rax       # Load head->next
    movq -24(%rbp), %rdx     # Load head
    movq %rdx, 4(%rax)       # Update head->next->next

.L4:
    movq -24(%rbp), %rax     # Load head
    movq $0, 4(%rax)         # Set head->next = NULL
    movq -24(%rbp), %rax     # Load head
    movl (%rax), %edx        # Load head->val
    movl -28(%rbp), %eax     # Load len
    addl %eax, %edx          # head->val += len
    movq -24(%rbp), %rax     # Load head
    movl %edx, (%rax)        # Store updated val in head->val
    movq -8(%rbp), %rax      # Return newHead

.L3:
    leave                    # Restore stack and base pointer
    ret                      # Return

/**
as tickets.asm -o tickets.o && ld tickets.o -o tickets
gdb ./tickets
b *(_start + 20)
run
x/21wx &A  # we have 7 nodes, each takes 12 bytes, together: 84 bytes : 4 bytes = 21 words (word = 4 bytes)
rsp begining: 
0x7fffffffe0b0
0x7fffffffe080
0x7fffffffe050
0x7fffffffe020
0x7fffffffdff0
0x7fffffffdfc0
0x7fffffffdf90
0x7fffffffdf70
0x7fffffffdf98
0x7fffffffdfa0
 */