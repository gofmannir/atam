.global _start

.section .data
 Node1:
    .quad 0
    .int 15
    .quad Node2

 Node2:
    .quad Node1
    .int 15
    .quad Node3

Node4:
    .quad Node3
    .int 5
    .quad 0

Node3:
    .quad 0
    .int 5
    .quad 0

head:
    .quad Node1

node:
    .quad 


.section .text
_start:
#your code here
