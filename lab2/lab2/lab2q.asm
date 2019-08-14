/*
lab 2, Quiz
Name: Alexander Nunez
Class #: 11697
PI Name: Chris Crary
Description: quiz on timer/counter - stopwatch that keeps track of tenth of seconds
*/

.include "ATxmega128A1Udef.inc"

; Start the program (skipping the early addresses)
.org 0
	rjmp MAIN

.ORG 0x0200	
; Write the rest of the program	(MAIN)
MAIN:
	; init porte as input
	ldi r16, 0x02
	sts PORTE_DIRCLR, r16
	; init portf as input
	ldi r16, 0x0C
	sts PORTE_DIRCLR, r16
	;init portc as output
	ldi r16, 0xFF
	sts PORTC_DIRSET, r16
	; set prescaler to 1024
	ldi r16, 0x07
	sts TCC0_CTRLA, r16
	; set to normal wave generation mode
	ldi r16, 0x00
	sts TCC0_CTRLB, r16
	; set period to 196
	ldi r16, 0xC4
	sts TCC0_PER, r16
	ldi r16, 0x00
	sts TCC0_PER+1, r16

RESET:
	; reset cnt
	ldi r16, 0xFF
	sts PORTC_OUT, r16	; output zero
	sts TCC0_CNT, r16	; set cnt to zero

STOP:
	sts PORTC_OUT, r16
	lds r17, PORTE_IN	; r17 = porte
	sbrs r17, 1		; check if ebi s1 pressed
	rjmp RESET
	lds r17, PORTF_IN	; r17 = portf
	sbrc r17, 2	; check if lsb-s1 pressed
	rjmp STOP	; loop

START:
	sts TCC0_CNT, r16
UP:
	lds r16, TCC0_CNT
	sts PORTC_OUT, r16
	lds r17, PORTE_IN	; r17 = porte
	sbrs r17, 1
	rjmp RESET
	lds r17, PORTF_IN	; r17 = portf
	sbrs r17, 3	; s2
	rjmp STOP
	rjmp UP
