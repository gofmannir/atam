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
    movq node(%rip), %rdi      # %rdi = pointer to the node to change

    # Save the pointer to the node to change
    movq %rdi, %r8              # %r8 = node to change (for later use)

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
    movq %rsi, %rbx             # %rbx = head node

    # Initialize traversal variables
    movq %rbx, %rsi             # %rsi = current node
    movl $0, %edx               # %edx = flag indicating if previous data is stored
    movl $1, %ecx               # %ecx = arithmetic possible flag (1 = possible)
    movl $1, %r12d              # %r12d = geometric possible flag (1 = possible)
    movl $0, %r9d               # %r9d = previous data value
    movl $0, %r10d              # %r10d = common difference (d)
    movl $0, %r11d              # %r11d = common ratio (r)

    # -----------------------------------------
    # Arithmetic Sequence Check
    # -----------------------------------------

    # Traverse the list from head to node->prev
arithmetic_before_node:
    # Check if current node is the node to change
    cmpq %rsi, %r8
    je arithmetic_after_node    # Skip the node to change

    # Load current data value
    movl 8(%rsi), %r13d         # %r13d = current data value (offset 8)

    # If this is the first node, store its data
    cmp $0, %edx
    jne arithmetic_process_node_before

    # First node
    movl %r13d, %r9d            # %r9d = previous data value
    movl $1, %edx               # Set flag to indicate first data stored
    jmp arithmetic_next_node_before

arithmetic_process_node_before:
    # Compute difference d = current data - previous data
    movl %r13d, %eax            # %eax = current data
    movl %r9d, %ebx             # %ebx = previous data
    subl %ebx, %eax             # %eax = d

    # If first difference, store it
    cmp $1, %edx
    jne arithmetic_check_difference_before
    movl %eax, %r10d            # %r10d = common difference (d)
    jmp arithmetic_store_previous_before

arithmetic_check_difference_before:
    # Compare with common difference
    cmpl %r10d, %eax
    je arithmetic_store_previous_before
    # Differences not equal, arithmetic progression not possible
    movl $0, %ecx               # %ecx = arithmetic possible flag = 0
    jmp arithmetic_after_node   # Break out of loop

arithmetic_store_previous_before:
    # Store current data as previous data
    movl %r13d, %r9d
    jmp arithmetic_next_node_before

arithmetic_next_node_before:
    # Move to next node
    movq 12(%rsi), %rsi         # %rsi = current->next (offset 12)
    cmpq %rsi, %r8              # Check if we've reached the node to change
    jne arithmetic_before_node

arithmetic_after_node:
    # Skip the node to change and start from node->next
    movq 12(%r8), %rsi          # %rsi = node->next

arithmetic_traverse_after_node:
    # Check if current node is NULL
    cmpq $0, %rsi
    je arithmetic_check_result  # End of list

    # Load current data value
    movl 8(%rsi), %r13d         # %r13d = current data value

    movq 12(%rsi), %rsi         # %rsi = current->next (offset 12)
    cmpq $0, %rsi               # Check if next is NULL
    je arithmetic_check_result  # If last node, jump to result


    # Compute difference d = current data - previous data
    movl %r13d, %eax            # %eax = current data
    movl %r9d, %ebx             # %ebx = previous data
    subl %ebx, %eax             # %eax = d

    # Compare with common difference
    cmpl %r10d, %eax
    je arithmetic_store_previous_after
    # Differences not equal, arithmetic progression not possible
    movl $0, %ecx               # %ecx = arithmetic possible flag = 0
    jmp arithmetic_check_result

arithmetic_store_previous_after:
    # Store current data as previous data
    movl %r13d, %r9d
    # Move to next node
    movq 12(%rsi), %rsi         # %rsi = current->next
    jmp arithmetic_traverse_after_node

arithmetic_check_result:
    # %ecx holds the arithmetic possible flag (1 = possible, 0 = not possible)

    # -----------------------------------------
    # Geometric Sequence Check
    # -----------------------------------------

    # Re-initialize traversal variables
    movq %rbx, %rsi             # %rsi = head node
    movl $0, %edx               # %edx = flag indicating if previous data is stored
    movl $1, %r12d               # %r12d = geometric possible flag (1 = possible)
    movl $0, %r9d               # %r9d = previous data value
    movl $0, %r11d              # %r11d = common ratio (r)

    # Traverse the list from head to node->prev
geometric_before_node:
    # Check if current node is the node to change
    cmpq %rsi, %r8
    je geometric_after_node     # Skip the node to change

    # Load current data value
    movl 8(%rsi), %r13d         # %r13d = current data value

    # If this is the first node, store its data
    cmp $0, %edx
    jne geometric_process_node_before

    # First node
    movl %r13d, %r9d            # %r9d = previous data value
    movl $1, %edx               # Set flag to indicate first data stored
    jmp geometric_next_node_before

