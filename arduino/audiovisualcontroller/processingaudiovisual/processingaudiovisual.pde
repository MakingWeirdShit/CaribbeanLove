import processing.sound.*;
import processing.serial.*;

SoundFile song;
Amplitude amp;
Serial myPort;

int numLeds = 50;             // Number of LEDs
float amplitude = 0;           // Audio amplitude
float smoothedAmplitude = 0;   // Smoothed amplitude for reduced jitter
float smoothFactor = 0.1;      // Smoothing factor (higher is smoother but less responsive)
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
  
  // Apply exponential smoothing to reduce jitter
  smoothedAmplitude += (amplitude - smoothedAmplitude) * smoothFactor;
  
  // Set LED colors based on smoothed amplitude with different effects
  for (int i = 0; i < numLeds; i++) {
    int redVal, blueVal;
    
    //// Fluctuate only certain LEDs at low amplitude levels
    //if (i % 3 == 0 && smoothedAmplitude < 100) {
    //  redVal = int(smoothedAmplitude / 1.5);
    //  blueVal = 255 - int(smoothedAmplitude / 1.5);
    //} else if (i % 2 == 0 && smoothedAmplitude > 100) {
    //  // Brighter and more reactive for certain LEDs above threshold
    //  redVal = int(smoothedAmplitude);
    //  blueVal = 255 - int(smoothedAmplitude);
    //} else {
      // Default subtle glow for all LEDs
      redVal = int(smoothedAmplitude * 0.5);
      blueVal = 255 - int(smoothedAmplitude * 0.5);
    

    ledColors[i] = color(redVal, smoothedAmplitude, blueVal);  // Assign color for each "LED"
  }
  
  // Draw the LED strip visualization
  int ledSize = width / numLeds;  // Set the size of each LED square
  for (int i = 0; i < numLeds; i++) {
    fill(ledColors[i]);  // Set fill color based on calculated LED color
    rect(i * ledSize, height / 2 - ledSize / 2, ledSize, ledSize);  // Draw LED square
  }
  
  // Send the smoothed amplitude data to Arduino as a single byte
  if (myPort != null) {
    int ledValue = int(constrain(smoothedAmplitude, 0, 255));  // Constrain to 0-255 range
    println(smoothedAmplitude);
    myPort.write(ledValue);  // Send the smoothed amplitude value
  }
}

void stop() {
  song.stop();  // Stop audio on exit
  super.stop();
}
