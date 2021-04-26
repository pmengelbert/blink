PAGE_SIZE = 0x1000 @ standard linux page size

GPIO_OFFSET = 0x20200 /* 
                         See page 5 of BCM2835 datasheet, the "physical addresses" section.
                         It's divided by 0x1000 because mmap2(2) takes the number of pages,
                         not the number of bytes.
                      */
GPIO_PIN_OUTPUT = 0xfffffe7f @ see note below

.data
filename: .asciz "/dev/gpiomem" @ /dev/gpiomem does not require root access
sleep_amount: .4byte 1, 0 @ the amount of time between blinks. See nanosleep(2). 1 second and 0 nanoseconds.

.text
.globl _start

_start:
    @ open /dev/gpiomem to pass to mmap2
    mov r7, #5
    ldr r0, =filename
    mov r1, #2
    mov r2, #0
    svc #0

    @ return value is file descriptor, which is the 5th argument to mmap2
    mov r4, r0

    @ mmap2. See mmap2(2)
    /*
        tldr: mmap2 will map a file (including special files like
        /dev/gpiomem) to the current process's address space. /dev/mem (or
        /dev/gpiomem) maps to the physical addresses of the machine.

        the return value of mmap2 is a pointer to memory owned by the local
        process, which if acted upon will affect the source of the map (i.e.
        /dev/gpiomem).
    */
    mov r0, #0
    mov r1, #PAGE_SIZE
    mov r2, #3 @ read and write access
    mov r3, #1 @ this is shared access
    ldr r5, =#GPIO_OFFSET @ the physical address of the GPIO pins
    mov r7, #192
    svc #0

    @ return value is base address of GPIO peripheral. Store this address in r8
    mov r8, r0

    /*
        for pin n:
        register is BASE_GPIO + n/10 (integer division)
        formula for function set to output: ~(7 << ((n % 10)*3)) | 1 << ((n % 10)*3)
        set the mode of pin 2 to output
    */
    ldr r0, =#GPIO_PIN_OUTPUT
    str r0, [r8]

.Lloop:
    @ clear pin 2
    mov r0, #4 @ the formula for setting or clearing pin n: 1 << n. Here, 1 << 2 = 4
    str r0, [r8, #0x28]

    @ nanosleep(2) syscall
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

    b .Lloop

    mov r7, #1
    mov r0, #0
 
    svc #0

@ vim:ft=armv5
