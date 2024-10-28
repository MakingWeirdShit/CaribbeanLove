#include <FastLED.h>

#define NUM_LEDS 50
#define DATA_PIN 6
#define BRIGHTNESS 128

CRGB leds[NUM_LEDS];
int amplitude = 0;

void setup() {
    Serial.begin(9600);  
    FastLED.addLeds<WS2812, DATA_PIN, RGB>(leds, NUM_LEDS);
    FastLED.setBrightness(BRIGHTNESS);
}

void loop() {
    if (Serial.available() > 0) {
        amplitude = Serial.read();
        
        for (int i = 0; i < NUM_LEDS; i++) {
            leds[i] = CRGB(amplitude, 0, 255 - amplitude);  // Adjust colors based on amplitude
        }
        
        FastLED.show();
    }
}
