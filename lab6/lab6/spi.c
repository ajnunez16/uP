/*
 * spi.c
 *
 *  Last updated: 7/11/2019 4:49 PM
 *  Author: Dr. Schwartz
*/ 

#include <avr/io.h>
#include "spi.h"

/* initializes the SPI module of Port F to communicate with the LSM330 */
void spif_init(void)
{
	
  /* configure pin direction of SPI signals */
  PORTF.OUTSET = MOSI | SSA | SENSOR_SEL;
  PORTA.OUTCLR = PROTOCOL_SEL;
  PORTF.DIRSET	= MOSI | SCK | SSA | SCL | SENSOR_SEL;
  PORTA.DIRSET = PROTOCOL_SEL;
  PORTF.DIRCLR  = MISO;
	
	/* 8 MHz SPI frequency since 10MHz is the maximum allowed by the LSM330 */
	SPIF.CTRL	=	SPI_PRESCALER_DIV4_gc	|
						      SPI_MASTER_bm			    |
						      SPI_MODE_3_gc         |
						      SPI_ENABLE_bm;
}

/* writes a single byte of data to the SPIF data register */
void spif_write(uint8_t data)
{
	SPIF.DATA = data;
	while(!(SPIF.STATUS = SPI_IF_bm));	/* wait for transfer to be complete */
}

/* attempts to read a byte of data from device connected to SPIF */
uint8_t spif_read(void)
{
  SPIF.DATA = 0x37;                   /* write garbage to cause transaction */
  while(!(SPIF.STATUS = SPI_IF_bm));	/* wait for transfer to be complete */
	return SPIF.DATA;
}