geometric_process_node_before:
    # Check if previous data is zero (cannot divide by zero)
    cmp $0, %r9d
    je geometric_not_possible

    # Compute ratio r = current data / previous data
    movl %r13d, %eax            # %eax = current data
    xorl %edx, %edx             # Clear %edx
    divl %r9d                   # Unsigned division: %eax = quotient, %edx = remainder

    # Check if division is exact
    cmp $0, %edx
    jne geometric_not_possible

    # If first ratio, store it
    cmp $1, %edx
    jne geometric_check_ratio_before
    movl %eax, %r11d            # %r11d = common ratio (r)
    jmp geometric_store_previous_before

geometric_check_ratio_before:
    # Compare with common ratio
    cmpl %r11d, %eax
    je geometric_store_previous_before
    # Ratios not equal, geometric progression not possible
    movl $0, %r12d              # %r12d = geometric possible flag = 0
    jmp geometric_after_node    # Break out of loop

geometric_store_previous_before:
    # Store current data as previous data
    movl %r13d, %r9d
    jmp geometric_next_node_before

@ check_ratio:
@     # Check for geometric progression
@     # Check if previous data is zero
@     cmp $0, %r9d
@     je geom_not_possible

@     movl %r13d, %eax          # %eax = current data
@     xorl %edx, %edx           # Clear %edx
@     divl %r9d                 # Unsigned division

@     # Check if division is exact
@     cmp $0, %edx
@     jne geom_not_possible

@     # If first ratio, store it
@     cmp $0, %r11d
@     jne check_ratio_value
@     movl %eax, %r11d          # %r11d = common ratio
@     jmp store_previous

@ check_ratio_value:
@     # Compare with common ratio
@     cmpl %r11d, %eax
@     je store_previous
@     # Ratios not equal, geometric progression not possible
@     movl $0, %r12d            # %r12d = geometric possible flag = 0

@ geom_not_possible:
@     movl $0, %r12d            # %r12d = geometric possible flag = 0

@ store_previous:
@     # Advance the pointers
@     movq %rsi, %rdi           # %rdi = current node becomes previous node
@     movq 12(%rsi), %rsi       # %rsi = current->next
@     cmpq $0, %rsi
@     jne traverse_list

geometric_next_node_before:
    # Move to next node
    movq 12(%rsi), %rsi         # %rsi = current->next
    cmpq %rsi, %r8              # Check if we've reached the node to change
    jne geometric_before_node

geometric_after_node:
    # Skip the node to change and start from node->next
    movq 12(%r8), %rsi          # %rsi = node->next

geometric_traverse_after_node:
    # Check if current node is NULL
    cmpq $0, %rsi
    je geometric_check_result   # End of list

    # Load current data value
    movl 8(%rsi), %r13d         # %r13d = current data value

    # Check if previous data is zero
    cmp $0, %r9d
    je geometric_not_possible

    # Compute ratio r = current data / previous data
    movl %r13d, %eax            # %eax = current data
    xorl %edx, %edx             # Clear %edx
    divl %r9d                   # Unsigned division
    cmp $0, %edx
    jne geometric_not_possible

    # Compare with common ratio
    cmpl %r11d, %eax
    je geometric_store_previous_after
    # Ratios not equal, geometric progression not possible
    movl $0, %r12d               # %r12d = geometric possible flag = 0
    jmp geometric_check_result

geometric_store_previous_after:
    # Store current data as previous data
    movl %r13d, %r9d
    # Move to next node
    movq 12(%rsi), %rsi         # %rsi = current->next
    jmp geometric_traverse_after_node

geometric_not_possible:
    movl $0, %r12d               # %r12d = geometric possible flag = 0

geometric_check_result:
    # %r12d holds the geometric possible flag (1 = possible, 0 = not possible)

    # -----------------------------------------
    # Set Result
    # -----------------------------------------

    movl $0, %eax               # %eax = Result value

    cmp $1, %ecx                # Check arithmetic possible flag
    jne check_geometric_flag
    movl $1, %eax               # %eax = 1 (arithmetic possible)

check_geometric_flag:
    cmp $1, %r12d                # Check geometric possible flag
    jne set_result
    cmp $1, %ecx
    jne geometric_only
    movl $3, %eax               # %eax = 3 (both possible)
    jmp set_result

geometric_only:
    movl $2, %eax               # %eax = 2 (geometric possible)

set_result:
    movb %al, Result(%rip)      # Store Result
    jmp done_HW1

done_HW1:
    # Exit the program
    movq $60, %rax              # syscall: exit
    xor %rdi, %rdi              # status 0
    syscall


/*
as ex4.asm -o ex4.o && ld ex4.o -o ex4 && ./ex4
*/