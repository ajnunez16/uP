/*
lab 6, 5. PLOTTING REAL-TIME ACCELEROMETER DATA 
Name: Alexander Nunez
Class #: 11697
PI Name: Chris Crary
Description:   This program will plot accelerometer data for each of the coordinate planes (X, Y, and Z) in real-time, using SerialPlot.
*/

#include <avr/io.h>
#include "lsm330.h"
#include "lsm330_registers.h"
#include "usart.h"
#include "ebi_driver.h"
#include <avr/interrupt.h>

#define BIT7 0x80
#define BIT0 0x01

volatile int accel_flag = 0;

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

// init external interrupt
void init_interrupt( void ) {
	// pc7 is interrupt source
	PORTC_INT0MASK = BIT7;
	// set pc7 as input
	PORTC_DIRCLR = BIT7;
	// select ext interrupt as low level
	PORTC_INTCTRL = BIT0;
	// select rising edge for external interrupt 
	PORTC_PIN7CTRL = BIT0;
	// turn on low level interrupts
	PMIC_CTRL = BIT0;
	// sei;
}

// ISR asserts global flag
ISR(PORTC_INT0_vect){
	accel_flag = 1;
}

int main(void) {
	// init usart
	usartd0_init();
	// init external interrupt via pc7
	init_interrupt();
	// accel init
	accel_init();
	
	lsm330_data_t lsm_data;
	
	while(1){
			// calls out_char when global flag asserted
			if(accel_flag){
				// read output x-axis low reg
				lsm_data.byte.accel_x_low = accel_read(OUT_X_L_A);
				usartd0_out_char((char) lsm_data.byte.accel_x_low);
				// read output x-axis high reg
				lsm_data.byte.accel_x_high = accel_read(OUT_X_H_A);
				usartd0_out_char((char) lsm_data.byte.accel_x_high);
				// read output y-axis low reg
				lsm_data.byte.accel_y_low = accel_read(OUT_Y_L_A);
				usartd0_out_char((char)lsm_data.byte. accel_y_low);
				// read output y-axis high reg
				lsm_data.byte.accel_y_high = accel_read(OUT_Y_H_A);
				usartd0_out_char((char)lsm_data.byte. accel_y_high);
				// read output z-axis low reg
				lsm_data.byte.accel_z_low = accel_read(OUT_Z_L_A);
				usartd0_out_char((char) lsm_data.byte.accel_z_low);
				// read output z-axis high reg
				lsm_data.byte.accel_z_high = accel_read(OUT_Z_H_A);
				usartd0_out_char((char) lsm_data.byte.accel_z_high);
				// reset flag to false to allow interrupt to be triggered again
				accel_flag = 0;
			}
			// plots data from all 3 planes
	}
	return 0;
}
	

