/*
lab4, 1. INTRODUCTION TO INTERRUPTS
Name: Alexander Nunez
Class #: 11697
PI Name: Chris Crary
Description:  Within this program, a timer/counter to trigger an overflow 
			(OVF) interrupt every 100 ms. Within the necessary interrupt 
			service routine, an I/O port pin is toggled.
 */ 

 .include "ATxmega128A1Udef.inc"

 ;******************************INITIALIZATIONS***************************************
.equ stack_init = 0x3FFF
.equ Bit0 = 0b00000001
.equ BIT10 = 0b00000011

 ; Start the program (skipping the early addresses)
.org 0
	rjmp MAIN

; Place code at the interrupt vector for PORTD_INT0 interrupt & jump to ISR
.org TCD0_OVF_vect		
	rjmp EXT_INTR_ISR

.ORG 0x0200	
; Write the rest of the program	(MAIN)
MAIN:
	; initialize stack
	ldi YL, low(stack_init)
	out CPU_SPL, YL
	ldi YL, high(stack_init)
	out CPU_SPH, YL

	; call subroutine to initialize our interrupt
	rcall INIT_INTERRUPT
		; set prescaler to 1024 and start timer/counter
	ldi r16, 0x07
	sts TCD0_CTRLA, r16

	; output black
	ldi r16, 0xFF
	sts PORTC_OUT, r16

	; set portdpin0 as output
	ldi r16, BIT0
	sts PORTC_DIRSET, r16

DONE:
	; loop forever while our interrupt fires
	rjmp DONE

/************************************************************************************
* Name:     INIT_INTERRUPT
* Purpose:  Subroutine to initialize the TCD0 as interrupt using INT0
* Inputs:   None			 
* Outputs:  None
* Affected: r16, PMIC_CTRL, TCD0: _INTCTRLA, CTRLB, _PER, _CTRLA
 ***********************************************************************************/
 INIT_INTERRUPT:
	; select TCD0 as the interrupt source
	; overflow interrupt enable
	ldi r16, BIT0
	sts TCD0_INTCTRLA, r16

	; set to normal wave generation mode
	ldi r16, 0x00
	sts TCD0_CTRLB, r16
	; set period to 196 => 100ms
	ldi r16, 196
	sts TCD0_PER, r16
	ldi r16, 0x00
	sts TCD0_PER+1, r16

	;turn on low level interrupts
	ldi r16, BIT0
	sts PMIC_CTRL, r16

	; turn on the global interrupt flag LAST!
	sei 
	ret
	
/************************************************************************************
* Name:     EXT_INTR_ISR
* Purpose:  Interrupt service routine to deal with the PortD external 
*           pin interrupt PD0.  Do NOT need to clear the interrupt flag,
*           but "it can't hurt!". Also, toggles I/O pin.
* Inputs:   None
* Outputs:  None
* Affected: PORTD_INTFLAGS
 ***********************************************************************************/
EXT_INTR_ISR:
	;	"push CPU_SREG"	;not needed since won't change from below
	push r17
	; Clear the TCD0_INTFLAGS
	ldi	 r17, Bit0
	sts  TCD0_INTFLAGS, r17
	; toggle i/o pin
	sts PORTC_OUTTGL, r17
	pop  r17
	;return from the interrupt routine
	reti
