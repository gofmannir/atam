.global _start

.section .data
 Node1:
    .quad 0
    .int 5
    .quad Node2

 Node2:
    .quad Node1
    .int 10
    .quad Node3

Node3:
    .quad Node2
    .int 25
    .quad Node4

Node4:
    .quad Node3
    .int 20
    .quad 0

node:
    .quad Node3

Result:
    .byte 0

.section .text
_start:
  # Load the address of 'node' into %rdi
    movq node(%rip), %rdi      # %rdi = temp pointer to the node to change

    # Save the pointer to the node to change
    movq %rdi, %r8              # %r8 = perminent pointer to the node to change

    # Initialize %rsi to the node to change
    movq %rdi, %rsi

    # Find the head of the list by traversing prev pointers
find_head:
    movq 0(%rsi), %rax          # %rax = current->prev (offset 0)
    cmpq $0, %rax
    je found_head               # If prev is NULL, we've found the head
    movq %rax, %rsi             # Move to prev node
    jmp find_head

found_head:
    # %rsi now points to the head node
    # %rsi = pointer to the current node (starting from head)
    # %rdi will be next node in iteration

    movq 12(%rsi), %rdi   # %rdi = head->next
    # if head->next is null there is only one node in list
    testq %rdi, %rdi
    jz always_possible

    # -----------------------------------------
    # Arithmetic Sequence Check
    # -----------------------------------------

    # Initialize flags and variables
    movl $1, %ebx            # %ebx = arithmetic possible flag (1 = possible)
    movl $1, %ecx            # %ecx = geometric possible flag (1 = possible)
    movl $0, %r9d            # %r9d = diff
    movl $0, %r10d           # %r10d = ratio
    
    # Start traversal
traverse_list:
    # Check if current node is the node to change
    cmpq %rdi, %r8
    jne process_node

    # If current node is the node to change
    # Set current pointer to node->next
    movq 12(%r8), %rsi        # %rsi = node->next (offset 12)
    # check if the node is last in the list
    cmpq $0, %rsi
    je end_traverse           # If node->next is NULL, end traversal
   
    # calculate node->next - node->prev and check if its equal to 2 x diff
    movq 0(%r8), %rax        # %rax = node->prev
    movl 8(%rax), %r14d      # %r14d = node->prev->data
    movl 8(%rsi), %r15d      # %r15d = node->next->data
    subl %r14d, %r15d        # %r15d = node->next->data - node->prev->data
    movl %r9d, %r14d         # %r14d = expected diff
    addl %r14d, %r14d        # %r14d = 2 x expected diff
    cmpl %r14d, %r15d        # check if  node->next->data - node->prev->data = 2 x expected diff
    jne not_arithmetic
  
    # Set next pointer to node->next->next
    movq 12(%rsi), %rdi       # %rdi = node->next->next
    cmpq $0, %rdi
    je end_traverse           # If node->next->next is NULL, end traversal

    jmp process_node

process_node:
    # Load current data value
    movl 8(%rsi), %r11d       # %r11d = current data value
    # Load next data value
    movl 8(%rdi), %r12d        # %r12d = next data value

    # Compute difference for arithmetic progression
    movl %r11d, %edx            # %edx = current data
    movl %r12d, %r13d           # %r13d = next data
    subl %edx, %r13d            # %r13d = next data - current data = diff

    # check if it's the first difference
    cmp $0, %r9d
    jne check_difference
    # If it's the first difference calculate, store it in r9d
    movl %r13d, %r9d            # %r9d = diff
    jmp advance_pointers

check_difference:
    # %r9d = previous diff
    # %r13d = current diff in iteration
    cmpl %r9d, %r13d
    je advance_pointers
    jmp not_arithmetic

not_arithmetic:
    # Differences not equal, arithmetic not possible
    movl $0, %ebx             # %ebx = arithmetic possible flag = 0
    jmp advance_pointers

advance_pointers:
    # Advance the pointers
    movq 12(%rsi), %rsi       # %rsi = current->next
    testq %rsi, %rsi          # Check if current->next is NULL
    jz end_traverse
    movq 12(%rsi), %rdi       # %rdi = current->next->next
    testq %rdi, %rdi          # Check if current->next->next is NULL
    jz end_traverse
    jmp traverse_list

end_traverse:
    # Set Result
    cmpl $1, %ebx              # Check arithmetic possible flag
    je arithmetic_possible
    # if arithmetic isn't possible, check geometric
    cmpl $1, %ecx
    jne never_possible
    # if possible, set Result to 2
    movb $2, Result(%rip)
    jmp done_HW1

arithmetic_possible:
    # check geometric
    cmpl $1, %ecx
    je always_possible
    movb $1, Result(%rip)    # only arithmetic
    jmp done_HW1

always_possible:
    movb $3, Result(%rip)
    jmp done_HW1

never_possible:
    movb $0, Result(%rip)
    jmp done_HW1

done_HW1:
    # Exit the program
    movq $60, %rax            # syscall: exit
    xor %rdi, %rdi            # status 0
    syscall

/*
as ex4.asm -o ex4.o && ld ex4.o -o ex4 && ./ex4
*/