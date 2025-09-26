// ESP32 Dev Module: Control built-in LED over MQTT from backend
// Backend publishes to: farm/<device_id>/control/light with JSON payload

#include <WiFi.h>
#include <PubSubClient.h>
#include <DHT11.h>

#ifndef LED_BUILTIN
#define LED_BUILTIN 2
#endif

// Set to 1 if your LED turns ON when pin is driven LOW (common on ESP32 Dev)
#ifndef LED_ACTIVE_LOW
#define LED_ACTIVE_LOW 1
#endif

// ====== USER CONFIG: update these ======
const char* WIFI_SSID = "Decompiler";
const char* WIFI_PASSWORD = "17532296404";
// To find your MQTT broker IP or hostname when using Docker:
// - If your ESP32 is on the same WiFi network as your PC, run `ipconfig` (Windows) or `ifconfig`/`ip a` (Linux/Mac) on your PC to get its local IP address.
// - Use that IP as MQTT_HOST (e.g., "192.168.1.100") if you started the broker with Docker on your PC.
// - If using Docker Compose, make sure the broker's port (usually 1883) is published to your host.
// Example (replace with your actual host IP):
const char* MQTT_HOST = "192.168.0.134"; // Broker IP or hostname
const uint16_t MQTT_PORT = 1883;
const char* DEVICE_ID = "esp32-001";  // Must match backend device_id
// =======================================

WiFiClient wifiClient;
PubSubClient mqttClient(wifiClient);

char controlTopic[128];
char tempTopic[128];
char humTopic[128];
char waterflowTopic[128];

// ====== DHT11 SENSOR CONFIG ======
#ifndef DHTPIN
#define DHTPIN 4
#endif
DHT11 dht(DHTPIN);

// ====== WATER FLOW SENSOR CONFIG ======
#ifndef WATERFLOW_PIN
#define WATERFLOW_PIN 5
#endif
volatile int flowPulseCount = 0;
volatile unsigned long lastFlowPulseTime = 0;
volatile unsigned long totalPulseCount = 0; // Total pulses since startup
const float CALIBRATION_FACTOR = 4.5; // Pulses per liter/minute (adjust based on your sensor)

// Water flow sensor interrupt handler
void IRAM_ATTR flowPulse() {
  unsigned long currentTime = millis();
  // Debounce: ignore pulses faster than 10ms apart
  if (currentTime - lastFlowPulseTime > 10) {
    flowPulseCount++;
    totalPulseCount++;
    lastFlowPulseTime = currentTime;
  }
}

void connectWiFi() {
  WiFi.mode(WIFI_STA);
  Serial.println("[WiFi] Connecting...");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  uint32_t startMs = millis();
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print('.');
    if (millis() - startMs > 20000) { // 20s timeout then retry
      Serial.println("\n[WiFi] Timeout. Retrying...");
      startMs = millis();
      WiFi.disconnect();
      delay(200);
      WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    }
  }
  Serial.print("\n[WiFi] Connected. IP: ");
  Serial.println(WiFi.localIP());
}

void handleControlMessage(char* topic, byte* payload, unsigned int length) {
  Serial.print("[MQTT] Message on ");
  Serial.print(topic);
  Serial.print(" len=");
  Serial.println(length);
  // Backend payload example: {"command":"light","desired_state":"on",...}
  // Minimal parse: search for desired_state on/off without adding ArduinoJson
  bool turnOn = false;
  String s;
  s.reserve(length + 1);
  for (unsigned int i = 0; i < length; ++i) s += (char)payload[i];
  Serial.print("[MQTT] Payload: ");
  Serial.println(s);

  // Robust extraction of desired_state (ignores spaces):
  int keyPos = s.indexOf("\"desired_state\"");
  if (keyPos >= 0) {
    int colonPos = s.indexOf(':', keyPos);
    if (colonPos >= 0) {
      // find opening quote after colon
      int openQ = s.indexOf('"', colonPos + 1);
      if (openQ >= 0) {
        int closeQ = s.indexOf('"', openQ + 1);
        if (closeQ > openQ) {
          String val = s.substring(openQ + 1, closeQ);
          val.toLowerCase();
          Serial.print("[PARSE] desired_state=\"");
          Serial.print(val);
          Serial.println("\"");
          if (val == "on") turnOn = true;
          if (val == "off") turnOn = false;
        }
      }
    }
  }
  int level = turnOn ? (LED_ACTIVE_LOW ? LOW : HIGH) : (LED_ACTIVE_LOW ? HIGH : LOW);
  digitalWrite(LED_BUILTIN, level);
  Serial.print("[LED] State -> ");
  Serial.print(turnOn ? "ON" : "OFF");
  Serial.print(" (pin level=");
  Serial.print(level == HIGH ? "HIGH" : "LOW");
  Serial.println(")");
}

void ensureMqttConnected() {
  while (!mqttClient.connected()) {
    String clientId = String("esp32-") + String((uint32_t)ESP.getEfuseMac(), HEX);
    Serial.print("[MQTT] Connecting to ");
    Serial.print(MQTT_HOST);
    Serial.print(":");
    Serial.print(MQTT_PORT);
    Serial.print(" as ");
    Serial.println(clientId);
    if (mqttClient.connect(clientId.c_str())) {
      Serial.println("[MQTT] Connected");
      if (mqttClient.subscribe(controlTopic, 1)) {
        Serial.print("[MQTT] Subscribed: ");
        Serial.println(controlTopic);
      } else {
        Serial.println("[MQTT] Subscribe failed");
      }
    } else {
      Serial.print("[MQTT] Connect failed, state=");
      Serial.println(mqttClient.state());
      delay(1000);
    }
  }
}

