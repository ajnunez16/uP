/*
lab 2, 2. SOFTWARE DELAYS
Name: Alexander Nunez
Class #: 11697
PI Name: Chris Crary
Description: This program employs a series of meaningless instructions as a software delay.
*/

.include "ATxmega128A1Udef.inc"

; Start the program (skipping the early addresses)
.org 0
	rjmp MAIN

.ORG 0x0100	
; Write the rest of the program	(MAIN)
MAIN:
	; init output pin
	ldi r22, 0x01
	sts PORTD_DIRSET, r22

	ldi r20, 20		;toggle output pin at rate of 10Hz
LOOP: 
	rcall DELAY_10MS	; call to subroutine
	sts PORTD_OUTTGL, r22	; toggle output pin
	rjmp LOOP	; jump to loop

.org 0x300	;put this here only to know the address of subroutine
;*********************SUBROUTINES**************************************
; Subroutine Name: DELAY_10MS
; delay 10 ms by counting to 3998
; Inputs: None
; Ouputs: None
; Affected: R16, R17, R18, R19

DELAY_10MS:
	; push to stack
	push r16
	push r17
	push r18
	push r19
	; r16 = 0
	clr r16
	; r17 = 0xFF
	ldi r17, 0xFF
	; r18 = 0
	clr r18
	; r19 = 0x10
	ldi r19, 0x10

UP:
	; check if r16 = r17
	cp r16, r17
	; branch to upper if they’re =
	breq UPPER
	; r16++
	inc r16
	; loop to UP
	rjmp UP


UPPER:
	; r16 = 0
	clr r16
	; r18++
	inc r18
	; check if r18 != r19
	cp r18, r19
	; branch to upper if they’re !=
	brne UP

BACK:
	; pop from stack
	pop r18
	pop r17
	pop r16
	; return
	ret

;*********************SUBROUTINES**************************************
; Subroutine Name: DELAY_X_10MS
; delay 10 ms by counting to 3998
; Inputs: R20
; Ouputs: None
; Affected: R21

DELAY_X_10MS:
	; push to stack
	push r21
	; r21 = 0
	clr r21

UP1:
	; check if r20 = r21
	cp r20, r21
	; branch to back1 if they're =
	breq BACK1
	; call subroutine to delay 10ms
	rcall DELAY_10MS
	; r21++
	inc r21
	; loop to up1
	rjmp UP1

BACK1:
	; pop from stack
	pop r21
	; return
	ret