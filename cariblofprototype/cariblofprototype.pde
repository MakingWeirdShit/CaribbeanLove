import processing.sound.*;
SoundFile song;
FFT fft;
int bands =128; // Number of frequency bands for FFT
PImage[] images;
int[] dominantColors;
float easing = 0.15; // Increase easing for smoother transitions
float[] currentHue, currentSaturation, currentBrightness; // Arrays to store eased color values

void setup() {
  // Enable fullscreen
  fullScreen();
  
  // Load song and setup FFT
  song = new SoundFile(this, "zag2berenstereo.mp3");
  fft = new FFT(this, bands);
  fft.input(song);
  song.play();
  
  // Load baby images from folder
  String[] filenames = { "alyanne.JPG", "backgroundgreensmile.jpeg", "bfgaio.jpg",  "lilgirlysmilingousside.jpg", "sandsmile.jpg"}; // Replace with your filenames
  images = new PImage[filenames.length];
  dominantColors = new int[filenames.length];
  
  // Initialize arrays for eased color values
  currentHue = new float[filenames.length];
  currentSaturation = new float[filenames.length];
  currentBrightness = new float[filenames.length];
  
  rectMode(CENTER);
  for (int i = 0; i < filenames.length; i++) {
    images[i] = loadImage(filenames[i]);
    dominantColors[i] = extractDominantColor(images[i]); // Extract dominant color for each image
    
    // Initialize the eased color values to the dominant color's initial values
    float r = red(dominantColors[i]);
    float g = green(dominantColors[i]);
    float b = blue(dominantColors[i]);
    colorMode(HSB, 360, 100, 100);
    currentHue[i] = hue(color(r, g, b));
    currentSaturation[i] = saturation(color(r, g, b));
    currentBrightness[i] = brightness(color(r, g, b));
  }
}

void draw() {
  background(0);
  fft.analyze();
  
  // Calculate the width for each image based on screen size
  float imgWidth = width / images.length;
  float imgHeight;

  // Display images and apply brightness and saturation based on FFT amplitude
  for (int i = 0; i < images.length; i++) {
    PImage img = images[i];
    imgHeight = (float)img.height / img.width * imgWidth; // Keep consistent aspect ratio for the image
    float xPos = i * imgWidth + imgWidth / 2; // Adjust xPos for rectMode(CENTER)
    
    // Display image in the top half of the screen (slightly lower to leave room for rects)
    image(img, xPos - imgWidth / 2, 0, imgWidth, imgHeight);
    
    // Adjust the dominant color's brightness and saturation based on FFT
    float fftValue = fft.spectrum[i % bands]; // FFT data for brightness and saturation
    int dominantColor = dominantColors[i];
    
    // Extract RGB components
    float r = red(dominantColor);
    float g = green(dominantColor);
    float b = blue(dominantColor);
    
    // Map FFT values to brightness (0 to 255) and saturation
    float targetBrightness = map(fftValue, 0, 1, 50, 255); // Adjust brightness range
    float targetSaturation = map(fftValue, 0, 1, 0.5, 1.5); // Adjust saturation
    
    // Apply brightness to the dominant color
    colorMode(HSB, 360, 100, 100);
    float targetHue = hue(color(r, g, b));
    float targetSat = saturation(color(r, g, b)) * targetSaturation; // Apply dynamic saturation
    float targetBri = targetBrightness;
    
    // Smoothly interpolate (ease) the current values towards the target values
    currentHue[i] += (targetHue - currentHue[i]) * easing;
    currentSaturation[i] += (targetSat - currentSaturation[i]) * easing;
    currentBrightness[i] += (targetBri - currentBrightness[i]) * easing;
    
    // Set fill color with eased brightness and saturation
    fill(currentHue[i], currentSaturation[i], currentBrightness[i]);
    noStroke();
    
    // Draw a rectangle with the dynamic color in the bottom half of the screen
    float rectHeight = height - imgHeight; // Ensure the rectangle fits in the bottom half without overlap
    rect(xPos, imgHeight + rectHeight / 2, imgWidth, rectHeight); // Bottom half rectangle with dynamic color
  }
}

// Extract dominant color (simplified for this example)
int extractDominantColor(PImage img) {
  img.loadPixels();
  int totalR = 0, totalG = 0, totalB = 0;
  
  // Sample pixels to calculate average color
  for (int i = 0; i < img.pixels.length; i++) {
    color c = img.pixels[i];
    totalR += red(c);
    totalG += green(c);
    totalB += blue(c);
  }
  
  return color(totalR / img.pixels.length, totalG / img.pixels.length, totalB / img.pixels.length);
}
