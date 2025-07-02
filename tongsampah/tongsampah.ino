// ESP32-CAM + MQ135 + Buzzer + LED + Deep Sleep (Enhanced Version)

#define MQ2_PIN 34       // Analog input pin for MQ-135
#define BUZZER_PIN 22      // GPIO pin for buzzer
#define LED_BUILTIN 2      // Onboard LED for ESP32

#define GAS_THRESHOLD 300  // Set threshold value (adjust after testing)
#define uS_TO_S_FACTOR 1000000  // Conversion factor for seconds to microseconds
#define TIME_TO_SLEEP 300       // 5 minutes in seconds
#define WARMUP_TIME 30000       // Sensor warm-up time in milliseconds
#define NUM_READINGS 10         // Number of readings to average

void longBuzzNotification() {
  for (int i = 0; i < 3; i++) {
    digitalWrite(BUZZER_PIN, HIGH);
    delay(300);
    digitalWrite(BUZZER_PIN, LOW);
    delay(300);
  }
  delay(500);
  for (int i = 0; i < 2; i++) {
    digitalWrite(BUZZER_PIN, HIGH);
    delay(500);
    digitalWrite(BUZZER_PIN, LOW);
    delay(500);
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);
  digitalWrite(LED_BUILTIN, LOW);

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

  // Read gas multiple times to average
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
  }

  // Deep sleep
  esp_sleep_enable_timer_wakeup(TIME_TO_SLEEP * uS_TO_S_FACTOR);
  Serial.println("Entering deep sleep for 5 minutes...");
  delay(100);
  esp_deep_sleep_start();
}

void loop() {
  // Not used due to deep sleep
}
