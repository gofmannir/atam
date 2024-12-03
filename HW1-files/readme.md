$ objdump -D ./ex1

./ex1:     file format elf64-x86-64


Disassembly of section .text:

00000000004000b0 <_start>:
  4000b0:       8b 05 20 00 20 00       mov    0x200020(%rip),%eax        # 6000d6 <Num1>
  4000b6:       8b 1d 1e 00 20 00       mov    0x20001e(%rip),%ebx        # 6000da <Num2>
  4000bc:       c6 05 1b 00 20 00 01    movb   $0x1,0x20001b(%rip)        # 6000de <BitCheck>
  4000c3:       c6 05 14 00 20 00 00    movb   $0x0,0x200014(%rip)        # 6000de <BitCheck>
  4000ca:       48 c7 c0 3c 00 00 00    mov    $0x3c,%rax
  4000d1:       48 31 ff                xor    %rdi,%rdi
  4000d4:       0f 05                   syscall 

Disassembly of section .data:

00000000006000d6 <Num1>:
  6000d6:       01 00                   add    %eax,(%rax)
        ...

00000000006000da <Num2>:
  6000da:       02 00                   add    (%rax),%al
        ...

00000000006000de <BitCheck>:
        ...
student@student:~/Desktop/HW1-files$ gdb ./ex1
GNU gdb (Ubuntu 8.1-0ubuntu3.2) 8.1.0.20180409-git
Copyright (C) 2018 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
<http://www.gnu.org/software/gdb/documentation/>.
For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from ./ex1...(no debugging symbols found)...done.
(gdb) si
The program is not being run.
(gdb) b _start
Breakpoint 1 at 0x4000b0
(gdb) r
Starting program: /home/student/Desktop/HW1-files/ex1 

Breakpoint 1, 0x00000000004000b0 in _start ()
(gdb) si
0x00000000004000b6 in _start ()
(gdb) si
0x00000000004000bc in _start ()
(gdb) info registers
rax            0x1      1
rbx            0x2      2
rcx            0x0      0
rdx            0x0      0
rsi            0x0      0
rdi            0x0      0
rbp            0x0      0x0
rsp            0x7fffffffe0c0   0x7fffffffe0c0
r8             0x0      0
r9             0x0      0
r10            0x0      0
r11            0x0      0
r12            0x0      0
r13            0x0      0
r14            0x0      0
r15            0x0      0
rip            0x4000bc 0x4000bc <_start+12>
eflags         0x202    [ IF ]
cs             0x33     51
ss             0x2b     43
ds             0x0      0
es             0x0      0
fs             0x0      0
gs             0x0      0
(gdb) 