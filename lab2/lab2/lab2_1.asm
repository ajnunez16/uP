
/*
lab 2, 1. INTRODUCTION TO I/O
Name: Alexander Nunez
Class #: 11697
PI Name: Chris Crary
Description: This program connects switches to leds.
*/

.include "ATxmega128A1Udef.inc"

; Start the program (skipping the early addresses)
.org 0
	rjmp MAIN

.ORG 0x0100	
; Write the rest of the program	(MAIN)
MAIN:
	;init porta as input
	ldi r16, 0xFF
	sts PORTA_DIRCLR, r16
	;init portc as output
	sts PORTC_DIRSET, r16

POLL:
	; set r16 = PORTA
	lds r16, PORTA_IN
	;set portc = r16
	sts PORTC_OUT, r16
	rjmp POLL	; loop to poll