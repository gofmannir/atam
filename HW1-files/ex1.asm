.global _start

.section .text
_start:
    # Load Num1 and Num2 into registers
    movl Num1(%rip), %eax       
    movl Num2(%rip), %ebx       
 
    # Initialize counters
    xorl %ecx, %ecx             # counter for Num1 bits
    xorl %edx, %edx             # counter for Num2 bits

count_bits_num1_HW1:
    testl $1, %eax              # check if Num1 lsb is 1
    jz skip_increment_num1_HW1  # if no, skip increment counter
    incl %ecx                   # if yes, increment counter
skip_increment_num1_HW1:
    shrl $1, %eax               # shift right to check next lsb bit
    jnz count_bits_num1_HW1

count_bits_num2_HW1:
    testl $1, %ebx              # check if Num2 lsb is 1
    jz skip_increment_num2_HW1  # if no, skip increment counter
    incl %edx                   # if yes, increment counter

skip_increment_num2_HW1:
    shrl $1, %ebx               # shift right to check next lsb bit
    jnz count_bits_num2_HW1

    # Compare the counters
    cmpl %ecx, %edx
    jne not_equal_HW1
    movb $1, BitCheck(%rip)     # Set BitCheck to 1 (true)
    jmp done_HW1

not_equal_HW1:
    movb $0, BitCheck(%rip)     # Set BitCheck to 0 (false)

done_HW1:
