/*
lab 5, 5. USART, CHARACTER INPUT
Name: Alexander Nunez
Class #: 11697
PI Name: Chris Crary
Description:   This program configure the appropriate USART module to receive serial data from your computer
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
 MAIN:
 	; call subroutine to initialize usart module
	rcall INIT_USART
; continually echo (i.e., re-transmit) any character received by your microcontroller back to your computer
LOOP:
	rcall IN_CHAR
	rcall OUT_CHAR
	rjmp LOOP	; loop forever

; *********************************************
; INIT_USART initializes UART 0 on PortD (PortD0) and PortD Pin3 for output (PortD0 TX pin)
; SUBROUTINE:   INIT_USART
; FUNCTION:     Initializes the USARTDO's TX, 57600 (115200) BAUD, even parity, 8 data bits, 1 start bit, 1 stop bit. 
;				Must set PortD_PIN3 as output for TX pin of USARTD0 and initial output value to 1.
; INPUT:        None
; OUTPUT:       None
; DESTROYS:     R16
; REGS USED:	USARTD0_CTRLB, USARTD0_CTRLC, USARTD0_BAUDCTRLA,
;               USARTD0_BAUDCTRLB, PortD_DIR, PortD_OUT
; CALLS:        None.

INIT_USART:
	; Set the data direction of the appropriate USART transmit and receive pins. 
	ldi R16, 0x08	
	sts PortD_OUTSET, R16	;set the TX line to default to '1' as described in the documentation
	sts PortD_DIRSET, R16	;Must set PortD_PIN3 as output for TX pin of USARTD0
	ldi R16, 0x04
	sts PORTD_DIRCLR, R16	; set PortD_PIN2 as input for RX pin of USARTD0
	; Configure the USART module for the appropriate mode (synchronous, asynchronous, etc.), 
	; as well as configure the necessary amount of data bits, type of parity, and number of stop bits.
	ldi R16, 0x18				
	sts USARTD0_CTRLB, R16		;turn on TXEN and RXEN
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

; *********************************************
; IN_CHAR receives a character via R16 and will
;   poll the DREIF (Data register empty flag) until it true,
;   when the character will then be sent to the USART data register.
; SUBROUTINE:   IN_CHAR
; FUNCTION:     receive a single character with the relevant USART module 
;				and return the received character to the calling procedure 
;				via a specified general-purpose register 
; INPUT:        Receive the data.
; OUTPUT:       Received data is in register R16. 
; DESTROYS:     None.
; REGS USED:	USARTD0_STATUS, USARTD0_DATA
; CALLS:        None.

IN_CHAR:
	; Check if a character has been received (by polling an appropriate interrupt flag), 
	; and if not, keep checking until one has been received. 
	lds R16, USARTD0_STATUS		;load the status register
	sbrs R16, 7					;proceed to reading in a char if the receive flag is set
	; Read the received character from the appropriate buffer 
	rjmp IN_CHAR				;else continue polling
	lds R16, USARTD0_DATA		;read the character into R16
	; return the character to the calling procedure. 
	ret