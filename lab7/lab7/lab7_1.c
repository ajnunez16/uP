/*
lab 7, 1. USING THE ADC SYSTEM 
Name: Alexander Nunez
Class #: 11697
PI Name: Chris Crary
Description:   This program will sample data from the CdS cell located on the OOTB Analog Backpack.
 */ 

#include <avr/io.h>

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
	ADCA_CH0_MUXCTRL = ADC_CH_MUXPOS_PIN1_gc | ADC_CH_MUXNEG_PIN6_gc;
	// The CDS+ and CDS- signals on the OOTB Analog Backpack schematic should be used
	ADCA_CTRLA = ADC_ENABLE_bm; 
}

int main(void)
{
	int16_t result = 0x00;
	adc_init();
    while (1) 
    {
		// Start an ADC conversion on the proper ADC channel
		ADCA_CH0_CTRL |= ADC_CH_START_bm;
		// Wait for the proper ADC interrupt flag to be set, indicating the conversion has finished 
		while( !(ADCA_CH0_INTFLAGS & ADC_CH_CHIF_bm) );
		// Store the 12-bit signed conversion result into a signed 16-bit variable 
		result = ADCA_CH0_RES;
		// clear flag
		ADCA_CH0_INTFLAGS = ADC_CH_CHIF_bm;
    }
	return 0;
}

