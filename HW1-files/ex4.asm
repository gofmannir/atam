.global _start

.section .text
_start:
   # Load the address of 'node' into %rdi
    movq node(%rip), %rdi      # %rdi = pointer to the node to change

    # Save the pointer to the node to change
    movq %rdi, %r8             # %r8 = permanent pointer to the node to change

    # Initialize %rsi to the node to change
    movq %rdi, %rsi

    # If empty list, both possible
    testq %rsi, %rsi
    je always_possible_HW1

    # Find the head of the list by traversing prev pointers
find_head_HW1:
    movq 0(%rsi), %rax         # %rax = current->prev (offset 0)
    cmpq $0, %rax
    je found_head_HW1              # If prev is NULL, we've found the head
    movq %rax, %rsi            # Move to prev node
    jmp find_head_HW1

found_head_HW1:
    # %rsi now points to the head node
    # Save head pointer for later use
    movq %rsi, %r9             # %r9 = head node

    # Initialize element count to 0
    xorq %rcx, %rcx            # %rcx = count = 0

iterate_list_HW1:
    # Check if the current node is NULL (end of list)
    testq %rsi, %rsi
    je check_count_HW1             # If %rsi is NULL we're done

    # Increment count
    incq %rcx

    # Move to the next node
    movq 12(%rsi), %rsi         # %rsi = current->next (offset 8)
    jmp iterate_list_HW1

check_count_HW1:
    # Compare count with 3
    cmpq $2, %rcx
    jbe always_possible_HW1        # If count < 2 always possible
    cmpq $3, %rcx
    je three_elements_HW1
    # if more than 3 elements - need to check which serie it
    jmp check_serie_HW1

three_elements_HW1:
    movq 0(%r8), %rbx       # %rbx = node->prev (offset 0)
    # Check if the node->prev is NULL (then node is the head)
    testq %rbx, %rbx 
    je check_serie_HW1          # if node is the head need to check the other elements
    movq 12(%r8), %rcx       # %rcx = node->next (offset 12)
    testq %rcx, %rcx 
    je check_serie_HW1          # if node is the tail need to check the other elements
    # node in the middle
    jmp always_possible_HW1

check_serie_HW1:
    xorq %rbx, %rbx
    xorq %rcx, %rcx
    movq %r9, %rsi

    # ---------------------------------------
    # Arithmetic Progression Check Loop
    # ---------------------------------------

    # Initialize flags and variables
    movq $1, %rbx              # %rbx = arithmetic possible flag (1 = possible)
    movl $0, %r10d             # %r10d = stored difference (initialize to 0)
    movl $0, %r15d             # %r15d = flag if diff already calculated (1 if yes)

    movq 12(%rsi), %rdi        # %rdi = next node

    # If empty list, both possible
    testq %rsi, %rsi
    je always_possible_HW1

    # If there's only one node, both possible
    testq %rdi, %rdi
    je always_possible_HW1

arithmetic_loop_HW1:
    # Check if we've reached the end of the list
    cmpq $0, %rdi
    je arithmetic_done_HW1

    # Check if current node is the node to change
    # this case happens only if rsi us the node before rdi
    # this case happens only if the node is first
    cmpq %rsi, %r8
    je advance_pointers_arith_HW1

    # Check if next node is the node to change
    cmpq %rdi, %r8
    je arith_node_to_change_next_HW1

    # Load current and next data values
    movl 8(%rsi), %r11d        # %r11d = current data
    movl 8(%rdi), %r12d        # %r12d = next data

    # Compute difference: diff = next data - current data
    movl %r12d, %eax           # %eax = next data
    subl %r11d, %eax           # %eax = diff

    # Check if it's the first difference
    cmpl $0, %r15d
    jne check_arith_diff_HW1
    # First difference; store it
    movl %eax, %r10d           # %r10d = stored difference
    movl $1, %r15d             # change flag to 1 to indicate diff calculate
    jmp advance_pointers_arith_HW1

check_arith_diff_HW1:
    # Compare current diff (%eax) with stored diff (%r10d)
    cmpl %r10d, %eax
    je advance_pointers_arith_HW1
    # Differences not equal; arithmetic progression not possible
    movl $0, %ebx              # %ebx = arithmetic possible flag = 0
    jmp arithmetic_done_HW1

advance_pointers_arith_HW1:
    # Advance pointers
    movq %rdi, %rsi            # %rsi = next node
    movq 12(%rsi), %rdi        # %rdi = current->next
    jmp arithmetic_loop_HW1

