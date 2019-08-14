/*
lab 6, 3. RECEIVING WITH SPI & COMMUNICATING WITH THE LSM330 
Name: Alexander Nunez
Class #: 11697
PI Name: Chris Crary
Description:   This program will read from an accelerometer register within the external LSM330 IMU
*/

#include <avr/io.h>
#include "lsm330.h"
#include "lsm330_registers.h"


int main(void) {
	//  init spi
	spif_init();
	// verify receive functionality of our SPI system
	while( accel_read(WHO_AM_I_A) != DEFAULT_VAL_A);
	return 0;
}