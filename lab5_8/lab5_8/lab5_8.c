/*
lab 5, 8. MEMORY GUI 
Name: Alexander Nunez
Class #: 11697
PI Name: Chris Crary
Description:   This program implements a graphical user interface (GUI) to allow some data memory 
locations within the ATxmega128A1U to be viewed and edited via a serial terminal program.
 */ 

#include "usart.h"
#include "ebi_driver.h"
#include "string.h"

/*****************************************************************************
* Name: usartd0_init
* Purpose: To configure the USARTD0 module for a specific asynchronous
*          serial protocol, and to enable the corresponding receiver and
*          transmitter.
* Input(s): N/A
* Output: N/A
******************************************************************************/
void usartd0_init(void)
{
  /* configure relevant TxD and RxD pins */
	PORTD.OUTSET = PIN3_bm;
	PORTD.DIRSET = PIN3_bm;
	PORTD.DIRCLR = PIN2_bm;

  /* configure baud rate */
	/* At 2 MHz SYSclk, 5 BSEL, -6 BSCALE corresponds to 57600 bps */
	USARTD0.BAUDCTRLA = (uint8_t)75;
	USARTD0.BAUDCTRLB = (uint8_t)( (-6 << 4) | (75 >> 8) );

  /* configure remainder of serial protocol */
  /* in this example, a protocol with 8 data bits, even parity, and
   * one stop bit is chosen. */
	USARTD0.CTRLC = USART_CMODE_ASYNCHRONOUS_gc |
					        USART_PMODE_EVEN_gc		  |
					        USART_CHSIZE_8BIT_gc        &
                  ~USART_SBMODE_bm;

  /* enable receiver and/or transmitter systems */
	USARTD0.CTRLB = USART_RXEN_bm | USART_TXEN_bm;

  /* enable interrupt (optional) */
	/* USARTD0.CTRLA = USART_RXCINTLVL_MED_gc; */
}

/*****************************************************************************
* Name: usartd0_out_char
* Purpose: To output a character from the transmitter within USARTD0.
* Input(s): c (char)
* Output: N/A
******************************************************************************/
void usartd0_out_char(char c)
{
	while(!(USARTD0.STATUS & USART_DREIF_bm));
	USARTD0.DATA = c;
}

/*****************************************************************************
* Name: usartd0_out_string
* Purpose: To output a C string from the transmitter within USARTD0.
* Input(s): str (char *)
* Output: N/A
******************************************************************************/
void usartd0_out_string(char * str)
{
	while(*str) usartd0_out_char(*(str++));
}

/*****************************************************************************
* Name: usartd0_in_char
* Purpose: To read in a character from the receiver within USARTD0.
* Input(s): N/A
* Output: (char)
******************************************************************************/
char usartd0_in_char(void)
{
  while(!(USARTD0.STATUS & USART_RXCIF_bm));
  return USARTD0.DATA;
}

/*****************************************************************************
* Name: usartd0_in_string
* Purpose: To read in a string from the receiver within USARTD0. The string
*          is to be stored within a pre-allocated buffer (buf).
* Input(s): buf (char *)
* Output: N/A
******************************************************************************/
void usartd0_in_string(char * buf)
{
  // read chars
  for(int i = 0; i < strlen(buf); i++){
	  // store char returned by in char in char array buf
	  buf[i] = usartd0_in_char();
  }
}

int main( void ){
		// init usart
	usartd0_init();
	// output intro prompt
	usartd0_out_string("Welcome to the Memory GUI! This program allows a user to view as well as edit any data memory location within the connected ATxmega128A1U.");
	// loop forever
	while(1){
		usartd0_out_string("To read from a memory location, type 'R'. To write to a memory location, type 'W'. (R/W): ");
		volatile char c;
		// loop until R or W is entered
		while(c != 'R' && c != 'W'){
			c = usartd0_in_char();	// get input char
			usartd0_out_char(c);	// allow user to see input
		}
		usartd0_out_string("Address: 0x");
		volatile char addr[4];
		// loop until addr is within range
		while(!(addr[0] == '0' && addr[0] == '1'&& addr[0] == '2'&& addr[0] == '3')){
			usartd0_in_string(addr);	// get string input and store in addr
			usartd0_out_string(addr); // allow user to see input
		}
		// if read selected
		if(c == 'R') {
			// read from memory location
			__far_mem_read(addr);
		}	// if write selected
		else if (c== 'W') {
			usartd0_out_string("Data: 0x");
			volatile char data[2];
			usartd0_in_string(data); // read in data string
			usartd0_out_string(data);	// allow user to see input
			// write to memory location
			__far_mem_write(addr, data);
		}
	}
	return 0;
}