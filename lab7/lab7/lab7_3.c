/*
lab 7, 3. OUTPUTTING SAMPLED DATA WITH UART
Name: Alexander Nunez
Class #: 11697
PI Name: Chris Crary
Description:   This program will you will test the functionality of your current system by outputting the analog voltage 
value measured on the CdS cell every second, and then display the results, in terms of both decimal and hexadecimal, 
within a serial terminal program on your computer (e.g., PuTTY). 
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>
#include "usart.h"
#include "ebi_driver.h"

#define RED_PWM_LED PIN4_bm
#define PER (2000000/1024)	// 1 Hz
#define B ( -4095 / (2*2047) ) // b = -4095/(2*2047)
#define M (5/4095)	// slope

int16_t result = 0;
float copy = 0;
int temp = 0;
volatile int conv_flag = 0;
char c;

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
	/* At 2 MHz SYSclk, 0 BSEL, -3 BSCALE corresponds to 128000 bps */
	USARTD0.BAUDCTRLA = (uint8_t)0;
	USARTD0.BAUDCTRLB = (uint8_t)( (-3 << 4) | (0 >> 8) );

  /* configure remainder of serial protocol */
  /* in this example, a protocol with 8 data bits, no parity, and
   * one stop bit is chosen. */
	USARTD0.CTRLC = USART_CMODE_ASYNCHRONOUS_gc |
					        USART_PMODE_DISABLED_gc		  |
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


// initialize the TCC0 timer/counter to overflow once a second
void tcc0_init( void ) {
	// Use any valid prescaler/period combination necessary to achieve an overflow time of one second.
	TCC0_CTRLB = 0x00;	// normal mode
	TCC0_PERL = (uint8_t) PER;
	TCC0_PERH = (uint8_t) ( PER >> 8 );
	// Use the TCC0 overflow to trigger an event on Event Channel 0. This can be done using the Event System’s CH0MUX register.
	EVSYS_CH0MUX = EVSYS_CHMUX_TCC0_OVF_gc;
	TCC0_CTRLA = 0x07;	// set prescaler to 1024 and start
}

// initialize adc module
void adc_init(void){
	//12-bit signed, right-adjusted
	// Normal, i.e., NOT freerun mode
	ADCA_CTRLB = ADC_RESOLUTION_12BIT_gc | ADC_CONMODE_bm;
	// Use a 2.5 V voltage reference
	ADCA_REFCTRL = ADC_REFSEL_AREFB_gc;	// external ref from portb
	ADCA_PRESCALER = ADC_PRESCALER_DIV512_gc;	// ADC Clock = peripheral clock/512
	// Only enable the module AFTER all ADC initializations, and do NOT start a conversion within the initialization function.
	PORTA_DIRCLR = PIN1_bm | PIN6_bm;	// set pin1 and pin6 as inputs on port a
	// In the MUXCTRL register, select the appropriate combination of positive and negative inputs to measure the voltage at the CdS cell.
	ADCA_CH0_CTRL = ADC_CH_INPUTMODE_DIFFWGAIN_gc;	// differential w/ gain input mode
	// The CDS+ and CDS- signals on the OOTB Analog Backpack schematic should be used
	ADCA_CH0_MUXCTRL = ADC_CH_MUXPOS_PIN1_gc | ADC_CH_MUXNEG_PIN6_gc;
	
	// Enable an ADC interrupt to be triggered when a conversion is complete.
	ADCA_CH0_INTCTRL = ADC_CH_INTMODE_COMPLETE_gc | ADC_CH_INTLVL_LO_gc;
	PMIC_CTRL = PMIC_LOLVLEN_bm;
	sei();
	// Using the EVCTRL register in the ADC module, make an ADC conversion start when Event Channel 0 is triggered.
	ADCA_EVCTRL = ADC_SWEEP_0_gc | ADC_EVSEL_0123_gc | ADC_EVACT_CH0_gc;
	ADCA_CTRLA = ADC_ENABLE_bm;
}

ISR( ADCA_CH0_vect ){
	// Save the result into a signed 16-bit integer variable, just like you did in § 1.4.3.
	result = ADCA_CH0_RES;
	// set conversion flag to true
	conv_flag = 1;
	// Toggle the RED_PWM LED on the µPAD.
	PORTD_OUTTGL = RED_PWM_LED;
}

int main(void) {
	// init red pwm led
	PORTD_OUTSET = RED_PWM_LED;
	PORTD_DIRSET = RED_PWM_LED;	// set as output
	// initialize adc
	adc_init();
	// initialize tcc0
	tcc0_init();
	// init usart
	usartd0_init();
	
	while(1) {
		// when conv_flag gets set
		while( conv_flag ) {
			// clear conv_flag
			conv_flag = 0;
			copy = (float) ( (M*result)+B);
			// check if voltage is < 0
			if( result < 0 ) {
				usartd0_out_char('-');
			}
			else {
				usartd0_out_char('+');
			}
			// output decimal value
			for(int i = 0; i < 3; i++) {
				temp = (int) copy;
				c = temp + '0';
				usartd0_out_char( c );
				copy = 10 * (copy - temp);
				if( i==0 ) {
					usartd0_out_char('.');
				}
			}
			usartd0_out_char(' ');
			usartd0_out_char('V');
			usartd0_out_char(' ');
			usartd0_out_char('(');
			usartd0_out_char('0');
			usartd0_out_char('x');
			// Output the voltage to the serial terminal
			c = ( (uint8_t) result ) + '0';
			usartd0_out_char( c );
			c = ( (uint8_t) ( result >> 8 ) ) + '0';
			usartd0_out_char( c );
			usartd0_out_char( ')' );
			usartd0_out_char(13);	// carriage return 
			usartd0_out_char(10);	// line feed
		}
		
	}
	
	return 0;
}