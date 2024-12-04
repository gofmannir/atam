.global _start

.section .data
Num1: 
	.int 0b10000000000000000000000000001011
Num2: 
	.int 0b00001000000000010000000110000000
BitCheck:
    .byte 0

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
    jmp end_program_HW1

not_equal_HW1:
    movb $0, BitCheck(%rip)     # Set BitCheck to 0 (false)

end_program_HW1:
    # Exit syscall as before

    movq $60, %rax
    xorq %rdi, %rdi
    syscall

/**
as ex1.asm -o ex1.o && ld ex1.o -o ex1 && ./ex1

**/