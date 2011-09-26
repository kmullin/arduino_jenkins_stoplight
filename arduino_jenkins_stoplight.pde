const bool DEBUG = false;  // output anything to the console (slow)

const int REDPin = 3;    // RED pin of the LED to PWM pin 3
const int GREENPin = 5;  // GREEN pin of the LED to PWM pin 5
const int BLUEPin = 6;   // BLUE pin of the LED to PWM pin 6

const int StatusLED = 13;
const int PushButton = 7; // sensor for pushbutton

const int stall = 175; // time in MS to wait between blinks for test and failure
const int brightness = 255; // LED brightness

unsigned long previousMillis = 0;
unsigned long currentMillis = 0;

int lastPin = 0;
int fadeAmount = 5;

void setup()
{ // setup serial port and pins
  pinMode(REDPin, OUTPUT);
  pinMode(GREENPin, OUTPUT);
  pinMode(BLUEPin, OUTPUT);
  pinMode(StatusLED, OUTPUT);
  pinMode(PushButton, INPUT);
  Serial.begin(9600);
  selfTest();
}

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
{ // blink them all randomly until something else
  int Lights[] = {
    REDPin, BLUEPin, GREENPin      };
  int temp = lastPin;
  int button = 0;
  while ((checkSerial() == 0) && (button != 1)) {
    // Loop until button is pushed, or something valid comes thru serial
    currentMillis = millis();
    if (currentMillis - previousMillis >= stall) {
      previousMillis = currentMillis;
      allOff();
      while (temp == lastPin) {
        temp = Lights[random(3)];
      }
      turnOn(temp);
    }
    button = checkPushButton();
  }
}

void fade()
{
  int new_bright = brightness;
  int new_fade = fadeAmount;
  int button = 0;
  while ((checkSerial() == 0) && (button != 1)) {
    currentMillis = millis();
    if (currentMillis - previousMillis >= (stall / 10)) {
      previousMillis = currentMillis;
      analogWrite(lastPin, new_bright);
      if (DEBUG) {
        Serial.print("FADE: Bright ");
        Serial.println(new_bright);
      }
      if (new_bright == 0 || new_bright == brightness) {
        new_fade = -new_fade;
      }
      new_bright = new_bright + new_fade;
    }
    button = checkPushButton();
  }
  turnOn(lastPin);
}

int checkPushButton()
{
  int val = digitalRead(PushButton);

  if (val == HIGH) {
    return 0;
  }
  return 1;
}

int checkSerial()
{ /* INPUT:
 1 - Red
 2 - Blue
 3 - Green
 B - Blink all (Fail, or error)
 F - Building (Fade) */
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
  case 66:  // if capital 'B' blink all
    blinkem();
    break;
  case 70:  // if capital 'F' fade
    fade();
    break;
  default:
    stuff = 0;
  }
  checkPushButton();
  return stuff;
}

void loop()
{ // main loop that just reads from serial as fast as it can
  int button = 0;
  checkSerial();
  button = checkPushButton();
  if (button == 1) {
    Serial.println(1);
    delay(1000);
  }
}
