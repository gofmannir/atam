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
    je always_possible

    # Find the head of the list by traversing prev pointers
find_head:
    movq 0(%rsi), %rax         # %rax = current->prev (offset 0)
    cmpq $0, %rax
    je found_head              # If prev is NULL, we've found the head
    movq %rax, %rsi            # Move to prev node
    jmp find_head

found_head:
    # %rsi now points to the head node
    # Save head pointer for later use
    movq %rsi, %r9             # %r9 = head node

    # ---------------------------------------
    # Arithmetic Progression Check Loop
    # ---------------------------------------

    # Initialize flags and variables
    movl $1, %ebx              # %ebx = arithmetic possible flag (1 = possible)
    movl $0, %r10d             # %r10d = stored difference (initialize to 0)
    movl $0, %r15d             # %r15d = flag if diff already calculated (1 if yes)

    # Set up pointers for traversal
    # If empty list, both possible
    testq %rsi, %rsi
    je always_possible

    movq 12(%rsi), %rdi        # %rdi = next node

    # If empty list, both possible
    testq %rsi, %rsi
    je always_possible

    # If there's only one node, both possible
    testq %rdi, %rdi
    je always_possible

arithmetic_loop:
    # Check if we've reached the end of the list
    cmpq $0, %rdi
    je arithmetic_done

    # Check if current node is the node to change
    # this case happens only if rsi us the node before rdi
    # this case happens only if the node is first
    cmpq %rsi, %r8
    je advance_pointers_arith

    # Check if next node is the node to change
    cmpq %rdi, %r8
    je arith_node_to_change_next

    # Load current and next data values
    movl 8(%rsi), %r11d        # %r11d = current data
    movl 8(%rdi), %r12d        # %r12d = next data

    # Compute difference: diff = next data - current data
    movl %r12d, %eax           # %eax = next data
    subl %r11d, %eax           # %eax = diff

    # Check if it's the first difference
    cmpl $0, %r15d
    jne check_arith_diff
    # First difference; store it
    movl %eax, %r10d           # %r10d = stored difference
    movl $1, %r15d             # change flag to 1 to indicate diff calculate
    jmp advance_pointers_arith

check_arith_diff:
    # Compare current diff (%eax) with stored diff (%r10d)
    cmpl %r10d, %eax
    je advance_pointers_arith
    # Differences not equal; arithmetic progression not possible
    movl $0, %ebx              # %ebx = arithmetic possible flag = 0
    jmp arithmetic_done

advance_pointers_arith:
    # Advance pointers
    movq %rdi, %rsi            # %rsi = next node
    movq 12(%rsi), %rdi        # %rdi = current->next
    jmp arithmetic_loop

arith_node_to_change_next:
    # Node to change is the next node
    # Need to check if (node->next->data - node->prev->data) == 2 * stored difference
    # Get current data
    movl 8(%rsi), %r11d        # %r11d = node->prev->data

    # Get next_next node
    movq 12(%rdi), %rax        # %rax = node->next
    cmpq $0, %rax
    je advance_pointers_arith  # If next->next is NULL, can't compute, skip

    movl 8(%rax), %r12d        # %r12d = node->next data

    xorq %rax, %rax            
    # Compute diff: diff = next_next data - current data
    movl %r12d, %eax           # %eax = next_next data
    subl %r11d, %eax           # %eax = current diff

    cmpl $0, %r15d             # check if diff is already calculated
    je calculate_expected_diff

    # Expected diff: expected_diff = 2 * stored difference
    movq %r10, %rdx           # %edx = stored difference
    addq %r10, %rdx           # %edx = 2 * stored difference

    # Compare diffs
    cmpq %rdx, %rax
    je skip_node_arith_next    # Can proceed, skip the node to change
    # Cannot form arithmetic progression by changing the node
    movl $0, %ebx              # %ebx = arithmetic possible flag = 0
    jmp arithmetic_done

calculate_expected_diff:
    movl $2, %r12d
    divl %r12d
    # Check if division is exact
    testl %edx, %edx
    jne arith_not_possible
    movl %eax, %r10d
    movl $1, %r15d
    jmp advance_pointers_arith

skip_node_arith_next:
    # Advance pointers
    movq 12(%rdi), %rsi        # %rsi = node->next
    movq 12(%rsi), %rdi        # %rdi = next node's next
    jmp arithmetic_loop

arith_not_possible:
    movl $0, %ebx              # %ebx = arithmetic possible flag = 0
    jmp arithmetic_done

arithmetic_done:

    # ---------------------------------------
    # Geometric Progression Check Loop
    # ---------------------------------------

    # Initialize flags and variables
    movl $1, %ecx              # %ecx = geometric possible flag (1 = possible)
    movl $0, %r13d             # %r13d = stored ratio (initialize to 0)
    movl $0, %r15d             # %r15d = flag if ratio already calculated (1 if yes)

    # Restore head pointer
    movq %r9, %rsi             # %rsi = head node
    movq 12(%rsi), %rdi        # %rdi = next node

    # If there's only one node, progression is always possible
    testq %rdi, %rdi
    je always_possible

geometric_loop:
    # Check if we've reached the end of the list
    cmpq $0, %rdi
    je geometric_done

    # Check if current node is the node to change
    # this case happens only if rsi us the node before rdi
    # this case happens only if the node is first
    cmpq %rsi, %r8
    je advance_pointers_geom

    # Check if next node is the node to change
    cmpq %rdi, %r8
    je geom_node_to_change_next

    # Load current and next data values
    movl 8(%rsi), %r11d        # %r11d = current data
    movl 8(%rdi), %r12d        # %r12d = next data

    # Check if current data is zero to avoid division by zero
    testl %r11d, %r11d
    je geom_not_possible

    # Compute ratio: ratio = next data / current data
    movl %r12d, %eax           # %eax = next data
    xorl %edx, %edx            # Clear %edx
    divl %r11d                 # Unsigned division

    # Check if division is exact
    testl %edx, %edx
    jne geom_not_possible

    # %eax now contains the ratio

    # Check if it's the first ratio
    cmpl $0, %r15d
    jne check_geom_ratio
    # First ratio; store it
    movl %eax, %r13d           # %r13d = stored ratio
    movl $1, %r15d             # update flag
    jmp advance_pointers_geom

check_geom_ratio:
    # Compare current ratio (%eax) with stored ratio (%r13d)
    cmpl %r13d, %eax
    je advance_pointers_geom
    # Ratios not equal; geometric progression not possible
    movl $0, %ecx              # %ecx = geometric possible flag = 0
    jmp geometric_done

advance_pointers_geom:
    # Advance pointers
    movq %rdi, %rsi            # %rsi = next node
    movq 12(%rsi), %rdi        # %rdi = current->next
    jmp geometric_loop

geom_node_to_change_next:
    # Node to change is the next node
    # Need to check if (next_next data) / (current data) == stored ratio * stored ratio
    # Get current data
    movl 8(%rsi), %r11d        # %r11d = current data

    # Get next_next node
    movq 12(%rdi), %rax        # %rax = next->next
    cmpq $0, %rax
    je advance_pointers_geom   # If next->next is NULL, can't compute, skip

    movl 8(%rax), %r12d        # %r12d = node->next->data

    cmpl $0, %r15d             # check if ratio is already calculated
    je calculate_expected_ratio

    # Check if current data is zero to avoid division by zero
    testl %r11d, %r11d
    je geom_not_possible

    # Compute expected ratio squared: expected_ratio_sq = stored ratio * stored ratio
    movl %r13d, %eax           # %eax = stored ratio
    xorl %edx, %edx            # Clear %edx
    mull %eax                  # %edx:%eax = stored ratio squared
    movl %eax,%r14d            # %r14d = ratio * ratio

    # Check for multiplication overflow
    testl %edx, %edx
    jne geom_not_possible

    # Compute ratio: ratio = next_next data / current data
    xorq %rax, %rax            # clear %rax
    movl %r12d, %eax           # %ecx = next_next data
    xorl %edx, %edx            # Clear %edx
    divl %r11d                 # Unsigned division: %eax = quotient, %edx = remainder

    # Check if division is exact
    testl %edx, %edx
    jne geom_not_possible

    # Compare computed ratio with expected_ratio_sq
    cmpl %eax, %r14d            # Since %eax is the division and r14d is ratio * ratio
    je skip_node_geom_next     # Can proceed, skip the node to change
    # Cannot form geometric progression by changing the node
    movl $0, %ecx              # %ecx = geometric possible flag = 0
    jmp geometric_done

calculate_expected_ratio:
    movq 12(%rax), %r11       # r11 is node->next->next
    cmpq $0, %r11
    je advance_pointers_geom
    movl 8(%r11), %eax      # eax is node->next->next->data
    # r12 is %r12d = node->next->data
    divl %r12d
    # Check if division is exact
    testl %edx, %edx
    jne geom_not_possible
    movl %eax, %r13d
    movl $1, %r15d
    jmp advance_pointers_geom

skip_node_geom_next:
    # Advance pointers
    movq 12(%rdi), %rsi        # %rsi = node->next
    movq 12(%rsi), %rdi        # %rdi = next node's next
    jmp geometric_loop

geom_not_possible:
    movl $0, %ecx              # %ecx = geometric possible flag = 0
    jmp geometric_done

geometric_done:

    # ---------------------------------------
    # Determine and Set Result
    # ---------------------------------------

    # Check arithmetic and geometric possible flags
    xorq %rax, %rax   # %eax = 0 (neither progression possible)           

    # Check arithmetic possible flag (%ebx)
    cmpl $1, %ebx
    jne check_geom_flag
    movl $1, %eax              # %eax = 1 (arithmetic progression possible)

check_geom_flag:
    cmpl $1, %ecx
    jne set_result
    # Geometric progression possible
    cmpl $1, %ebx
    jne geom_only
    movl $3, %eax              # %eax = 3 (both progressions possible)
    jmp set_result

geom_only:
    movl $2, %eax              # %eax = 2 (only geometric progression possible)

set_result:
    movb %al, result(%rip)     # Store Result
    jmp done_HW1

always_possible:
    # For lists with one or no nodes, both progressions are possible
    movb $3, result(%rip)      # Result = 3 (both possible)
    jmp done_HW1

done_HW1:

/*
as ex4t.asm ex4sample_test -o my_test.o && ld my_test.o -o ex4t && ./ex4t
 */