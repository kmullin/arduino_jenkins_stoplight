const bool DEBUG = false;  // output anything to the console (slow)?

const int REDPin = 3;    // RED pin of the LED to PWM pin 3
const int GREENPin = 5;  // GREEN pin of the LED to PWM pin 5
const int BLUEPin = 6;   // BLUE pin of the LED to PWM pin 6

const int stall = 100; // time in MS to wait between blinks for test and failure
const int brightness = 255; // LED brightness

int lastPin = 0;
int fadeAmount = 5;

void allOff()
{ // turn off all pins
  analogWrite(GREENPin, 0);
  analogWrite(REDPin, 0);
  analogWrite(BLUEPin, 0);
  if (DEBUG) {
    Serial.println("Green Led Off");
    Serial.println("Red Led Off");
    Serial.println("Blue Led Off");
  }
}

void selfTest()
{ // test all LEDs and end with Blue
  turnOn(GREENPin);
  delay(stall);
  turnOn(REDPin);
  delay(stall);
  turnOn(BLUEPin);
  delay(stall);
  allOff();
  turnOn(BLUEPin);
}

void setup()
{ // setup serial port and pins
  pinMode(REDPin, OUTPUT);
  pinMode(GREENPin, OUTPUT);
  pinMode(BLUEPin, OUTPUT);
  Serial.begin(9600);
  selfTest();
}

void turnOn(int pin)
{ // turn on one at a time
  analogWrite(pin, brightness);
  lastPin = pin;
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

void fade()
{
  int new_bright = brightness;
  int new_fade = fadeAmount;
  while (checkSerial() == 0) {
    analogWrite(lastPin, new_bright);
    if (DEBUG) {
      Serial.print("FADE: Bright ");
      Serial.println(new_bright);
    }
    if (new_bright == 0 || new_bright == brightness) {
      new_fade = -new_fade;
    }
    new_bright = new_bright + new_fade;
    delay(stall / 10);
  }
}

int checkSerial()
{ /* INPUT:
 1 - Red
 2 - Blue
 3 - Green
 F - Blink all (Fail, or error)
 B - Building (Fade) */
  int stuff = 0;
  if (Serial.available() > 0) {
    stuff = Serial.read();
    if (DEBUG) {
      Serial.println(stuff);
    }
  }
  switch (stuff) {
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
    break;
  case 66:  // if capital 'B' fade
    fade();
    break;
  default:
    stuff = 0;
  }
  return stuff;
}

void loop()
{ // main loop that just reads from serial as fast as it can
  checkSerial();
}
