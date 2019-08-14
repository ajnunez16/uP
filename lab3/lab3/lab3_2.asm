/*
lab 3, 2. INTERFACING WITH EXTERNAL I/O PORTS
Name: Alexander Nunez
Class #: 11697
PI Name: Chris Crary
Description: This program employs ebi to connect to an external switch and led.
*/

.include "ATxmega128A1Udef.inc"

;******************************INITIALIZATIONS***************************************
.set IN_PORT = 0x19000		
.set IN_PORT_END = 0x1903F
.set OUT_PORT = 0x19000		
.set OUT_PORT_END = 0x1903F	

; Start the program (skipping the early addresses)
.org 0
	rjmp MAIN

.ORG 0x0100	
; Write the rest of the program	(MAIN)
MAIN:
	; Initialize WE(L), RE(L) and CS1(L) by giving them default values (H) 
	; bits 0, 1,and 4 respectively
	ldi r16, 0b10011		
	sts PORTH_OUTSET, r16
	; Initialize DIR for PORTH outputs CS1(L), ALE1(H), RE(L), and WE(L)
	ldi r16, 0b10111
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
	; Initialize middle byte (A15:8) of BASEADDR for CS1, EBI_CS1_BASEADDR
	ldi r16, byte2(IN_PORT)
	sts EBI_CS1_BASEADDR, r16
	; Initialize high byte (A23:A16) of BASEADDR for CS1, EBI_CS1_BASEADDR+1
	ldi r16, byte3(IN_PORT)
	sts EBI_CS1_BASEADDR+1, r16
	; Init EBI_CS1_CTRLA for 256 bytes (supposed to be 64 bits) size (0x1 9000 - 0x1 903F) and turn on SRAM mode
	ldi r16, 0x00			
	sts EBI_CS1_CTRLA, r16
	; Point to the IN_PORT with X
	ldi r16, byte3(IN_PORT)
	sts CPU_RAMPX, r16
	ldi XH, high(IN_PORT)
	ldi XL, low(IN_PORT)
	; Point to the OUT_PORT with Y
	ldi r16, byte3(OUT_PORT)
	sts CPU_RAMPX, r16
	ldi YH, high(OUT_PORT)
	ldi YL, low(OUT_PORT)
; Continuously read the Input port (but do nothing with it)
TEST:
	; read the input port into r16
	ld r16, X
	; store r16 to the output port
	st Y, r16
	rjmp TEST; continuously loop

