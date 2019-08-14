/*
lab 6, 2. TRANSMITTING WITH SPI  
Name: Alexander Nunez
Class #: 11697
PI Name: Chris Crary
Description:   This program will verify the transmitting ability of the
appropriate SPI module with your DAD as it continuously transmits 0x53.
 */ 

#include <avr/io.h>
#include "spi.h"

int main(void) {
	// intialize spi on portf 
	spif_init();
	// continuously transmit 0x53
	while(1) {
		spif_write((uint8_t) 0x53);
	}
	
	return 0;
}