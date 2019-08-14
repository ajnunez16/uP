/*
lab 5, 7. USART, INTERRUPT-BASED RECEIVING
Name: Alexander Nunez
Class #: 11697
PI Name: Chris Crary
Description:   This program configures interrupt-based receiving within the USART system 
; by creating an interrupt-driven echo program for the appropriate USART module.
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

 .org USARTD0_RXC_vect
	rjmp ECHO_ISR

 MAIN:
 	; call subroutine to initialize usart module
	rcall INIT_USART
	; call subroutine to init interrupt
	rcall INIT_INTERRUPT
	; init green led pwn
	ldi R17, 0x20
	sts PORTD_DIRSET, R17

LOOP:
	; toggle green pwm led
	ldi R17, 0x20
	sts PORTD_OUTTGL, R17
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

/************************************************************************************
* Name:     INIT_INTERRUPT
* Purpose:  Subroutine to initialize USARTD0 RXC as interruptsource
* Inputs:   None			 
* Outputs:  None
* Affected: r16, PMIC_CTRL, PORTF: _INT0MASK_OUT, _DIRCLR, _INTCTRL, _PIN2CTRL
 ***********************************************************************************/
 INIT_INTERRUPT:
	; select RXC as interrupt soucre
	ldi R16, 0x10
	sts USARTD0_CTRLA, R16
	 ;turn on low level interrupts
	ldi r16, 0x01
	sts PMIC_CTRL, r16
	;	Also effected pins 7-1

	; turn on the global interrupt flag LAST!
	sei 
	ret

/************************************************************************************
* Name:     ECHO_ISR
* Purpose:  Interrupt service routine to deal with the USARTD0 RXC flag.
*			 Do NOT need to clear the interrupt flag, but "it can't hurt!". Also, outputs data.
* Inputs:   Received Data
* Outputs:  Data to be Transmitted.
* Affected: R16
 ***********************************************************************************/
ECHO_ISR:
	; need to preserve status register
	lds R16, USARTD0_DATA		;read the character into R16
	rcall OUT_CHAR	; echo character input
	reti