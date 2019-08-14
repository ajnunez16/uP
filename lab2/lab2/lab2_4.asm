/*
lab 2, 4. LED ANIMATION CREATOR
Name: Alexander Nunez
Class #: 11697
PI Name: Chris Crary
Description: This program employs timers to display various led sequences that were indicated by the switches. Software delays were used for switch debouncing.
*/

.include "ATxmega128A1Udef.inc"

; Start the program (skipping the early addresses)
.org 0
	rjmp MAIN

; Define space for the table in DATA memory
.DSEG
.org $2000
Table: .BYTE 0x1FFF

; program memory
.cseg
.ORG 0x0200	
; Write the rest of the program	(MAIN)
MAIN:
	; init porte as input
	ldi r16, 0x02
	sts PORTE_DIRCLR, r16
	; init portf as input
	ldi r16, 0x0C
	sts PORTF_DIRCLR, r16
	;init porta as input
	ldi r16, 0xFF
	sts PORTA_DIRCLR, r16
	;init portc as output
	sts PORTC_DIRSET, r16
	; Point to a table in Data memory (for the copy)
	ldi YL, low(Table)
	ldi YH, high(Table)

EDIT:
	lds r17, PORTF_IN	; r17 = portf
	sbrs r17, 3	; check if s2 pressed
	rjmp PLAY
	; set r16 = PORTA
	lds r16, PORTA_IN
	;set portc = r16
	sts PORTC_OUT, r16
	;check if ebi-s1 pressed
	lds r17, PORTE_IN
	sbrc r17, 1
	rjmp EDIT	; loop to edit

WAIT:
	; check if ebi-s1 released
	lds r17, PORTE_IN
	sbrs r17, 1
	rjmp WAIT	; keep waiting if not released
	; store in table and increment pointer
	st Y+, r16
	rjmp EDIT	; loop to poll

PLAY:
	; set z to start of table
	ldi ZL, low(Table)
	ldi ZH, high(Table)

UP:
	; load table from data memory
	lpm r18, Z+
	; output data table
	sts PORTC_OUT, r18
	; timer counter to wait til 20Hz
	; 
	lds r17, PORTF_IN	; r17 = portf
	sbrs r17, 2	; check if lsb-s1 pressed
	rjmp EDIT
	; check if z=Y
	cp ZL, YL
	breq CHECK
	; jump to UP if z=y
	rjmp UP

CHECK:
	; check if z=Y
	cp ZH, YH
	breq PLAY	; jump to play if z=y
