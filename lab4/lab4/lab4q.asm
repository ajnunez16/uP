/*
lab4, 2. INTERRUPTS, CONTINUED
Name: Alexander Nunez
Class #: 11697
PI Name: Chris Crary
Description:  This program triggers an interrupt whenever tactile switch S1 is pressed. 
			Within the necessary ISR for the interrupt, increment a global counter and
			then display the updated count value in binary notation with illuminated 
			LEDs. Additionally, within the main routine of the relevant program, after 
			configuring the necessary interrupt, continuously toggle on/off the blue 
			LED as quickly as possible to be able to easily highlight the fact that 
			the separate, assigned tasks can appear to occur at the same time.
 */ 

 .include "ATxmega128A1Udef.inc"

 ;******************************INITIALIZATIONS***************************************
.equ stack_init = 0x3FFF
.equ BIT0 = 0b00000001
.equ BIT2 = 0b00000100
.equ BIT10 = 0b00000011

 ; Start the program (skipping the early addresses)
.org 0
	rjmp MAIN

; Place code at the interrupt vector for PORTD_INT0 interrupt & jump to ISR
.org PORTF_INT0_vect		
	rjmp EXT_INTR_ISR

.ORG 0x0200	
; Write the rest of the program	(MAIN)
MAIN:
	; initialize stack
	ldi YL, low(stack_init)
	out CPU_SPL, YL
	ldi YL, high(stack_init)
	out CPU_SPH, YL
	; init leds as output - portc
	ldi r16, 0xFF
	sts PORTC_OUT, r16
	ldi r16, 0x01
	sts PORTC_DIRSET, r16
	; init rgb led as output - portd
	ldi r17, 0x50
	sts PORTD_OUT, r16
	ldi r16, 0x70
	sts PORTD_DIRSET, r16
	; set to normal wave generation mode
	ldi r16, 0x00
	sts TCD0_CTRLB, r16
	; set period to 196 => 100ms
	ldi r16, 196
	sts TCD0_PER, r16
	ldi r16, 0x00
	sts TCD0_PER+1, r16
	; set prescaler to 1024 and start timer/counter
	ldi r16, 0x07
	sts TCD0_CTRLA, r16
	; call subroutine to initialize our interrupt
	rcall INIT_INTERRUPT
	; set portdpin0 as output
	ldi r16, BIT0
	sts PORTC_DIRSET, r16

DONE:
	lds r16, TCD0_CNT
	cp r16
	rjmp DONE
	ldi r16, BIT0
	sts PORTC_DIRSET, r16
	sts PORTD_OUTTGL, r17
	; loop forever while our interrupt fires
	rjmp DONE

/************************************************************************************
* Name:     INIT_INTERRUPT
* Purpose:  Subroutine to initialize the PortF external pin interrupt PF2 using INT0
* Inputs:   None			 
* Outputs:  None
* Affected: r16, PMIC_CTRL, PORTF: _INT0MASK_OUT, _DIRCLR, _INTCTRL, _PIN2CTRL
 ***********************************************************************************/
 INIT_INTERRUPT:
	; select PORTF_PIN2 as the interrupt source
	ldi r16, BIT2
	sts PORTF_INT0MASK, r16
	; init tactile switch s1 as input - portf
	ldi r16, BIT2
	sts PORTF_DIRCLR, r16
	; select the external interrupt as a low level 
	ldi r16, BIT0
	sts PORTF_INTCTRL, r16	;  priority interrupt 
		;	Probably inappropriately cleared the INT1 interrupt level pins 

	; select low level pin for external interrupt 
	ldi r16, BIT0
	;  (not rising edge, falling edge, or any edge)
	sts PORTF_PIN2CTRL, r16
		;	Probably inappropriately cleared pins 7, 5, 4, 3

	;turn on low level interrupts
	ldi r16, BIT0
	sts PMIC_CTRL, r16
	;	Also effected pins 7-1

	; turn on the global interrupt flag LAST!
	sei 
	ret
	
/************************************************************************************
* Name:     EXT_INTR_ISR
* Purpose:  Interrupt service routine to deal with the PortF external 
*           pin interrupt PF2.  Do NOT need to clear the interrupt flag,
*           but "it can't hurt!". Increments global counter
* Inputs:   r17
* Outputs:  r17
* Affected: PORTD_INTFLAGS, global counter
 ***********************************************************************************/
EXT_INTR_ISR:
	;	"push CPU_SREG"	;not needed since won't change from below
	push r18
	; Clear the PORTF_INTFLAGS
	ldi r18, BIT0
	sts PORTF_INTFLAGS, r18
	sbrc r17, 6
	rjmp OTHER
	ldi r17, 0x30
	rjmp FIN
OTHER:
	ldi r17, 0x50
FIN:
	pop r18
	;return from the interrupt routine
	reti