void setup() {
  Serial.begin(115200);
  delay(200);
  Serial.println();
  Serial.println("=== ESP32 LED MQTT Client ===");
  Serial.print("Device: "); Serial.println(DEVICE_ID);
  Serial.print("Broker: "); Serial.print(MQTT_HOST); Serial.print(":"); Serial.println(MQTT_PORT);
  Serial.print("WiFi SSID: "); Serial.println(WIFI_SSID);

  pinMode(LED_BUILTIN, OUTPUT);
  // Ensure LED starts OFF
  digitalWrite(LED_BUILTIN, LED_ACTIVE_LOW ? HIGH : LOW);

  snprintf(controlTopic, sizeof(controlTopic), "farm/%s/control/light", DEVICE_ID);
  Serial.print("[Topic] Control: "); Serial.println(controlTopic);
  snprintf(tempTopic, sizeof(tempTopic), "farm/%s/sensor/temperature", DEVICE_ID);
  Serial.print("[Topic] Temperature: "); Serial.println(tempTopic);
  snprintf(humTopic, sizeof(humTopic), "farm/%s/sensor/humidity", DEVICE_ID);
  Serial.print("[Topic] Humidity: "); Serial.println(humTopic);
  snprintf(waterflowTopic, sizeof(waterflowTopic), "farm/%s/sensor/waterflow", DEVICE_ID);
  Serial.print("[Topic] Waterflow: "); Serial.println(waterflowTopic);

  // Setup water flow sensor
  pinMode(WATERFLOW_PIN, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(WATERFLOW_PIN), flowPulse, RISING);

  connectWiFi();
  mqttClient.setServer(MQTT_HOST, MQTT_PORT);
  mqttClient.setCallback(handleControlMessage);
}

void loop() {
  if (WiFi.status() != WL_CONNECTED) {
    connectWiFi();
  }
  if (!mqttClient.connected()) {
    ensureMqttConnected();
  }
  mqttClient.loop();
  static uint32_t lastLog = 0;
  if (millis() - lastLog > 10000) { // every 10s
    lastLog = millis();
    Serial.print("[HB] WiFi "); Serial.print(WiFi.localIP());
    Serial.print(" | MQTT "); Serial.println(mqttClient.connected() ? "OK" : "DISCONNECTED");
  }
  // Periodic sensor publishes (server-expected topics)
  static uint32_t lastTelemetry = 0;
  if (millis() - lastTelemetry > 5000) { // every 5s
    lastTelemetry = millis();
    
    // DHT11 readings
    int tC = 0;
    int hP = 0;
    int err = dht.readTemperatureHumidity(tC, hP);
    if (err != 0) {
      Serial.print("[DHT] Read error code: ");
      Serial.println(err);
    } else {
      char payloadTemp[64];
      char payloadHum[64];
      int n1 = snprintf(payloadTemp, sizeof(payloadTemp), "{\"value_c\":%.2f}", (float)tC);
      int n2 = snprintf(payloadHum, sizeof(payloadHum), "{\"value_pct\":%.2f}", (float)hP);
      if (n1 > 0 && n1 < (int)sizeof(payloadTemp)) {
        bool ok1 = mqttClient.publish(tempTopic, payloadTemp, false);
        Serial.print("[PUB] Temp -> "); Serial.print(tempTopic);
        Serial.print(" | "); Serial.println(ok1 ? payloadTemp : "publish failed");
      }
      if (n2 > 0 && n2 < (int)sizeof(payloadHum)) {
        bool ok2 = mqttClient.publish(humTopic, payloadHum, false);
        Serial.print("[PUB] Hum -> "); Serial.print(humTopic);
        Serial.print(" | "); Serial.println(ok2 ? payloadHum : "publish failed");
      }
    }
    
    // Water flow reading
    noInterrupts();
    int pulseCount = flowPulseCount;
    unsigned long totalPulses = totalPulseCount;
    flowPulseCount = 0;
    interrupts();
    
    // Calculate various flow metrics
    float flowRate = (pulseCount * 60.0) / (5.0 * CALIBRATION_FACTOR); // L/min
    float totalVolume = totalPulses / CALIBRATION_FACTOR; // Total liters since startup
    float avgFlowRate = (totalPulses * 60.0) / (millis() / 1000.0 * CALIBRATION_FACTOR); // Average L/min since startup
    
    char payloadWaterflow[128];
    int n3 = snprintf(payloadWaterflow, sizeof(payloadWaterflow), 
                     "{\"l_per_min\":%.2f,\"total_liters\":%.2f,\"avg_l_per_min\":%.2f,\"pulses\":%lu}", 
                     flowRate, totalVolume, avgFlowRate, totalPulses);
    if (n3 > 0 && n3 < (int)sizeof(payloadWaterflow)) {
      bool ok3 = mqttClient.publish(waterflowTopic, payloadWaterflow, false);
      Serial.print("[PUB] Waterflow -> "); Serial.print(waterflowTopic);
      Serial.print(" | "); Serial.println(ok3 ? payloadWaterflow : "publish failed");
    }
  }
  delay(10);
}
