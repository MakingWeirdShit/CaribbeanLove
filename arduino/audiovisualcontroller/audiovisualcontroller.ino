#include <FastLED.h>

#define NUM_LEDS 50
#define DATA_PIN 6

CRGB leds[NUM_LEDS];
int amplitude = 0;

// Base color from the flag
int defaultRed = 0;
int defaultGreen = 43;
int defaultBlue = 127;

// Color transition parameters
float targetRed = defaultRed;
float targetGreen = defaultGreen;
float targetBlue = defaultBlue;

// Easing control
float easingFactor = 0.09;  // Control how quickly the colors transition

// Thresholds for voice activity
int lowThreshold = 12;  // Minimum amplitude for response
int highThreshold = 85; // Maximum amplitude for response
int recentAmplitudes[70] = {0}; // Array to hold recent amplitude values
int index = 0; // Index for the recent amplitudes
int minAmplitude = 255; // Minimum amplitude seen in recent history

void setup() {
    Serial.begin(9600);  
    FastLED.addLeds<WS2812, DATA_PIN, RGB>(leds, NUM_LEDS);
    FastLED.setBrightness(128);
}

void loop() {
    if (Serial.available() > 0) {
        amplitude = Serial.read();

        // Update recent amplitudes array and find minimum amplitude
        recentAmplitudes[index] = amplitude;
        index = (index + 1) % 10; // Loop through the array
        minAmplitude = recentAmplitudes[0];

        // Calculate the minimum amplitude from the recent values
        for (int i = 1; i < 10; i++) {
            if (recentAmplitudes[i] < minAmplitude) {
                minAmplitude = recentAmplitudes[i];
            }
        }

        // Map amplitude to a range of 0 to 1 based on thresholds
        float transitionAmount = constrain(map(amplitude, minAmplitude, highThreshold, 0, 1), 0, 1);
        
        // Calculate target colors based on amplitude
        targetRed = lerp(defaultRed, 255, transitionAmount);
        targetGreen = lerp(defaultGreen, 255, transitionAmount);
        targetBlue = lerp(defaultBlue, 255, transitionAmount);

        // Update LED colors based on smoothed transitions
        for (int i = 0; i < NUM_LEDS; i++) {
            // Apply easing to the colors
            leds[i].r = ease(leds[i].r, targetRed);
            leds[i].g = ease(leds[i].g, targetGreen);
            leds[i].b = ease(leds[i].b, targetBlue);
        }
        
        FastLED.show();
    } else {
        // Optional: Fade LEDs back to the base color when no signal is received
        for (int i = 0; i < NUM_LEDS; i++) {
            leds[i].r = ease(leds[i].r, defaultRed);
            leds[i].g = ease(leds[i].g, defaultGreen);
            leds[i].b = ease(leds[i].b, defaultBlue);
        }
        FastLED.show();
    }
}

// Linear interpolation function
float lerp(float start, float end, float t) {
    return start + (end - start) * t;
}

// Easing function for smooth transitions
uint8_t ease(uint8_t current, float target) {
    return current + (target - current) * easingFactor;
}
