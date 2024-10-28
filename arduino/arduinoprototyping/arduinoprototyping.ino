#include <FastLED.h>

// Number of LEDs in your strip
#define NUM_LEDS 50

// Define the data pin for the WS2812 LED strip
#define DATA_PIN 6

// Define the array of LEDs
CRGB leds[NUM_LEDS];

// Set brightness level (0-255)
#define BRIGHTNESS 128

// Animation speed in milliseconds
int speed = 500; // Adjust this to control animation speed

// Time tracking
unsigned long previousMillis = 0;

// Define the colors for the flags
CRGB colors[] = {
    CRGB(255, 0, 24),     // Red (LGBTQIA+)
    CRGB(255, 140, 0),    // Orange (LGBTQIA+)
    CRGB(255, 237, 0),    // Yellow (LGBTQIA+)
    CRGB(0, 121, 255),    // Blue (LGBTQIA+)
    CRGB(127, 63, 152),   // Purple (LGBTQIA+)
    CRGB(0, 0, 0),        // Black (BLM)
    CRGB(255, 255, 255),  // White (BLM)
    CRGB(136, 0, 255),    // Lavender (Intersex/Queer)
};

// Number of colors in the pattern
int numColors = sizeof(colors) / sizeof(colors[0]);

void setup() {
    // Initialize FastLED with the correct data pin and color order
    FastLED.addLeds<WS2812, DATA_PIN, RGB>(leds, NUM_LEDS);
    FastLED.setBrightness(BRIGHTNESS); // Set the brightness level
}

void loop() {
    // Check the time difference
    unsigned long currentMillis = millis();

    // Only update if the time passed is greater than 'speed'
    if (currentMillis - previousMillis >= speed) {
        // Save the current time
        previousMillis = currentMillis;

        // Shift each LED to the color of the previous one
        for (int i = NUM_LEDS - 1; i > 0; i--) {
            leds[i] = leds[i - 1];
        }

        // Cycle through colors in the pattern at the beginning of the strip
        static int colorIndex = 0;
        leds[0] = colors[colorIndex];

        // Move to the next color and wrap around if needed
        colorIndex++;
        if (colorIndex >= numColors) {
            colorIndex = 0;
        }

        // Show the updated LED array
        FastLED.show();
    }
}
