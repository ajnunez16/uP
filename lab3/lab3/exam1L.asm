/*
 * exam1L.asm
 *
 *  Created: 6/20/2019 10:09:15 AM
 *   Author: Aj
 */ 

 .include "ATxmega128A1Udef.inc"

;******************************INITIALIZATIONS***************************************
.set OUT_PORT = 0x4000		
.set OUT_PORT_END = 0x47FF
	

; Start the program (skipping the early addresses)
.org 0x0000
	rjmp MAIN

.org 0x0200
MAIN:
; Initialize  RE(L) and CS0(L) by giving them default values (H) 
	; bits 0, 1, 3, and 4 respectively
	ldi r16, 0b01010		
	sts PORTH_OUTSET, r16
	; Initialize DIR for PORTH outputs CS0(L), ALE1(H), and RE(L)
	ldi r16, 0b10101
	sts PORTH_DIRSET, r16
	; Initialize PORTK pins for outputs (A15-A0)
	ldi r16, 0xFF
	sts PORTK_DIRSET, r16
	; Initialize PORTJ pins for outputs (D7-D0), because the manual says so!
	ldi r16, 0xFF
	sts PORTJ_DIRSET, r16
	; Initialize the SRAM ALE1 3-port mode in EBI_CTRL
	ldi r16, 0x01
	sts EBI_CTRL, r16
	; Initialize middle byte (A15:8) of BASEADDR for CS0, EBI_CS0_BASEADDR
	ldi r16, byte2(OUT_PORT)
	sts EBI_CS0_BASEADDR, r16
	; Initialize high byte (A23:A16) of BASEADDR for CS0, EBI_CS0_BASEADDR+1
	ldi r16, byte3(OUT_PORT)
	sts EBI_CS0_BASEADDR+1, r16
	; Init EBI_CS0_CTRLA for 2K size (0x4000 - 0x47FF) and turn on SRAM mode
	ldi r16, 0x03			
	sts EBI_CS0_CTRLA, r16
	; Point to bad OUT_PORT with Y
	ldi r16, byte3(0x4037)
	sts CPU_RAMPY, r16
	ldi YH, high(0x4037)
	ldi YL, low(0x4037)
	; Point to the OUT_PORT with X
	ldi r16, byte3(0x4744)
	sts CPU_RAMPX, r16
	ldi XH, high(0x4744)
	ldi XL, low(0x4744)
	;init porta as input
	ldi r16, 0xFF
	sts PORTA_DIRCLR, r16
	;init portc as output for debugging
	sts PORTC_DIRSET, r16
DONE:
	; set r16 = PORTA
	lds r16, PORTA_IN
	;set portc = r16 for debugging
	sts PORTC_OUT, r16
	; store r16 to bad out_port
	st Y, r16
	; store r16 to the output port
	st X, r16
	rjmp DONE