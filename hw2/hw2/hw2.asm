/*
hw 2
Name: Alexander Nunez
Class #: 11697
PI Name: Chris Crary
Description: This program uses dip switches to determine the duty
cycle of pulse-width modulation and tactile switches to determine
the color of the led that is output.
*/

.include "ATxmega128A1Udef.inc"

.equ R = 0b11101111
.equ G = 0b11011111
.equ B = 0b10111111

; Start the program (skipping the early addresses)
.org 0
	rjmp MAIN

.ORG 0x0100	
; Write the rest of the program	(MAIN)
MAIN:
	; init dip switch as input
	ldi r16, 0xFF
	sts PORTA_DIRCLR, r16
	; init rgb led as output
	ldi r16, 0x70
	sts PORTD_DIRSET, r16
	; init led s1 and s2 as input
	ldi r16, 0x0C
	sts PORTF_DIRCLR, r16
	; init ebi s1 as input
	ldi r16, 0x02
	sts PORTE_DIRCLR, r16
	; init timer/counter pwm and cca
	ldi r16, 0x13
	sts TCD0_CTRLB, r16
	;init timer/counter period
	ldi r16, 0xFF
	sts TCD0_PER, r16
	sts TCD0_PER+1, r16

WAIT:
	; output BLACK
	ldi r16, 0xFF
	sts PORTD_OUT, r16
	; if led s1 branch to red
	lds r16, PORTF_IN
	sbrs r16, 2
	rjmp RED
	; if led s2 branch to blue
	lds r16, PORTF_IN
	sbrs r16, 3
	rjmp BLUE
	; if ebi s1 branch to green
	lds r16, PORTE_IN
	sbrs r16, 1
	rjmp GREEN
	; loop until tactile switch is pressed
	rjmp WAIT

RED:
	; calculate duty cycle
	lds r17, PORTA_IN
	sts TCD0_CCA, r17
	; start timer/counter
	ldi r16, 0x07
	sts TCD0_CTRLA, r16
RED_ON:
	; check if count = duty cycle
	lds r18, TCD0_CNT
	cp r17, r18
	breq RED_OFF
	; output red led PWM
	ldi r16, R
	sts PORTD_OUT, r16
	; if led s2 branch to blue
	lds r16, PORTF_IN
	sbrs r16, 3
	rjmp BLUE
	; if ebi s1 branch to green
	lds r16, PORTE_IN
	sbrs r16, 1
	rjmp GREEN
	; loop red
	rjmp RED_ON
RED_OFF:
	; check if count restarted
	lds r18, TCD0_CNT
	cpi r18, 0x00
	breq RED_ON
	; output black
	ldi r16, 0xFF
	sts PORTD_OUT, r16
	; loop
	rjmp RED_OFF

BLUE:
	; calculate duty cycle
	lds r17, PORTA_IN
	sts TCD0_CCA, r17
	; start timer/counter
	ldi r16, 0x07
	sts TCD0_CTRLA, r16
BLUE_ON:
	; check if count = duty cycle
	lds r18, TCD0_CNT
	cp r17, r18
	breq BLUE_OFF
	; output blue led PWM
	ldi r16, B
	sts PORTD_OUT, r16
	; if led s1 branch to red
	lds r20, PORTF_IN
	sbrs r20, 2
	rjmp RED
	; if ebi s1 branch to green
	lds r20, PORTE_IN
	sbrs r20, 1
	rjmp GREEN
	; loop blue
	rjmp BLUE_ON
BLUE_OFF:
	; check if count restarted
	lds r18, TCD0_CNT
	cpi r18, 0x00
	breq BLUE_ON
	; output black
	ldi r16, 0xFF
	sts PORTD_OUT, r16
	; loop
	rjmp BLUE_OFF

GREEN:
	; calculate duty cycle
	lds r17, PORTA_IN
	sts TCD0_CCA, r17
	; start timer/counter
	ldi r16, 0x07
	sts TCD0_CTRLA, r16

GREEN_ON:
	; check if count = duty cycle
	lds r18, TCD0_CNT
	cp r17, r18
	breq GREEN_OFF
	; output green led PWM
	ldi r16, G
	sts PORTD_OUT, r16
	; if led s1 branch to red
	lds r20, PORTF_IN
	sbrs r20, 2
	rjmp RED
	; if led s2 branch to blue
	lds r20, PORTF_IN
	sbrs r20, 3
	rjmp BLUE
	; loop green
	rjmp GREEN_ON
GREEN_OFF:
	; check if count restarted
	lds r18, TCD0_CNT
	cpi r18, 0x00
	breq GREEN_ON
	; output black
	ldi r16, 0xFF
	sts PORTD_OUT, r16
	; loop
	rjmp GREEN_OFF