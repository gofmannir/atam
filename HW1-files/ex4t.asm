.section .data
Node1:
    .quad 0          # prev (offset 0)
    .int 5           # data (offset 8)
    .int 0           # padding (offset 12)
    .quad Node2      # next (offset 16)

Node2:
    .quad Node1
    .int 10
    .int 0
    .quad Node3

Node3:
    .quad Node2
    .int 25          # Node to change
    .int 0
    .quad Node4

Node4:
    .quad Node3
    .int 20
    .int 0
    .quad 0          # next (NULL)

node:
    .quad Node3

Result:
    .byte 0

.section .text
.global _start

_start:
    # Load the address of 'node' into %rdi
    movq node(%rip), %rdi       # %rdi = pointer to the node to change

    # Initialize pointers
    movq %rdi, %r8              # %r8 = node to change (for later use)

    # Find the head of the list by traversing prev pointers
    movq %rdi, %rsi             # %rsi = current node
    movl $0, %r15d              # %r15d = node counter

find_head:
    inc %r15d                   # Increment node counter
    movq 0(%rsi), %rax          # %rax = current->prev (offset 0)
    cmpq $0, %rax               # Check if prev is NULL
    je found_head               # If NULL, we've found the head
    movq %rax, %rsi             # Move to prev node
    jmp find_head

found_head:
    movq %rsi, %rbx             # %rbx = head node

    # Count nodes from head to tail to get total number of nodes
    movq %rbx, %rsi             # %rsi = current node (head)
    movl $0, %r14d              # %r14d = total node count (reset)

count_nodes:
    inc %r14d                   # Increment total node count
    movq 16(%rsi), %rsi         # %rsi = current->next (offset 16)
    cmpq $0, %rsi               # Check if end of list
    jne count_nodes

    # Check if total nodes <= 3
    cmp $3, %r14d
    jle small_list              # If list has 3 nodes or fewer

    # Proceed with progression checks
    # Initialize registers for traversal
    movq %rbx, %rsi             # %rsi = current node
    movl $0, %edx               # %edx = flag for first difference/ratio
    movl $1, %ecx               # %ecx = arithmetic possible flag (1 = possible)
    movl $1, %esi               # %esi = geometric possible flag (1 = possible)
    movl $0, %r9d               # %r9d = previous data value
    movl $0, %r10d              # %r10d = common difference (for arithmetic)
    movl $0, %r11d              # %r11d = common ratio (for geometric)

traverse_list:
    # If current node is the node to change, skip it
    cmpq %rsi, %r8
    je skip_node

    # Load current data value
    movl 8(%rsi), %r13d         # %r13d = current data value (offset 8)

    # If this is the first valid node, store its data
    cmp $0, %edx
    jne process_node

    # First valid node
    movl %r13d, %r9d            # %r9d = previous data value
    movl $1, %edx               # Set flag to indicate first valid data stored
    jmp next_node

process_node:
    # Compute difference for arithmetic progression
    movl %r13d, %eax            # %eax = current data value
    movl %r9d, %ebx             # %ebx = previous data value
    subl %ebx, %eax             # %eax = current data - previous data (difference)

    # If first difference, store it
    cmp $1, %edx
    jne check_difference
    movl %eax, %r10d            # %r10d = common difference
    jmp check_ratio

check_difference:
    # Compare with common difference
    cmpl %r10d, %eax
    je check_ratio
    # Differences not equal, arithmetic progression not possible
    movl $0, %ecx               # %ecx = arithmetic possible flag = 0

check_ratio:
    # Compute ratio for geometric progression
    # Check if previous data is zero to avoid division by zero
    cmp $0, %r9d
    je geom_not_possible

    movl %r13d, %eax            # %eax = current data value
    xorl %edx, %edx             # Clear %edx
    movl %r9d, %ebx             # %ebx = previous data value (divisor)
    divl %ebx                   # Unsigned division: %eax = quotient, %edx = remainder

    # Check if division is exact
    cmp $0, %edx
    jne geom_not_possible

    # If first ratio, store it
    cmp $1, %edx
    jne check_ratio_value
    movl %eax, %r11d            # %r11d = common ratio
    jmp store_previous

check_ratio_value:
    # Compare with common ratio
    cmpl %r11d, %eax
    je store_previous
    # Ratios not equal, geometric progression not possible
    movl $0, %esi               # %esi = geometric possible flag = 0
    jmp store_previous

geom_not_possible:
    # Geometric progression not possible
    movl $0, %esi               # %esi = geometric possible flag = 0

store_previous:
    # Store current data as previous data for next iteration
    movl %r13d, %r9d            # %r9d = current data value

next_node:
    # Move to next node
    movq 16(%rsi), %rsi         # %rsi = current->next (offset 16)
    cmpq $0, %rsi               # Check if end of list
    jne traverse_list

    # End of list
    # Set Result accordingly
    movl $0, %eax               # %eax = Result value

    cmp $1, %ecx                # Check arithmetic possible flag
    jne check_geom_flag
    movl $1, %eax               # %eax = 1 (arithmetic possible)

check_geom_flag:
    cmp $1, %esi                # Check geometric possible flag
    jne set_result
    # If arithmetic possible flag is also set, update Result
    cmp $1, %ecx
    jne geom_only
    movl $3, %eax               # %eax = 3 (both possible)
    jmp set_result

geom_only:
    movl $2, %eax               # %eax = 2 (geometric possible)

set_result:
    movb %al, Result(%rip)      # Store Result
    jmp finalize

skip_node:
    # Node to change encountered, skip it
    # Move to next node
    movq 16(%rsi), %rsi         # %rsi = current->next (offset 16)
    cmpq $0, %rsi               # Check if end of list
    jne traverse_list

    # End of list reached after skipping node
    # If only one or no valid nodes left, set Result to 3 (both possible)
    cmp $1, %edx
    jl small_list               # If less than one valid node, treat as small list
    cmp $1, %edx
    je small_list               # If exactly one valid node, treat as small list
    jmp set_result

small_list:
    # For lists with three nodes or fewer, we can always form a progression
    movl $3, %eax               # %eax = 3 (both possible)
    movb %al, Result(%rip)      # Store Result

finalize:
    # Exit the program
    movq $60, %rax              # syscall: exit
    xor %rdi, %rdi              # status 0
    syscall
