import processing.sound.*;
import processing.serial.*;

SoundFile song;
Amplitude amp;
Serial myPort;

int numLeds = 50;             // Number of LEDs
float amplitude = 0;           // Audio amplitude
color[] ledColors = new color[numLeds];  // Array to hold each LED's color

void setup() {
  size(800, 200);  // Window size large enough to display LEDs
  
  // Initialize and load the audio file
  song = new SoundFile(this, "zag2berenstereo.mp3");  // Replace with your audio file path
  song.loop();
  
  // Set up the amplitude analyzer
  amp = new Amplitude(this);
  amp.input(song);
  
  // Set up serial communication with Arduino
  String portName = Serial.list()[0];  // Select the correct port for your Arduino
  myPort = new Serial(this, portName, 9600);
  
  // Initialize LED colors array
  for (int i = 0; i < numLeds; i++) {
    ledColors[i] = color(0);  // Start with all LEDs off (black)
  }
}

void draw() {
  background(0);
  
  // Analyze the current amplitude
  amplitude = amp.analyze() * 255;  // Scale to 0-255 for LED brightness
  
  // Set LED colors based on amplitude
  for (int i = 0; i < numLeds; i++) {
    int redVal = int(amplitude);                // Red based on amplitude
    int blueVal = 255 - int(amplitude);         // Blue is the inverse
    ledColors[i] = color(redVal, 0, blueVal);   // Assign color for each "LED"
  }
  
  // Draw the LED strip visualization
  int ledSize = width / numLeds;  // Set the size of each LED square
  for (int i = 0; i < numLeds; i++) {
    fill(ledColors[i]);  // Set fill color based on calculated LED color
    rect(i * ledSize, height / 2 - ledSize / 2, ledSize, ledSize);  // Draw LED square
  }
  
  // Send amplitude data to Arduino (if serial connection is open)
  if (myPort != null) {
    int ledValue = int(constrain(amplitude, 0, 255));  // Constrain to 0-255 range
    myPort.write(ledValue);  // Send the amplitude value as a single byte
  }
}

void stop() {
  song.stop();  // Stop audio on exit
  super.stop();
}
