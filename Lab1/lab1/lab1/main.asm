;
; lab1.asm
;
; Created: 5/28/2019 10:08:27 AM
; Author : Alexander Nunez
;
; Description: This program will load data from a table in program memory, filter the data, and place the reult in data memory.

.include "ATxmega128A1Udef.inc"

.equ NULL = 0	; set End of Table value
.equ BIT1 = 0b00000010
.equ res = 48
.equ ltby = 0x60

.org 0x0000				;Place code at address 0x0000
	rjmp MAIN			;Relative jump to start of program

.org 0xF1F0							;Place table at address 0xF1F0.  
Table:	.db 	0116, "N"	;Define the table in bytes
		.db		146, "'"
		.db		't', "t"
		.db		0b00101100, ","
		.db		'H', "H"
		.db		0146, "f"
		.db		0x37, "7"
		.db		63,	"?"
		.db		0x2C, ","
		.db		'x', "x"
		.db		0b11101010, "ê"
		.db		92, "\"
		.db		076, ">"
		.db		0x00, NULL

.dseg	;switch to data memory

.org 0x3F00
Outs:	.BYTE 4

.cseg
.org 0x200

MAIN:
	ldi ZL, low(Table << 1)		;load the low byte of the Table address into ZL register
	ldi ZH, high(Table << 1)	;load the high byte of the Table address into ZH register

	clr r17

	ldi YL, low(Outs)	;not necessary ## low = byte1
	ldi YH, high(Outs)	;not necessary ## high = byte2 (also is a byte3)

LOOP:
	lpm r16, Z+		; load the value from the table (using Z as pointer) into r16
	add r17, r16		; check if value is eot
	breq DONE		; if eot branch to done
	andi r17, BIT1	; check if bit1 is set
	breq LT
	lsr r16		; divide by 2
	ldi r17, res	; r0 = 48
	cp r16, r17	;	compare r16 and r0
	brge COPY	; r16 >= r0 then copy to ram table

LT:
	ldi r17, ltby	; r0=0x60
	cp r17, r16		; compare r16 and r0
	brge LOOP		; r0>= r16
	subi r16, 12	; r16-12
	
COPY:
	st Y+, r16		; store r16 in table
	rjmp LOOP		; branch back to loop

DONE:
	rjmp DONE