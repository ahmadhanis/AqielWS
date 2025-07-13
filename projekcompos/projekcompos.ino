#include <Wire.h>
#include <Adafruit_SSD1306.h>
#include <Adafruit_GFX.h>
#include <DHT.h>

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);

#define DHTPIN 14
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

#define MQ_PIN 34
#define BUZZER_PIN 12

void beepStartupBuzzer() {
  for (int i = 0; i < 3; i++) {
    digitalWrite(BUZZER_PIN, HIGH);
    delay(200);
    digitalWrite(BUZZER_PIN, LOW);
    delay(200);
  }
}

String getGasLevelText(int gasValue) {
  if (gasValue < 1000) return "Rendah";
  else if (gasValue < 1800) return "Sederhana";
  else return "Tinggi";
}

int mapValueToBar(int value, int min, int max, int width) {
  value = constrain(value, min, max);
  return map(value, min, max, 0, width);
}

void setup() {
  Serial.begin(115200);
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);
  beepStartupBuzzer();
  dht.begin();

  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println("OLED failed");
    while (true);
  }

  display.clearDisplay();
  display.setTextColor(SSD1306_WHITE);
  display.setTextSize(2);  // Font lebih besar
  display.setCursor(0, 0);
  display.println("SmartMQ");
  display.setCursor(0, 20);
  display.println("Kompos");
  display.setTextSize(1);  // Kembali ke font kecil untuk nota
  display.setCursor(0, 45);
  display.println("Tunggu 60s...");
  display.display();


  delay(60000);

  display.clearDisplay();
  display.setCursor(0, 0);
  display.println("Sedia untuk kompos");
  display.display();
  delay(2000);
}

void loop() {
  float temp = dht.readTemperature();
  float hum = dht.readHumidity();
  int gasValue = analogRead(MQ_PIN);

  Serial.print("Suhu: "); Serial.print(temp);
  Serial.print(" C, Kelembapan: "); Serial.print(hum);
  Serial.print(" %, Gas: "); Serial.println(gasValue);

  bool highGas = gasValue > 1800;
  bool highTemp = temp > 45;

  // --- Paparan utama ---
  display.clearDisplay();

  // Bar suhu
  display.setTextSize(1);
  display.setCursor(0, 0);
  display.print("Suhu:");
  int tempBar = mapValueToBar(temp, 0, 60, 60);
  display.fillRect(50, 0, tempBar, 6, SSD1306_WHITE);
  display.drawRect(50, 0, 60, 6, SSD1306_WHITE);

  // Bar gas
  display.setCursor(0, 10);
  display.print("Gas :");
  int gasBar = mapValueToBar(gasValue, 0, 3000, 60);
  display.fillRect(50, 10, gasBar, 6, SSD1306_WHITE);
  display.drawRect(50, 10, 60, 6, SSD1306_WHITE);

  // Suhu besar
  display.setTextSize(2);
  display.setCursor(0, 20);
  display.print("T:"); 
  display.print((int)temp); 
  display.print("C");

  // Tahap gas besar
  display.setCursor(0, 40);
  display.print("G:");
  display.print(getGasLevelText(gasValue)); // Rendah/Sederhana/Tinggi

  // Amaran kecil
  display.setTextSize(1);
  if (highGas || highTemp) {
    display.setCursor(80, 52);
    display.println("⚠ Amaran!");
  }

  display.display();

  // --- Buzzer ---
  if (highGas || highTemp) {
    if (highGas && highTemp) {
      for (int i = 0; i < 5; i++) {
        digitalWrite(BUZZER_PIN, HIGH); delay(100);
        digitalWrite(BUZZER_PIN, LOW); delay(100);
      }
    } else if (highTemp) {
      for (int i = 0; i < 2; i++) {
        digitalWrite(BUZZER_PIN, HIGH); delay(150);
        digitalWrite(BUZZER_PIN, LOW); delay(150);
      }
    } else if (highGas) {
      digitalWrite(BUZZER_PIN, HIGH); delay(300);
      digitalWrite(BUZZER_PIN, LOW);
    }
  } else {
    digitalWrite(BUZZER_PIN, LOW);
  }

  delay(1000);
}


