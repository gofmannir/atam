.global _start

.section .text
_start:
    # Load Num1 and Num2 into registers
    movl Num1(%rip), %eax       # Load Num1 into EAX
    movl Num2(%rip), %ebx       # Load Num2 into EBX
 
    # Initialize counters
    xorl %ecx, %ecx             # Counter for Num1 bits
    xorl %edx, %edx             # Counter for Num2 bits

count_bits_num1_HW1:
    testl $1, %eax
    jz skip_increment_num1_HW1
    incl %ecx
skip_increment_num1_HW1:
    shrl $1, %eax
    jnz count_bits_num1_HW1

count_bits_num2_HW1:
    testl $1, %ebx
    jz skip_increment_num2_HW1
    incl %edx

skip_increment_num2_HW1:
    shrl $1, %ebx
    jnz count_bits_num2_HW1

    # Compare the counts
    cmpl %ecx, %edx
    jne not_equal_HW1
    movb $1, BitCheck(%rip)     # Set BitCheck to 1 (true)
    jmp done_HW1

not_equal_HW1:
    movb $0, BitCheck(%rip)     # Set BitCheck to 0 (false)

done_HW1:
