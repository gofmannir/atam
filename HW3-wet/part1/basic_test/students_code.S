.global _start

.global get_element_from_matrix, inner_prod, matrix_multiplication

.section .text

get_element_from_matrix:
    # int get_element_from_matrix(int* matrix[], unsigned long n, unsigned long row, unsigned long col);
    # rdi = matrix , n = rsi , row = rdx , col = rcx
    # callee saved registers: rbx, rsp, rbp, r12, r13, r14, r15

    # prolog
    pushq %rbp
    movq %rsp, %rbp

    # Calculate the linear index: row * max_col + col
    movq %rdx, %rax            # rax = row
    imulq %rsi, %rax           # rax = row * max_col
    addq %rcx, %rax            # rax = row * max_col + col

    # Calculate the address of the element: matrix + (row * max_col + col) * 4
    shlq $2, %rax              # rax = (row * max_col + col) * 4 (size of int)
    addq %rdi, %rax            # rax = matrix + (row * max_col + col) * 4

    # Load the element at the calculated address
    movl (%rax), %eax          # eax = *(matrix + (row * max_col + col))

    # Epilog
    movq %rbp, %rsp            # Restore stack pointer
    popq %rbp                  # Restore base pointer

    # Result is in %rax
	ret

inner_prod:
    # int inner_prod(int* mat_a[], int* mat_b[], unsigned long row_a, unsigned long col_b, unsigned long max_col_a, unsigned long max_col_b);
    # %rdi - int* mat_a[]
    # %rsi - int* mat_b[]
    # %edx - unsigned int row_a
    # %ecx - unsigned int col_b
    # %r8d - unsigned int max_col_a
    # %r9d - unsigned int max_col_b
    # callee saved registers: rbx, rsp, rbp, r12, r13, r14, r15

    # Epilog
    pushq %rbp
    movq %rsp, %rbp

    # store callee saved registers
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15

    xorl %r15d, %r15d  # sum = 0
    xorl %r10d, %r10d  # int i = 0
    movq %rdi, %r14    # r14 = mat_a (backup)
    movq %rsi, %r11    # r11 = mat_b (backup)
    movl %ecx, %r12d   # r12d = col_b (backup)
    movl %edx, %r13d   # r13d = row_a (backup)

loop_start:
    cmpl %r8d, %r10d
    jge loop_end  # if i >= max_col_a, exit loop

    # Push arguments for get_element_from_matrix(mat_a, max_col_a, row_a, i)
    movq %r14, %rdi   # matrix = mat_a
    movl %r8d, %esi   # n = max_col_a
    movl %r13d, %edx  # row = row_a
    movl %r10d, %ecx  # col = i
    call get_element_from_matrix

    # Store result temporarily
    pushq %rax

    # Push arguments for get_element_from_matrix(mat_b, max_col_b, i, col_b)
    movq %r11, %rdi  # matrix = mat_b
    movl %r9d, %esi  # n = max_col_b
    movl %r10d, %edx  # row = i
    movl %r12d, %ecx  # col = col_b
    call get_element_from_matrix

    # Multiply with previously stored value from mat_a
    popq %rdx
    imull %edx, %eax  # result *= element from mat_a

    # Add to sum
    addl %eax, %r15d  # sum += result

    # Increment i and loop
    incl %r10d
    jmp loop_start

loop_end:
    # Result is in %eax
    movl %r15d, %eax
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %rbp
    ret


matrix_multiplication:
    # int matrix_multiplication(int* res[], int* mat_a[], int* mat_b[], unsigned long m, unsigned long n, unsigned long w, unsigned long q, unsigned long p);
    #    int* res[],        # %rdi
    #    int* mat_a[],      # %rsi
    #    int* mat_b[],      # %rdx
    #    unsigned long m,   # %rcx
    #    unsigned long n,   # %r8
    #    unsigned long w,   # %r9
    #    unsigned long q,   # 16(%rbp) on the stack
    #    unsigned long p);  # 24(%rbp) on the stack

    pushq %rbp
    movq  %rsp, %rbp
    subq  $80, %rsp                # Reserve 80 bytes for locals and callee-saved regs

    # callee saved registers: rbx, rsp, rbp, r12, r13, r14, r15
    # Save callee-saved registers %r12 and %r13
    movq  %r12, -56(%rbp)
    movq  %r13, -64(%rbp)

    # Store parameters in local memory
    movq  %rdi, -8(%rbp)           # res
    movq  %rsi, -16(%rbp)          # mat_a
    movq  %rdx, -24(%rbp)          # mat_b
    movl  %ecx, -32(%rbp)          # m
    movl  %r8d, -36(%rbp)          # n
    movl  %r9d, -40(%rbp)          # w

    movq  16(%rbp), %r10           # q -> r10
    movl  %r10d, -44(%rbp)         # q (32-bit)
    movq  24(%rbp), %r10           # p -> r10
    movl  %r10d, -48(%rbp)         # p (32-bit)

    # Dimension check: for (m x n) * (o x q) we need n == o
    movl  -36(%rbp), %eax          # %eax = n
    cmpl  -40(%rbp), %eax          # compare n, o
    jne   multiplication_not_valid

    # i = 0
    xorl  %r12d, %r12d

outer_loop_start:
    cmpl  -32(%rbp), %r12d        # if i >= m => break
    jge   outer_loop_end

    # j = 0
    xorl  %r13d, %r13d

inner_loop_start:
    cmpl  -44(%rbp), %r13d        # if j >= q => break
    jge   inner_loop_end

    # Compute inner product: mat_a[i,*] dot mat_b[*,j]
    movq  -16(%rbp), %rdi     # mat_a
    movq  -24(%rbp), %rsi     # mat_b
    movl  %r12d,     %edx     # row_a = i
    movl  %r13d,     %ecx     # col_b = j
    movl  -36(%rbp), %r8d     # n
    movl  -44(%rbp), %r9d     # q
    call  inner_prod
    # result in %eax (could be negative)

    # 2 result mod p  (signed => remainder in [0..p-1])
    movl  -48(%rbp), %ecx     # p -> ECX
    cdq                       # sign-extend EAX into EDX:EAX
    idivl %ecx                # signed divide  EDX:EAX by ECX
                              # => EAX = quotient, EDX = remainder
    movl  %edx, %eax          # remainder => EAX (but might be negative)
    cmpl  $0, %eax
    jge   .skip_fix
    addl  %ecx, %eax          # if remainder < 0 => remainder += p
.skip_fix:

    # Store %eax in res[i][j]
    movq  -8(%rbp),  %rdi     # res
    movl  -44(%rbp), %esi     # max_col = q
    movl  %r12d,     %edx     # row = i
    movl  %r13d,     %ecx     # col = j
    movl  %eax,      %r8d     # value = remainder in [0..p-1]
    call  set_element_in_matrix

    # j++
    incl  %r13d
    jmp   inner_loop_start

inner_loop_end:
    # i++
    incl  %r12d
    jmp   outer_loop_start

outer_loop_end:
    movl  $1, %eax
    jmp   end

multiplication_not_valid:
    movl  $0, %eax

end:
    # Restore callee-saved registers
    movq  -64(%rbp), %r13
    movq  -56(%rbp), %r12
    addq  $80, %rsp
    popq  %rbp
    ret