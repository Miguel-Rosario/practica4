.thumb              @ Ensambla usando el modo Thumb
.cpu cortex-m3      @ Genera instrucciones Cortex-M3
.syntax unified     @ Establece la sintaxis unificada

.include "ivt.s"                
.include "gpio_map.inc"         
.include "rcc_map.inc"          
.include "systick_map.inc"      
.include "nvic_reg_map.inc"     
.include "afio_map.inc"         
.include "exti_map.inc"         

.extern delay                   
.extern SysTick_Initialize      


check_speed:
    push    {r7} 
    sub     sp, sp, #4  
    add     r7, sp, #0

    cmp     r8, #1	//boton
    bne     C_S                @ Salta a C_S primera interrupcion
    mov     r0, #1000   
    adds    r7, r7, #4 
    mov     sp, r7 
    pop     {r7} 
    bx      lr 
C_S:
    cmp     r8, #2  //boton
    bne     C_S2                @ Salta a C_S2 segunda interrupcion
    mov     r0, #500   @ Establece r0 en el valor 500 (velocidad 2)
    adds    r7, r7, #4  
    mov     sp, r7 
    pop     {r7} 
    bx      lr  
C_S2:
    cmp     r8, #3  //boton
    bne     C_S3                @ Salta a C_S3 3
    mov     r0, #250            @ Establece r0 en el valor 250 (velocidad 3)
    adds    r7, r7, #4 
    mov     sp, r7  
    pop     {r7} 
    bx      lr 
C_S3:
    cmp     r8, #4              @ boton
    bne     C_S4     
    mov     r0, #125  
    adds    r7, r7, #4 
    mov     sp, r7  
    pop     {r7}               
    bx      lr                 
C_S4:
    mov     r8, #1              @ regresa boton 
    mov     r0, #1000           @ Establece r0 en el valor 1000 (velocidad 1)

    adds    r7, r7, #4         
    mov     sp, r7              
    pop     {r7}                
    bx      lr                  

.section .text
.align  1
.syntax unified
.thumb
.global __main
__main:
    push    {r7, lr}          
    sub     sp, sp, #16    
    add     r7, sp, #0  

    bl      SysTick_Initialize  @ Llama a la función SysTick_Initialize

    @ enabling clock in port A, B and C
    ldr     r2, =RCC_BASE   
    mov     r3, 0xC   
    str     r3, [r2, RCC_APB2ENR_OFFSET] 

    @ set pins PA0 to PA9 as digital output
    ldr     r2, =GPIOA_BASE  
    ldr     r3, =0x33333333 
    str     r3, [r2, GPIOx_CRL_OFFSET] 
    ldr     r3, =0x44444433     		
    str     r3, [r2, GPIOx_CRH_OFFSET]     	

    @ set pins PB0 and PB1 as digital input
    ldr     r2, =GPIOB_BASE
    ldr     r3, =0x44484448  		 //exti
    str     r3, [r2, GPIOx_CRL_OFFSET]  

    ldr     r0, =AFIO_BASE     
    mov     r1, #0    
    str     r1, [r0, AFIO_EXTICR1_OFFSET]  

    /*ldr     r0, =AFIO_BASE      		@ Carga la dirección base del registro AFIO en r0
    mov     r1, #0              		@ Carga el valor 0 en r1
    str     r1, [r0, AFIO_EXTICR2_OFFSET]  	@ Escribe el valor en el registro AFIO_EXTICR2
*/
    ldr     r0, =EXTI_BASE   
    mov     r1, #1      
    str     r1, [r0, EXTI_FTST_OFFSET]    
    ldr     r1, =0x11          
    str     r1, [r0, EXTI_RTST_OFFSET]

    str     r1, [r0, EXTI_IMR_OFFSET]  

    ldr     r0, =NVIC_BASE  
    ldr     r1, =0x440    
    str     r1, [r0, NVIC_ISER0_OFFSET] 

    # set led status initial value
    ldr     r3, =GPIOB_BASE     		@ Carga la dirección base del puerto GPIOB en r3
    mov     r4, 0x0             		@ Carga el valor 0 en r4
    str     r4, [r3, GPIOx_ODR_OFFSET]    	@ Escribe el valor en el registro GPIOx_ODR de GPIOB

    @ Set counter with 0
    mov     r3, 0x0             		@ Establece r3 en el valor 0
    str     r3, [r7, #4]        		@ Escribe el valor en la posición de memoria r7+4

    @ Set delay with 1000
    mov     r3, #1000           		@ Establece r3 en el valor 1000
    str     r3, [r7, #8]        		@ Escribe el valor en la posición de memoria r7+8

    @ Set counter initial status as increment
    mov     r5, #1              		@ Establece r5 en el valor 1
    mov     r8, #1              		@ Establece r8 en el valor 1

loop:
    @ Check if counter status is 1 or not
    bl      check_speed         		@ Llama a la función check_speed
    str     r0, [r7, #8]        		@ Guarda el resultado de check_speed en la posición de memoria r7+8
// lectura de boton a
    /*ldr     r0, =GPIOB_BASE
        ldr     r0, [r0, GPIOx_IDR_OFFSET]
        and     r0, r0, 0x1
        cmp     r0, 0x1*/
        //adds    r8, r8, #1

ldr     r0, =GPIOB_BASE
        ldr     r0, [r0, GPIOx_IDR_OFFSET]
        and     r0, r0, 0x10
        cmp     r0, 0x10
        bne     g1
    eor     r5, r5, #1
    and     r5, r5, #1

g1:

    cmp     r5, #1             
    bne     F1     
    ldr     r0, [r7, #4]    
    subs     r0, r0, #1      
    str     r0, [r7, #4]    
    b       F2 

F1:
    ldr     r0, [r7, #4]   
    add     r0, r0, #1    
    str     r0, [r7, #4]      

F2:
    /*ldr     r3, [r7, #8]      
    cmp     r0, r3          
    beq     F3                 

    @ Delay for some time
    ldr     r0, [r7, #8]        	
    bl      delay               	

    b       loop  */              

    //**ldr     r4, =0xffff 
    ldr     r3, =GPIOA_BASE     
    //ldr     r4, [r3, GPIOx_ODR_OFFSET]   
    add     r3, GPIOx_ODR_OFFSET
    //**ldr     r2, [r7, #4]
    ldr r4,[r7,#4] 
    mov r2, #0
    ldr r4, [r7,#4]
    orr r4, r2,r4
    
    //**eor     r4, r4, r2     
    str     r4, [r3]
    //str     r4, [r3, GPIOx_ODR_OFFSET]   

    /*ldr     r3, =0xffff
        ldr     r0, =GPIOA_BASE
        add     r0, GPIOx_ODR_OFFSET
        ldr     r2, [r7]
        and     r3, r3, r2
        str     r3, [r0]*/
    @ Delay for some time
    ldr     r0, [r7, #8]        	
    bl      delay          

    b       loop                		@ Salta a loop


