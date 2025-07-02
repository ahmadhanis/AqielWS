// NodeMCU ESP8266 + MQ2 + Buzzer + LED (Enhanced Version)

#define MQ2_PIN A0         // Analog input pin for MQ-2 (ESP8266 has only one analog pin)
#define BUZZER_PIN D5      // GPIO14
#define LED_BUILTIN D4     // GPIO2 (onboard LED on NodeMCU)

#define GAS_THRESHOLD 300  // Set threshold value (adjust after testing)
#define WARMUP_TIME 20000       // Sensor warm-up time in milliseconds
#define NUM_READINGS 10         // Number of readings to average
#define SLEEP_DURATION 300e6    // 5 minutes in microseconds (ESP.deepSleep in µs)

void longBuzzNotification() {
  // Not OK gas alert: urgent, pulsing tone
  for (int i = 0; i < 5; i++) {
    tone(BUZZER_PIN, 2000); delay(250);
    noTone(BUZZER_PIN); delay(100);
  }
  delay(500);
  for (int i = 0; i < 3; i++) {
    tone(BUZZER_PIN, 1500); delay(400);
    noTone(BUZZER_PIN); delay(100);
  }

  delay(500);
  for (int i = 0; i < 2; i++) {
    digitalWrite(BUZZER_PIN, HIGH);
    delay(500);
    digitalWrite(BUZZER_PIN, LOW);
    delay(500);
  }
}

void shortBuzzNotification() {
  // OK gas alert: musical-like chirp
  for (int i = 0; i < 2; i++) {
    tone(BUZZER_PIN, 1000); delay(100);
    tone(BUZZER_PIN, 1500); delay(100);
    noTone(BUZZER_PIN); delay(100);
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);
  digitalWrite(LED_BUILTIN, LOW);
  delay(500);
  Serial.println("Warming up MQ-2 sensor...");
  
  unsigned long warmupStart = millis();
  bool ledState = false;
  while (millis() - warmupStart < WARMUP_TIME) {
    ledState = !ledState;
    digitalWrite(LED_BUILTIN, ledState);
    delay(500);
  }
  digitalWrite(LED_BUILTIN, LOW);
  Serial.println("Sensor ready.");

  int totalGas = 0;
  for (int i = 0; i < NUM_READINGS; i++) {
    int val = analogRead(MQ2_PIN);
    totalGas += val;
    delay(200);
  }
  int avgGasValue = totalGas / NUM_READINGS;
  Serial.print("Average Gas Value: ");
  Serial.println(avgGasValue);

  if (avgGasValue > GAS_THRESHOLD) {
    Serial.println("Bad smell detected! Triggering buzzer and LED...");
    longBuzzNotification();
    digitalWrite(LED_BUILTIN, HIGH);
    delay(1000);
    digitalWrite(LED_BUILTIN, LOW);
  } else {
    Serial.println("Air quality OK. Playing short confirmation beep.");
    shortBuzzNotification();
  }

  Serial.println("Entering deep sleep for 5 minutes...");
  ESP.deepSleep(SLEEP_DURATION); // in microseconds
}

void loop() {
  // Not used due to deep sleep
}
