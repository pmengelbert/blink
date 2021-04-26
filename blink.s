GPIO_OFFSET = 0x20200
PAGE_SIZE = 0x1000

.data
filename: .asciz "/dev/gpiomem"

.bss
.lcomm gpio_filedes, 4

.text
.globl _start


_start:
    mov r7, #5
    ldr r0, =filename
    ldr r0, [r0]
    mov r1, #2
    mov r2, #0
    svc #0


    ldr r8, =gpio_filedes
    str r0, [r8] ; store the file descriptor somewhere

    mov r0, #0 ; NULL means address will be determined for me
    mov r1, #PAGE_SIZE
    mov r2, #3 ; read and write
    mov r3, #1 ; shared
    mov r4, [r8]
    mov r5, #GPIO_OFFSET
    mov r7, #192 ; mmap2
    svc #0

    ; close the file
    ; mov r7, #6
    ; svc #0

    ; exit
    mov r7, #1
    mov r0, #0
    svc #0
