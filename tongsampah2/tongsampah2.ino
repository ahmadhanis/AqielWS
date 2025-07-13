#include <Wire.h>
#include <Adafruit_SSD1306.h>
#include <Adafruit_GFX.h>
#include <DHT.h>

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

// DHT11 setup
#define DHTPIN 14
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

// MQ135 (simulated using MQ6) on analog pin
#define MQ_PIN 34

// Buzzer
#define BUZZER_PIN 12

void setup() {
  Serial.begin(115200);
beepStartupBuzzer();
  // DHT init
  dht.begin();

  // OLED init
  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println("OLED failed");
    while (true);
  }
  display.clearDisplay();
  display.setTextColor(SSD1306_WHITE);
  display.setTextSize(1);

  // Buzzer pin
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);

  // Warm-up MQ135
  display.setCursor(0, 0);
  display.println("Warming up Sensors...");
  display.setCursor(0, 10);  // Move to next line
  display.println("in 60 seconds");
  display.setCursor(0, 20);  // Move to next line
  display.println("Please wait...");
  display.display();

  delay(60000); // 60 seconds warmup

  display.clearDisplay();
  display.setCursor(0, 0);
  display.println("System Ready");
  display.display();
  delay(2000);
}

void beepStartupBuzzer() {
  // Three short beeps
  for (int i = 0; i < 3; i++) {
    digitalWrite(BUZZER_PIN, HIGH);
    delay(200);
    digitalWrite(BUZZER_PIN, LOW);
    delay(200);
  }
}

void loop() {
  // Read temperature and humidity
  float temp = dht.readTemperature();
  float hum = dht.readHumidity();

  // Read gas value
  int gasValue = analogRead(MQ_PIN);

  // Debug prints
  Serial.print("Temp: "); Serial.print(temp);
  Serial.print(" C, Humidity: "); Serial.print(hum);
  Serial.print(" %, Gas: "); Serial.println(gasValue);

 // Check for alerts
  bool highGas = gasValue > 1800;
  bool highTemp = temp > 45; // adjust threshold for real fire risk

  // OLED Display
  display.clearDisplay();
  display.setCursor(0, 0);
  display.print("    SmartMQ");
  display.setCursor(0, 10);
  display.print("Temp: "); display.print(temp); display.println(" C");
  display.print("Humidity: "); display.print(hum); display.println(" %");
  display.print("Gas Level: "); display.println(gasValue);

if (highGas || highTemp) {
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE, SSD1306_BLACK);
  display.println("⚠ ALERT!");
  if (highGas) display.println("Bad Air Quality");
  if (highTemp) display.println("High Temp Detected");

  // Buzzer pattern based on severity
  if (highGas && highTemp) {
    // Critical: continuous fast beeping
    for (int i = 0; i < 5; i++) {
      digitalWrite(BUZZER_PIN, HIGH);
      delay(100);
      digitalWrite(BUZZER_PIN, LOW);
      delay(100);
    }
  } else if (highTemp) {
    // Fast double beep for high temperature
    for (int i = 0; i < 2; i++) {
      digitalWrite(BUZZER_PIN, HIGH);
      delay(150);
      digitalWrite(BUZZER_PIN, LOW);
      delay(150);
    }
  } else if (highGas) {
    // Single short beep for gas
    digitalWrite(BUZZER_PIN, HIGH);
    delay(300);
    digitalWrite(BUZZER_PIN, LOW);
  }

} else {
  display.println("Air Quality: OK");
  digitalWrite(BUZZER_PIN, LOW);
}


  display.display();
  delay(1000);
}