arith_node_to_change_next_HW1:
    # Node to change is the next node
    # Need to check if (node->next->data - node->prev->data) == 2 * stored difference
    # Get current data
    movl 8(%rsi), %r11d        # %r11d = node->prev

    # Get next_next node
    movq 12(%rdi), %rax        # %rax = node->next
    cmpq $0, %rax
    je advance_pointers_arith_HW1  # If next->next is NULL, can't compute, skip

    movl 8(%rax), %r12d        # %r12d = node->next data

    xorq %rax, %rax            
    # Compute diff: diff = next_next data - current data
    movl %r12d, %eax           # %eax = next_next data
    subl %r11d, %eax           # %eax = current diff

    cmpl $0, %r15d             # check if diff is already calculated
    je calculate_expected_diff_HW1

    # Expected diff: expected_diff = 2 * stored difference
    movq %r10, %rdx           # %edx = stored difference
    addq %r10, %rdx           # %edx = 2 * stored difference

    # Compare diffs
    cmpq %rdx, %rax
    je skip_node_arith_next_HW1    # Can proceed, skip the node to change
    # Cannot form arithmetic progression by changing the node
    movl $0, %ebx              # %ebx = arithmetic possible flag = 0
    jmp arithmetic_done_HW1

calculate_expected_diff_HW1:
    movl $2, %r12d
    xorl %edx, %edx
    divl %r12d
    # Check if division is exact
    testl %edx, %edx
    jne arith_not_possible_HW1
    movl %eax, %r10d
    movl $1, %r15d
    jmp arith_check_from_begining_HW1

arith_check_from_begining_HW1:
    movq %r9, %rsi             # %rsi = head node
    movq 12(%rsi), %rdi        # %rdi = next node
    jmp arith_node_to_change_next_HW1

skip_node_arith_next_HW1:
    # Advance pointers
    movq 12(%rdi), %rsi        # %rsi = node->next
    movq 12(%rsi), %rdi        # %rdi = next node's next
    jmp arithmetic_loop_HW1

arith_not_possible_HW1:
    movl $0, %ebx              # %ebx = arithmetic possible flag = 0
    jmp arithmetic_done_HW1

arithmetic_done_HW1:

    # ---------------------------------------
    # Geometric Progression Check Loop
    # ---------------------------------------

    # Initialize flags and variables
    movq $1, %rcx              # %rcx = geometric possible flag (1 = possible)
    movl $0, %r13d             # %r13d = stored ratio (initialize to 0)
    movl $0, %r15d             # %r15d = flag if ratio already calculated (1 if yes)

    # Restore head pointer
    movq %r9, %rsi             # %rsi = head node
    movq 12(%rsi), %rdi        # %rdi = next node

    # If there's only one node, progression is always possible
    testq %rdi, %rdi
    je always_possible_HW1

geometric_loop_HW1:
    # Check if we've reached the end of the list
    cmpq $0, %rdi
    je geometric_done_HW1

    # Check if current node is the node to change
    # this case happens only if rsi us the node before rdi
    # this case happens only if the node is first
    cmpq %rsi, %r8
    je advance_pointers_geom_HW1

    # Check if next node is the node to change
    cmpq %rdi, %r8
    je geom_node_to_change_next_HW1

    # Load current and next data values
    movl 8(%rsi), %r11d        # %r11d = current data
    movl 8(%rdi), %r12d        # %r12d = next data

    # Check if current data is zero to avoid division by zero
    testl %r11d, %r11d
    je geom_not_possible_HW1

    # Compute ratio: ratio = next data / current data
    movl %r12d, %eax           # %eax = next data
    xorl %edx, %edx            # Clear %edx
    divl %r11d                 # Unsigned division

    # Check if division is exact
    testl %edx, %edx
    jne geom_not_possible_HW1

    # %eax now contains the ratio

    # Check if it's the first ratio
    cmpl $0, %r15d
    jne check_geom_ratio_HW1
    # First ratio; store it
    movl %eax, %r13d           # %r13d = stored ratio
    movl $1, %r15d             # update flag
    jmp advance_pointers_geom_HW1

check_geom_ratio_HW1:
    # Compare current ratio (%eax) with stored ratio (%r13d)
    cmpl %r13d, %eax
    je advance_pointers_geom_HW1
    # Ratios not equal; geometric progression not possible
    movl $0, %ecx              # %ecx = geometric possible flag = 0
    jmp geometric_done_HW1

