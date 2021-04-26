GPIO_OFFSET = 0x20200
PAGE_SIZE = 0x1000
GPIO_PIN_OUTPUT = 0xfffffe7f

.data
filename: .asciz "/dev/gpiomem"
sleep_amount: .4byte 1, 0

.bss
.lcomm gpio_filedes, 4
.lcomm gpio, 4

.text
.globl _start


_start:
    mov r7, #5
    ldr r0, =filename
    mov r1, #2
    mov r2, #0
    svc #0

    ldr r8, =gpio_filedes
    str r0, [r8]

    @ mmap2
    mov r0, #0
    mov r1, #PAGE_SIZE
    mov r2, #3
    mov r3, #1 
    ldr r4, [r8]
    ldr r5, =#GPIO_OFFSET
    mov r7, #192
    svc #0

    @ store GPIO address
    ldr r8, =gpio
    str r0, [r8]
    ldr r8, [r8]

    @ set the mode of pin 2 to output
    ldr r0, =#GPIO_PIN_OUTPUT
    str r0, [r8]

loop:
    @ clear pin 2
    mov r0, #4
    str r0, [r8, #0x28]

    ldr r0, =sleep_amount
    mov r1, #0
    mov r7, #162
    svc #0

    @ turn on pin 2
    mov r0, #4
    str r0, [r8, #0x1c]

    ldr r0, =sleep_amount
    mov r1, #0
    mov r7, #162
    svc #0

    b loop

    mov r7, #1
    mov r0, #0
 
    svc #0
