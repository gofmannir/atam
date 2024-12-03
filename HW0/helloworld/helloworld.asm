.global main

.data
helloworld: .ascii "Hello ATAM\n"
helloworldend:
goodluck: .asciz "Good Luck!\n"
goodluckend:

.text
main:
    # printf(helloworld)
    movq $1, %rax
    movq $1, %rdi
    movq $helloworld, %rsi
    movq $helloworldend-helloworld, %rdx
    syscall

    # printf(goodluck)
    movq $1, %rax
    movq $1, %rdi
    movq $goodluck, %rsi
    movq $goodluckend-goodluck, %rdx
    syscall

    xorq %rax, %rax
    ret

# # printf("Good ATAM")
#     movq $1, %rax                # syscall: write
#     movq $1, %rdi                # file descriptor: stdout
#     lea helloworld+6(%rip), %rsi # address of "ATAM" in helloworld
#     movq $goodluck-goodluckend+6, %rdx # length of "Good " (5) + length of "ATAM" (4)
#     syscall

#     xorq %rax, %rax              # return 0
#     ret