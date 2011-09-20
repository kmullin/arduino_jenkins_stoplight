const int REDPin = 3;    // RED pin of the LED to PWM pin 4 
const int GREENPin = 5;  // GREEN pin of the LED to PWM pin 5
const int BLUEPin = 6;   // BLUE pin of the LED to PWM pin 6
int brightness = 255; // LED brightness

char stuff = 0;

void allOff()
{
    analogWrite(GREENPin, 0);
    analogWrite(REDPin, 0);
    analogWrite(BLUEPin, 0);
}

void setup()
{
    pinMode(REDPin, OUTPUT);
    pinMode(GREENPin, OUTPUT);
    pinMode(BLUEPin, OUTPUT);
    Serial.begin(9600);
    turnOn(GREENPin);
    delay(250);
    turnOn(REDPin);
    delay(250);
    turnOn(BLUEPin);
    delay(250);
    allOff();
    turnOn(BLUEPin);
}

void turnOn(int pin)
{
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
    analogWrite(pin, brightness);
    Serial.println(" Led on");
}

void blinkem()
{
    int stall = 250;
    while (Serial.available() <= 0) {
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

void loop()
{
    stuff = 0;
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
        case 70:
          blinkem();
    }
}
