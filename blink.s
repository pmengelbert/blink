GPIO_OFFSET = 0x20200000
PAGE_SIZE = 0x1000

.data
filename: .asciz "/dev/gpiomem"

.bss
.lcomm gpio_filedes, 4

.section .text
.globl _start


_start:
    mov r7, #5
    ldr r0, addr_filename
    mov r1, #2
    mov r2, #0
    svc #0

    ldr r8, addr_gpio_filedes
    str r0, [r8]

    mov r7, #6
    svc #0

    mov r7, #1
    mov r0, #0
    svc #0

addr_filename: .word filename
addr_gpio_filedes: .word gpio_filedes
    
