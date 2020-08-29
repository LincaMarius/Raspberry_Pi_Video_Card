/* See description at https://www.valvers.com/open-software/raspberry-pi/bare-metal-programming-in-c-part-4/ */

.global bootstrap
bootstrap:
    ldr pc, _reset_h
    ldr pc, _undefined_instruction_h
    ldr pc, _software_interrupt_h
    ldr pc, _prefetch_abort_h
    ldr pc, _data_abort_h
    ldr pc, _unused_handler_h
    ldr pc, _interrupt_h
    ldr pc, _fast_interrupt_h

_reset_h:                        .word   _reset_
    _undefined_instruction_h:    .word   undef_exc_
    _software_interrupt_h:       .word   /*software_interrupt_*/    hang
    _prefetch_abort_h:           .word   prefetch_exc_
    _data_abort_h:               .word   data_exc_
    _unused_handler_h:           .word   hang
    _interrupt_h:                .word   irq_handler_
    _fast_interrupt_h:           .word   /*fast_interrupt_handler*/ hang


;@ See linker script file
.globl bss_start
bss_start: .word __bss_start__

.globl bss_end
bss_end: .word __bss_end__

.globl pheap_space
pheap_space: .word _heap_start

.globl heap_sz
heap_sz: .word heap_size

/* The bootloader starts, loads are executable, and enters */
/* execution at 0x8000 with the following values set.      */
/* r0 = boot method (usually 0 on pi)       		   */
/* r1 = hardware type (usually 0xc42 on pi) 		   */
/* r2 = start of ATAGS ARM tag boot info (usually 0x100)   */

;@ Initial entry point
_reset_:
    /* Copy the vector table (top of this file) to the active table at 0x00000000 */
    mov     r3, #0x8000
    mov     r4, #0x0000
    ldmia   r3!,{r5, r6, r7, r8, r9, r10, r11, r12}
    stmia   r4!,{r5, r6, r7, r8, r9, r10, r11, r12}
    ldmia   r3!,{r5, r6, r7, r8, r9, r10, r11, r12}
    stmia   r4!,{r5, r6, r7, r8, r9, r10, r11, r12}
    mov sp, #0x8000

    ;// Get CPU Id
    mrc     p15,0,r3,c0,c0,0
    ldr     r4, =0x410fb767     ;@ RPI Gen. 1
    cmp     r3,r4
    beq     setup_stack     ;@ skip mode change

    /* Change to supervisor mode for RPI3, 1&2 already start in supervisor mode */
    mrs     r3,cpsr         ;@ reads the CPU mode register
    bic     r3,r3,#0x1F     ;@ clears the CPU MODE bits (It will be 1A currently if in HYP_MODE) preserving all else
    orr     r3,r3,#0x13     ;@ sets the CPU_MODE bits for SVC_MODE (0x13) with ORR still keeping all the other bits
    msr     spsr_cxsf,r3    ;@ writes that to the spsr_cxsf register so it gets loaded when he calls for the switch
    add     r3,pc,#4        ;@ calculates the address he wants to go into SVC_MODE from the pc (the two opcodes that follow are that long)
    msr     ELR_hyp,r3      ;@ writes that address value to ELR_hyp register
    eret                    ;@ does the elevated return command

;@"================================================================"
;@ Now setup stack pointers for the different CPU operation modes.
;@"================================================================"
setup_stack:
	cps	#0x11				/* set fiq mode */
	ldr	sp, =__FIQ_stack_core0
	cps	#0x12				/* set irq mode */
	ldr	sp, =__IRQ_stack_core0
	cps	#0x17				/* set abort mode */
	ldr	sp, =__abort_stack_core0
	cps	#0x1B				/* set "undefined" mode */
	ldr	sp, =__abort_stack_core0
	cps	#0x1F				/* set system mode */
	ldr	sp, =__SVC_stack_core0

    ;@ Fill BSS with zeros
    ldr   r4, bss_start
    ldr   r9, bss_end
    mov   r5, #0
clear_bss:
    str   r5,[r4]
    add   r4,r4,#4
    cmp   r4,r9
    ble   clear_bss

    /* Call our main function */
    /* The values r0 - r2 from bootloader are preserved */
    ldr r3, =entry_point
    blx r3

.global hang
hang:
    wfe
    b hang

undef_exc_:
	ldr	sp, =__abort_stack_core0
	sub	lr, lr, #4		/* lr: correct PC of aborted program */
	stmfd	sp!, {lr}			/* store PC onto stack */
	mrs	lr, spsr			/* lr can be overwritten now */
	stmfd	sp!, {lr}			/* store saved PSR onto stack */
	stmfd	sp, {r0-r14}^			/* store user registers r0-r14 (unbanked) */
	sub	sp, sp, #4*15			/* correct stack (not done by previous instruction */
	mov	r1, sp				/* save sp_abt or sp_und */
	cps	#0x12				/* set IRQ mode to access sp_irq and lr_irq */
	mov	r2, sp
	mov	r3, lr
	cps	#0x1F				/* our abort handler runs in system mode */
	mov	sp, r1				/* set sp_sys to stack top of abort stack */
	stmfd	sp!, {r2, r3}			/* store lr_irq and sp_irq onto stack */
	mov	r1, sp				/* r1: pointer to register frame */
	mov	r0, #1			/* r0: exception identifier */
	b	exception_handler_		/* jump to ExceptionHandler (never returns) */

prefetch_exc_:
	ldr	sp, =__abort_stack_core0
	sub	lr, lr, #4		/* lr: correct PC of aborted program */
	stmfd	sp!, {lr}			/* store PC onto stack */
	mrs	lr, spsr			/* lr can be overwritten now */
	stmfd	sp!, {lr}			/* store saved PSR onto stack */
	stmfd	sp, {r0-r14}^			/* store user registers r0-r14 (unbanked) */
	sub	sp, sp, #4*15			/* correct stack (not done by previous instruction */
	mov	r1, sp				/* save sp_abt or sp_und */
	cps	#0x12				/* set IRQ mode to access sp_irq and lr_irq */
	mov	r2, sp
	mov	r3, lr
	cps	#0x1F				/* our abort handler runs in system mode */
	mov	sp, r1				/* set sp_sys to stack top of abort stack */
	stmfd	sp!, {r2, r3}			/* store lr_irq and sp_irq onto stack */
	mov	r1, sp				/* r1: pointer to register frame */
	mov	r0, #2			/* r0: exception identifier */
	b	exception_handler_		/* jump to ExceptionHandler (never returns) */

data_exc_:
	ldr	sp, =__abort_stack_core0
	sub	lr, lr, #8		/* lr: correct PC of aborted program */
	stmfd	sp!, {lr}			/* store PC onto stack */
	mrs	lr, spsr			/* lr can be overwritten now */
	stmfd	sp!, {lr}			/* store saved PSR onto stack */
	stmfd	sp, {r0-r14}^			/* store user registers r0-r14 (unbanked) */
	sub	sp, sp, #4*15			/* correct stack (not done by previous instruction */
	mov	r1, sp				/* save sp_abt or sp_und */
	cps	#0x12				/* set IRQ mode to access sp_irq and lr_irq */
	mov	r2, sp
	mov	r3, lr
	cps	#0x1F				/* our abort handler runs in system mode */
	mov	sp, r1				/* set sp_sys to stack top of abort stack */
	stmfd	sp!, {r2, r3}			/* store lr_irq and sp_irq onto stack */
	mov	r1, sp				/* r1: pointer to register frame */
	mov	r0, #3			/* r0: exception identifier */
	b	exception_handler_		/* jump to ExceptionHandler (never returns) */
