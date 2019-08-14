/*
lab 2, 3. INTRODUCTION TO TIMER/COUNTERS
Name: Alexander Nunez
Class #: 11697
PI Name: Chris Crary
Description: This program employs timers and counters to count to 255 slowly.
*/

.include "ATxmega128A1Udef.inc"

; Start the program (skipping the early addresses)
.org 0
	rjmp MAIN

.ORG 0x0100	
; Write the rest of the program	(MAIN)
MAIN:
	; set prescaler to 1024
	ldi r16, 0x07
	sts TCC0_CTRLA, r16
	; set to normal wave generation mode
	ldi r16, 0x00
	sts TCC0_CTRLB, r16
	; set period to 255
	ldi r16, 0xFF
	sts TCC0_PER, r16
	; init output pin
	ldi r16, 0xFF
	sts PORTC_DIRSET, r16
LOOP:
	; output low byte of counter
	lds r16, TCC0_CNT
	sts PORTC_OUT, r16
	; loop back
	rjmp LOOP