advance_pointers_geom_HW1:
    # Advance pointers
    movq %rdi, %rsi            # %rsi = next node
    movq 12(%rsi), %rdi        # %rdi = current->next
    jmp geometric_loop_HW1

geom_node_to_change_next_HW1:
    # Node to change is the next node
    # Need to check if (next_next data) / (current data) == stored ratio * stored ratio
    # Get current data
    movl 8(%rsi), %r11d        # %r11d = current data

    # Get next_next node
    movq 12(%rdi), %rax        # %rax = node->next
    cmpq $0, %rax
    je advance_pointers_geom_HW1   # If next->next is NULL, can't compute, skip

    movl 8(%rax), %r12d        # %r12d = node->next->data

    cmpl $0, %r15d             # check if ratio is already calculated
    je calculate_expected_ratio_HW1

    # Check if current data is zero to avoid division by zero
    testl %r11d, %r11d
    je geom_not_possible_HW1

    # Compute expected ratio squared: expected_ratio_sq = stored ratio * stored ratio
    movl %r13d, %eax           # %eax = stored ratio
    xorl %edx, %edx            # Clear %edx
    mull %eax                  # %edx:%eax = stored ratio squared
    movl %eax,%r14d            # %r14d = ratio * ratio

    # Check for multiplication overflow
    testl %edx, %edx
    jne geom_not_possible_HW1

    # Compute ratio: ratio = next_next data / current data
    xorq %rax, %rax            # clear %rax
    movl %r12d, %eax           # %ecx = next_next data
    xorl %edx, %edx            # Clear %edx
    divl %r11d                 # Unsigned division: %eax = quotient, %edx = remainder

    # Check if division is exact
    testl %edx, %edx
    jne geom_not_possible_HW1

    # Compare computed ratio with expected_ratio_sq
    cmpl %eax, %r14d            # Since %eax is the division and r14d is ratio * ratio
    je skip_node_geom_next_HW1     # Can proceed, skip the node to change
    # Cannot form geometric progression by changing the node
    movl $0, %ecx              # %ecx = geometric possible flag = 0
    jmp geometric_done_HW1

calculate_expected_ratio_HW1:
    xorq %r11, %r11
    movq 12(%rax), %r11       # r11 is node->next->next
    cmpq $0, %r11
    je advance_pointers_geom_HW1
    xorq %rdx, %rdx
    movl 8(%r11), %eax      # eax is node->next->next->data
    # r12 is %r12d = node->next->data
    divl %r12d
    # Check if division is exact
    testl %edx, %edx
    jne geom_not_possible_HW1
    movl %eax, %r13d
    movl $1, %r15d
    jmp check_from_begining_HW1

check_from_begining_HW1:
    movq %r9, %rsi             # %rsi = head node
    movq 12(%rsi), %rdi        # %rdi = next node
    jmp geom_node_to_change_next_HW1

skip_node_geom_next_HW1:
    # Advance pointers
    movq 12(%rdi), %rsi        # %rsi = node->next
    movq 12(%rsi), %rdi        # %rdi = next node's next
    jmp geometric_loop_HW1

geom_not_possible_HW1:
    movl $0, %ecx              # %ecx = geometric possible flag = 0
    jmp geometric_done_HW1

geometric_done_HW1:

    # ---------------------------------------
    # Determine and Set Result
    # ---------------------------------------

    # Check arithmetic and geometric possible flags
    xorq %rax, %rax   # %eax = 0 (neither progression possible)           

    # Check arithmetic possible flag (%ebx)
    cmpl $1, %ebx
    jne check_geom_flag_HW1
    movl $1, %eax              # %eax = 1 (arithmetic progression possible)

check_geom_flag_HW1:
    cmpl $1, %ecx
    jne set_result_HW1
    # Geometric progression possible
    cmpl $1, %ebx
    jne geom_only_HW1
    movl $3, %eax              # %eax = 3 (both progressions possible)
    jmp set_result_HW1

geom_only_HW1:
    movl $2, %eax              # %eax = 2 (only geometric progression possible)

set_result_HW1:
    movb %al, result(%rip)     # Store Result
    jmp done_HW1

always_possible_HW1:
    # For lists with one or no nodes, both progressions are possible
    movb $3, result(%rip)      # Result = 3 (both possible)
    jmp done_HW1

done_HW1:
