/*
 * examL2.c
 *
 * Created: 8/6/2019 9:34:54 AM
 * Author : Aj
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>

#define PER1 ((2000000/1024)/1250)	// 1250 Hz
#define PER2 ((2000000/1024)/2500)	// 2500 Hz

uint16_t arr[] = {0,373,737,1000,373,737,1000,1370};

// initialize the TCC0 timer/counter 
void tcc0_init( void ) {
	// Use any valid prescaler/period combination necessary to achieve an overflow time of one second.
	TCD0_CTRLB = 0x00;	// normal mode
	TCD0_PERL = (uint8_t) PER1;
	TCD0_PERH = (uint8_t) ( PER1 >> 8 );
	PMIC_CTRL |= PMIC_MEDLVLEN_bm;
	sei();
}

// initialize the TCC1 timer/counter
void tcc1_init( void ) {
	// Use any valid prescaler/period combination necessary to achieve an overflow time of one second.
	TCD1_CTRLB = 0x00;	// normal mode
	TCD1_PERL = (uint8_t) PER2;
	TCD1_PERH = (uint8_t) ( PER2 >> 8 );
	PMIC_CTRL |= PMIC_LOLVLEN_bm;
	sei();
}

ISR(TCD0_OVF_vect){
	PORTC_OUTTGL = PIN0_bm;
}

ISR(TCD1_OVF_vect){
	PORTC_OUTTGL = PIN0_bm;
}

int main(void)
{
    // init ebi s1 and s2 as input
	PORTE_DIRCLR = PIN0_bm | PIN1_bm;
	// init tc at 1250Hz
	tcc0_init();
	// init tc at 2500 Hz
	tcc1_init();
	// init portc as output for debugging
	PORTC_OUT = 0xFF;
	PORTC_DIRSET = 0xff;
    while (1) 
    {
			// loop while s1 is pressed
			while(PORTE_IN == PIN0_bm){
				if(TCD0_CTRLA!=0x07)
					TCD0_CTRLA = 0x07;
				PORTC_OUT = TCD0_CNT;
			}
			TCD0_CTRLA = 0x00;	// stop tcc0
			// loop while s2 is pressed
			while(PORTE_IN == PIN1_bm){
				if(TCD1_CTRLA!=0x07)
					TCD1_CTRLA = 0x07;
				PORTC_OUT = TCD1_CNT;
			}
			TCD1_CTRLA = 0x00;	// stop tcc1
    }
	return 0;
}

