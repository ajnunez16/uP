/*
lab 6, Quiz
Name: Alexander Nunez
Class #: 11697
PI Name: Chris Crary
Description:   This program will bit bang spi protocol signals for imaginary slave device.
*/

#include <avr/io.h>

#define SS 0x01
#define SCK 0x02
#define MOSI 0x04
#define data 0x1C
#define BIT0 0x01
#define BIT1 0x02
#define BIT2 0x04
#define BIT3 0x08
#define BIT4 0x10


int main(void){
	// init value of 1
	PORTF.OUTSET = SS | SCK | MOSI;
	// set as outputs
	PORTF.DIRSET = SS | SCK | MOSI;
	
	// loop forever
	while(1){
		// SS low
		PORTF.OUTCLR = SS; 
		// SCK falling edge
		PORTF.OUTCLR = SCK; 
		// D0
		if(data & BIT0)
			PORTF.OUTSET = MOSI;
		else 
			PORTF.OUTCLR = MOSI;
		// SCK rising edge
		PORTF.OUTSET = SCK;
		// SCK falling edge
		PORTF.OUTCLR = SCK; 
		// D1
		if(data & BIT1)
			PORTF.OUTSET = MOSI;
		else
			PORTF.OUTCLR = MOSI;
		// SCK rising edge
		PORTF.OUTSET = SCK;
		// SCK falling edge
		PORTF.OUTCLR = SCK;
		// D2
		if(data & BIT2)
			PORTF.OUTSET = MOSI;
		else
			PORTF.OUTCLR = MOSI;
		// SCK rising edge
		PORTF.OUTSET = SCK;
		// SCK falling edge
		PORTF.OUTCLR = SCK;
		// D3
		if(data & BIT3)
			PORTF.OUTSET = MOSI;
		else
			PORTF.OUTCLR = MOSI;
		// SCK rising edge
		PORTF.OUTSET = SCK;
		// SCK falling edge
		PORTF.OUTCLR = SCK;
		// D4
		if(data & BIT4)
			PORTF.OUTSET = MOSI;
		else
			PORTF.OUTCLR = MOSI;
		// SCK rising edge
		PORTF.OUTSET = SCK;
		// SS high
		PORTF.OUTSET = SS;
	}
	return 0;
}