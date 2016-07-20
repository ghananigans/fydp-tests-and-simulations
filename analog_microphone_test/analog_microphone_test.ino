#include <stdint.h>
#include <stdio.h>

/* mic pin connections */
uint8_t const MIC_PIN = 0; 

// the setup function runs once when you press reset or power the board
void setup() 
{
  // Setup serial baud-rate
  Serial.begin( 9600 );
  
  // initialize digital pin 13 (LED) as an output.
  pinMode( 13, OUTPUT );
}

uint16_t mic_data;

// the loop function runs over and over again forever
void loop() 
{
  digitalWrite(13, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay( 100 );

  mic_data = analogRead( 0 );
 
  digitalWrite(13, LOW);    // turn the LED off by making the voltage LOW
  Serial.println( "\n\nDone a loop iteration" );
  Serial.println( mic_data, DEC );
  delay( 100 );
}

