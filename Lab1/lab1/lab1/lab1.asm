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
 
Table:	.db 0116, 146,'t',0b00101100, 'H', 0146, 0x37, 63, 0x2C, 'x', 0b11101010, 92, 076, 0x00

.dseg	;switch to data memory

.org 0x3F00
Outs:	.BYTE 28

.cseg
.org 0x200

MAIN:
	ldi ZL, byte3(Table << 1)		;load the highest byte of the Table address into ZL register
	out CPU_RAMPZ, ZL
	ldi ZH, byte2(Table << 1)	;load the high byte of the Table address into ZH register
	ldi ZL, byte1(Table << 1)		;load the low byte of the Table address into ZL register

	ldi YL, low(Outs)	;not necessary ## low = byte1
	ldi YH, high(Outs)	;not necessary ## high = byte2 (also is a byte3)

LOOP:
	clr r17		; r17=0
	elpm r16, Z+		; load the value from the table (using Z as pointer) into r16
	add r17, r16		; check if value is eot
	breq DONE		; if eot branch to done
	andi r17, BIT1	; and with 2
	cpi r17, BIT1	; check if bit1 is set
	brne LT
	lsr r16		; divide by 2
	ldi r17, res	; r0 = 48
	cp r16, r17	;	compare r16 and r0
	brge COPY	; r16 >= r0 then copy to ram table

LT:
	ldi r17, ltby	; r0=0x60
	cp r16, r17		; compare r16 and r17
	brge UP		; r17>= r16
	subi r16, 0xC	; r16-12
	
COPY:
	st Y+, r16		; store r16 in table

UP:
	rjmp LOOP	; branch back to loop

DONE:
	rjmp DONE