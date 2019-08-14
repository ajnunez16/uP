/*
 * lsm330.c
 */

#include <avr/io.h>
#include "lsm330.h"
#include "lsm330_registers.h"
#include "spi.h"

#define READ_BIT (1<<7)

// Writes a single byte of data (data) to a specific accelerometer register (reg_addr) within the LSM330.
void accel_write(uint8_t reg_addr, uint8_t data){
	PORTF.OUTCLR = SSA;
	// r/w = 0 => write
	// ms = 0 => dont inc addr
	// 2:7 => addr
	// 8:15 => data
	spif_write( reg_addr );
	spif_write( data );
	PORTF.OUTSET = SSA;
}

// Returns a single byte of data that is read from a specific accelerometer register (reg_addr) within the LSM330.
uint8_t accel_read(uint8_t reg_addr){
	PORTF.OUTCLR = SSA;
	// write read and addr
	spif_write( READ_BIT | reg_addr );
	// read data into temp
		// r/w = 1 => read
		// ms = 0 => dont inc addr
		// 2:7 => addr
	uint8_t temp = spif_read();
	// PORTF.OUTCLR = MISO;
	PORTF.OUTSET = SSA;
	return temp;
}

// initialize the LSM330’s accelerometer
void accel_init(void){
	// init spi
	spif_init();
	// reset CTRL_REG4_A, enable interrupt1, make interrupt active high
	accel_write(CTRL_REG4_A, CTRL_REG4_A_STRT | CTRL_REG4_A_INT1_EN | CTRL_REG4_A_IEA);	// int1 connects to pc7, need to config external interrupt on uController
	// enable accelerometer to measure all 3 dimensions simultaneously and config measurements rate at 1600Hz
	accel_write(CTRL_REG5_A, CTRL_REG5_A_XEN | CTRL_REG5_A_YEN | CTRL_REG5_A_ZEN | CTRL_REG5_A_ODR3 | CTRL_REG5_A_ODR0);
}