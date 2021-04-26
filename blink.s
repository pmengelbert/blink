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
    mov r0, #0
    mov r1, #PAGE_SIZE
    mov r2, #3
    mov r3, #1 
    ldr r5, =#GPIO_OFFSET
    mov r7, #192
    svc #0

    @ return value is base address of GPIO peripheral. Store this address in r8
    mov r8, r0

    @ for pin n:
    @ register is BASE_GPIO + n/10 (integer division)
    @ formula for function set to output: ~(7 << ((n % 10)*3)) | 1 << ((n % 10)*3)
    @ set the mode of pin 2 to output
    ldr r0, =#GPIO_PIN_OUTPUT
    str r0, [r8]

loop:
    @ clear pin 2
    mov r0, #4
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

    b loop

    mov r7, #1
    mov r0, #0
 
    svc #0
