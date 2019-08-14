/*
 * lab8.c
 *
 * Created: 7/30/2019 1:30:40 PM
 * Author : Aj
 This prgram will generate a waveform with a constant voltage of 1 V, using a DAC module for which you have access to probe on the µPAD
 */ 

#include <avr/io.h>

// use assembly file clock.s
extern void clock_init( void );

int main(void)
{
	// init clock to 32 mhz
	clock_init();
	/*	NEEDS LED BACKPACK
	// output pinc7
	PORTC_OUT = PIN7_bm;
	// set as output
	PORTC_DIRSET = PIN7_bm;
	// output clk speed at 1x and pinC7
	PORTCFG_CLKEVOUT = PORTCFG_CLKOUTSEL_CLK1X_gc | PORTCFG_CLKOUT_PC7_gc;
	*/
	
	//init dac to output 1V
	// ch0 enable and dac enable
	DACA_CTRLA = DAC_CH1EN_bm | DAC_ENABLE_bm;
	
	// output
	
	PORTA_DIRSET = PIN5_bm;
	// loop continuously
    while (1);

	return 0;
}

