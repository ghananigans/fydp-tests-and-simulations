#include <SPI.h> // Mic uses the SPI protocol
#include <stdint.h>
#include <stdio.h>

/* mic pin connections */
uint8_t const SS_PIN = 10; 

/* 
 * ---------Mic SPI Settings
 * Our mic has a max clock rate of 20 MHz, sends data with MSB first
 * and operates with SPI_MODE1 (data placed on rishing edge of clock,
 * and data received on falling edge of clock).
 *
 */
SPISettings spi_settings( 20000000, MSBFIRST, SPI_MODE1 );

// the setup function runs once when you press reset or power the board
void setup() 
{
  // Setup serial baud-rate
  Serial.begin( 9600 );
  
  // initialize digital pin 13 (LED) as an output.
  pinMode( 13, OUTPUT );

  // Initialize the bus for a SPI device on pin 10
  pinMode( SS_PIN, OUTPUT );
  SPI.begin();
}

uint16_t spi_data;

// the loop function runs over and over again forever
void loop() 
{
  digitalWrite(13, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay( 100 );
  
  SPI.beginTransaction( spi_settings );
  digitalWrite( SS_PIN, LOW );

  // reading only.
  spi_data = SPI.transfer16( 0 ) & ( 0x0FFF );

  digitalWrite( SS_PIN, HIGH );
  SPI.endTransaction();
  
  digitalWrite(13, LOW);    // turn the LED off by making the voltage LOW
  Serial.println( "\n\nDone a loop iteration" );
  Serial.println( spi_data, DEC );

  delay( 100 );
}
