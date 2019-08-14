/*
lab 7, 2. SAMPLING AT A SPECIFIC RATE USING EVENTS
Name: Alexander Nunez
Class #: 11697
PI Name: Chris Crary
Description:   This program will sample the CdS cell once per second.
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>

#define RED_PWM_LED PIN4_bm
#define PER (2000000/1024)	// 1 Hz

int16_t result = 0;

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
	PMIC_CTRL = PMIC_LOLVLEN_bm;	//enable pmic interrupts
	sei();	// global enable interrupts
	// Using the EVCTRL register in the ADC module, make an ADC conversion start when Event Channel 0 is triggered. 
	ADCA_EVCTRL = ADC_SWEEP_0_gc | ADC_EVSEL_0123_gc | ADC_EVACT_CH0_gc;
	ADCA_CTRLA = ADC_ENABLE_bm;
}

// interrupt service routine
ISR( ADCA_CH0_vect ){
	// Save the result into a signed 16-bit integer variable, just like you did in § 1.4.3.
	result = ADCA_CH0_RES;
	// Toggle the RED_PWM LED on the µPAD. 
	PORTD_OUTTGL = RED_PWM_LED;
}

int main( void ) {
	// init red pwm led
	PORTD_OUTSET = 0x00;	// turn led on
	PORTD_DIRSET = RED_PWM_LED;	// set as output
	// initialize adc
	adc_init();
	// initialize tcc0
	tcc0_init();
	
	while(1);
	
	return 0;
}