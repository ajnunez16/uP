/*
lab 5, 4. USART, STRING TRANSMISSION
Name: Alexander Nunez
Class #: 11697
PI Name: Chris Crary
Description:   This program outputs a character string of arbitrary length. 
 */ 

  .include "ATxmega128A1Udef.inc"

 ;******************************INITIALIZATIONS***************************************
; Equate statements so we can easily change the BSel and BScale 
;    this will make it very easy to change the baud rate of the USART
;	 current configuration is a baud rate of 57600 Hz
.EQU BSel = 75
.EQU BScale = -6	; 57600 Hz

 .org 0x0000
 rjmp MAIN

 ; define complete name in program memory
 .org 0x100
 NAME: .db "Alexander Jorge Nunez"

 ; MAIN routine
 .org 0x200
 MAIN:
	; call subroutine to initialize usart module
	rcall INIT_USART
	; point to program memory with z pointer
	ldi ZL, low(NAME << 1)
	ldi ZH, high(NAME << 1)
	; call subroutine to output complete name stored in program memory
	rcall OUT_STRING
DONE:
	rjmp DONE	; loop forever

; *********************************************
; INIT_USART initializes UART 0 on PortD (PortD0) and PortD Pin3 for output (PortD0 TX pin)
; SUBROUTINE:   INIT_USART
; FUNCTION:     Initializes the USARTDO's TX, 57600 BAUD, even parity, 8 data bits, 1 start bit, 1 stop bit. 
;				Must set PortD_PIN3 as output for TX pin of USARTD0 and initial output value to 1.
; INPUT:        None
; OUTPUT:       None
; DESTROYS:     R16
; REGS USED:	USARTD0_CTRLB, USARTD0_CTRLC, USARTD0_BAUDCTRLA,
;               USARTD0_BAUDCTRLB, PortD_DIR, PortD_OUT
; CALLS:        None.

INIT_USART:
	; Set the data direction of the appropriate USART transmit pin. 
	ldi R16, 0x08	
	sts PortD_OUTSET, R16	;set the TX line to default to '1' as described in the documentation
	sts PortD_DIRSET, R16	;Must set PortD_PIN3 as output for TX pin of USARTD0
	; Configure the USART module for the appropriate mode (synchronous, asynchronous, etc.), 
	; as well as configure the necessary amount of data bits, type of parity, and number of stop bits.
	ldi R16, 0x08			
	sts USARTD0_CTRLB, R16		;turn on TXEN
	ldi R16, 0x23
	sts USARTD0_CTRLC, R16		;Set even Parity, 8 bit frame, 1 stop bit
	;  Set the baud rate by storing the appropriate value in the baud rate registers
	ldi R16, (BSel & 0xFF)		;select only the lower 8 bits of BSel
	sts USARTD0_BAUDCTRLA, R16	;set baudctrla to lower 8 bites of BSel 

	ldi R16, ((BScale << 4) & 0xF0) | ((BSel >> 8) & 0x0F)							
	sts USARTD0_BAUDCTRLB, R16	;set baudctrlb to BScale | BSel. Lower 
								;  4 bits are upper 4 bits of BSel 
								;  and upper 4 bits are the BScale. 
	ret

; *********************************************
; OUT_CHAR receives a character via R16 and will
;   poll the DREIF (Data register empty flag) until it true,
;   when the character will then be sent to the USART data register.
; SUBROUTINE:   OUT_CHAR
; FUNCTION:     Outputs the character in register R16 to the SCI Tx pin 
;               after checking if the DREIF (Data register empty flag)   
;     			is empty.  The PC terminal program will take this 
;               received data and  put it on the computer screen.
; INPUT:        Data to be transmitted is in register R16.
; OUTPUT:       Transmit the data.
; DESTROYS:     None.
; REGS USED:	USARTD0_STATUS, USARTD0_DATA
; CALLS:        None.

OUT_CHAR:
	push R17

TX_POLL:
	lds R17, USARTD0_STATUS		;load status register
	sbrs R17, 5					;proceed to writing out the char if
								;  the DREIF flag is set
	rjmp TX_POLL				;else go back to polling
	sts USARTD0_DATA, R16		;send the character out over the USART
	pop R17

	ret

; *********************************************
; SUBROUTINE:   OUT_STRING
; FUNCTION:    output a character string stored in program memory, 
; using the appropriate USART module.
; INPUT:        Data to be transmitted is in program memory .
; OUTPUT:       Transmit the data.
; DESTROYS:     None.
; REGS USED:	USARTD0_STATUS, USARTD0_DATA
; CALLS:        OUT_CHAR

OUT_STRING:
	; Read the character pointed to by Z and increment the pointer.
	lpm R16, Z+
	; check if non-null character 
	cpi r16, 0xff
	BREQ EXIT	; exit subroutine if null
	rcall OUT_CHAR	; call the subroutine OUT_CHAR
	rjmp OUT_STRING	; loop to check next char
EXIT:
	; when a null character is found, return from the subroutine
	ret