.include "exti_map.inc"
.include "gpio_map.inc"


.cpu cortex-m3      @ Generates Cortex-M3 instructions
.section .text
.align	1
.syntax unified
.thumb
.global EXTI0_Handler
EXTI0_Handler:
    ldr     r0, =GPIOB_BASE
    ldr     r0, [r0, GPIOx_IDR_OFFSET]
    and     r0, r0, 0x1
    cmp     r0, 0x1
    bne     g0
    adds    r8, r8, #1
g0:
    ldr     r0, =EXTI_BASE
    ldr     r1, [r0, EXTI_PR_OFFSET]
    orr     r1, r1, 0x1
    str     r1, [r0, EXTI_PR_OFFSET]
    bx      lr

.global EXTI4_Handler
EXTI4_Handler:
    /*ldr     r0, =GPIOB_BASE
        ldr     r0, [r0, GPIOx_IDR_OFFSET]
        and     r0, r0, 0x10
        cmp     r0, 0x10
        bne     g1
    eor     r5, r5, #1
    and     r5, r5, #1

g1:*/
   ldr     r0, =EXTI_BASE
    ldr     r1, [r0, EXTI_PR_OFFSET]
    orr     r1, r1, 0x10
    str     r1, [r0, EXTI_PR_OFFSET]
    bx      lr
    
