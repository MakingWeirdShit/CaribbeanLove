#include <FastLED.h>

#define NUM_LEDS 50
#define DATA_PIN 6


CRGB leds[NUM_LEDS];
int amplitude = 0;
float fadeAmount = 0.8;  // Fade factor
int brightness = 128;

//  0, 43, 127
int defaultRed = 0;
int defaultGreen = 43;
int defaultBlue = 127;

void setup() {
    Serial.begin(9600);  
    FastLED.addLeds<WS2812, DATA_PIN, RGB>(leds, NUM_LEDS);
    FastLED.setBrightness(brightness);
}

void loop() {
    if (Serial.available() > 0) {
        amplitude = Serial.read();

//        brightness  = 255  - (255 - amplitude);
//        FastLED.setBrightness(brightness);


        // Update LED colors based on amplitude with threshold effects
        for (int i = 0; i < NUM_LEDS; i++) {
//            if (i % 3 == 0 && amplitude < 100) {
//                // Low amplitude effect on specific LEDs
//                leds[i] = CRGB(int(amplitude * 0.5), 0, 255 - int(amplitude * 0.5));
//            } else if (i % 2 == 0 && amplitude > 100) {
//                // High amplitude effect on specific LEDs
//                leds[i] = CRGB(amplitude, 0, 255 - amplitude);
//            } else {
                // Fade effect for all LEDs
                int newRed = defaultRed;
                newRed = map(amplitude, 0, 150, 0, 255);
                int newGreen = defaultGreen ;
                newGreen = map(amplitude, 0, 150, 43, 255);

                int newBlue = defaultBlue;
                newBlue = map(amplitude, 0, 150, 143, 255);
                
//                leds[i] = CRGB(amplitude, 0, 255 - amplitude);
                leds[i] = CRGB(newRed, newGreen, newBlue);
                //leds[i].fadeToBlackBy(int(fadeAmount * 255));
            //}
        }
        
        FastLED.show();
    }
}
