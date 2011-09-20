const bool DEBUG = true;  // output anything to the console?

const int REDPin = 3;    // RED pin of the LED to PWM pin 3
const int GREENPin = 5;  // GREEN pin of the LED to PWM pin 5
const int BLUEPin = 6;   // BLUE pin of the LED to PWM pin 6

const int stall = 150; // time in MS to wait between blinks for test and failure

int brightness = 255; // LED brightness

void allOff()
{ // turn off all pins
    analogWrite(GREENPin, 0);
    analogWrite(REDPin, 0);
    analogWrite(BLUEPin, 0);
}

void setup()
{ // test all LEDs and end with Blue
    pinMode(REDPin, OUTPUT);
    pinMode(GREENPin, OUTPUT);
    pinMode(BLUEPin, OUTPUT);
    Serial.begin(9600);
    turnOn(GREENPin);
    delay(stall);
    turnOn(REDPin);
    delay(stall);
    turnOn(BLUEPin);
    delay(stall);
    allOff();
    turnOn(BLUEPin);
}

void turnOn(int pin)
{ // turn on one at a time
    analogWrite(pin, brightness);
    if (DEBUG) {
        switch (pin) {
          case REDPin:
            Serial.print("Red");
            break;
          case BLUEPin:
            Serial.print("Blue");
            break;
          case GREENPin:
            Serial.print("Green");
            break;
        }
        Serial.println(" Led on");
    }
}

void blinkem()
{ // blink them all until another entry comes in the serial
    while (checkSerial() == 0) {
        allOff();
        turnOn(REDPin);
        delay(stall);
        allOff();
        turnOn(BLUEPin);
        delay(stall);
        allOff();
        turnOn(GREENPin);
        delay(stall);
    }
}

int checkSerial()
{ /* INPUT:
  1 - Red
  2 - Blue
  3 - Green
  F - Blink all (Fail, or error) */
    int stuff = 0;
    if (Serial.available() > 0) {
        stuff = Serial.read();
    }
    switch (stuff) {
        case 0: // do nothing
          break;
        case 49: // 1 in ASCII
          allOff();
          turnOn(REDPin);
          break;
        case 50:
          allOff();
          turnOn(BLUEPin);
          break;
        case 51:
          allOff();
          turnOn(GREENPin);
          break;
        case 70:  // if capital 'F' blink all
          blinkem();
        default:
          stuff = 0;  // else set back to 0
    }
    return stuff;
}

void loop()
{ // main loop that just reads from serial as fast as it can
    checkSerial();
}