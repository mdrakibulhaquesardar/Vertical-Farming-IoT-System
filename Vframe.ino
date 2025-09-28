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

// ====== RGB LED CONFIG ======
#ifndef RGB_RED_PIN
#define RGB_RED_PIN 18    // GPIO18 for Red channel
#endif
#ifndef RGB_GREEN_PIN
#define RGB_GREEN_PIN 21  // GPIO21 for Green channel
#endif
#ifndef RGB_BLUE_PIN
#define RGB_BLUE_PIN 22   // GPIO22 for Blue channel
#endif

// ====== RELAY CONFIG ======
#ifndef RELAY_PIN
#define RELAY_PIN 19  // GPIO19 for relay control
#endif
// =======================================

WiFiClient wifiClient;
PubSubClient mqttClient(wifiClient);

char controlTopic[128];
char relayTopic[128];
char statusTopic[128];
char statusRequestTopic[128];
char tempTopic[128];
char humTopic[128];
char waterflowTopic[128];
char tdsTopic[128];

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

// ====== TDS SENSOR CONFIG ======
#ifndef TDS_PIN
#define TDS_PIN 34  // ADC1_CH6 (GPIO34) - analog input
#endif
#ifndef VREF
#define VREF 3.3  // analog reference voltage
#endif
#ifndef SCOUNT
#define SCOUNT 30  // sum of sample point
#endif

// TDS Quality Thresholds (ppm)
#define TDS_EXCELLENT 300   // <300 ppm - Pure/Drinking water
#define TDS_GOOD 600        // 300-600 ppm - Average tap water  
#define TDS_FAIR 800        // 600-800 ppm - Acceptable for plants
#define TDS_POOR 1000       // 800-1000 ppm - Poor quality
// >1000 ppm - Polluted/Unsafe

// RGB LED variables
bool wifiConnected = false;
bool mqttConnected = false;
unsigned long lastStatusBlink = 0;
bool statusLedState = false;

// TDS sensor variables
int analogBuffer[SCOUNT];
int analogBufferTemp[SCOUNT];
int analogBufferIndex = 0;
int copyIndex = 0;

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

float getMedianNum(int bArray[], int iFilterLen) {
  int bTab[iFilterLen];
  for (byte i = 0; i < iFilterLen; i++)
    bTab[i] = bArray[i];
  int i, j, bTemp;
  for (j = 0; j < iFilterLen - 1; j++) {
    for (i = 0; i < iFilterLen - j - 1; i++) {
      if (bTab[i] > bTab[i + 1]) {
        bTemp = bTab[i];
        bTab[i] = bTab[i + 1];
        bTab[i + 1] = bTemp;
      }
    }
  }
  if ((iFilterLen & 1) > 0)
    bTemp = bTab[(iFilterLen - 1) / 2];
  else
    bTemp = (bTab[iFilterLen / 2] + bTab[iFilterLen / 2 - 1]) / 2;
  return bTemp;
}

float readTDS() {
  static unsigned long analogSampleTimepoint = millis();
  static unsigned long lastTDSReading = 0;
  static float lastTDSValue = 0.0;
  static bool firstReading = true;
  
  // Sample analog every 40ms
  if (millis() - analogSampleTimepoint > 40U) {
    analogSampleTimepoint = millis();
    int rawValue = analogRead(TDS_PIN);
    analogBuffer[analogBufferIndex] = rawValue;
    analogBufferIndex++;
    if (analogBufferIndex == SCOUNT) {
      analogBufferIndex = 0;
      if (firstReading) {
        Serial.print("[TDS] First buffer filled, raw values: ");
        for (int i = 0; i < 5; i++) {
          Serial.print(analogBuffer[i]);
          Serial.print(" ");
        }
        Serial.println("...");
        firstReading = false;
      }
    }
  }
  
  // Calculate TDS every 800ms and store the result
  if (millis() - lastTDSReading > 800U) {
    lastTDSReading = millis();
    for (copyIndex = 0; copyIndex < SCOUNT; copyIndex++)
      analogBufferTemp[copyIndex] = analogBuffer[copyIndex];
    
    int medianValue = getMedianNum(analogBufferTemp, SCOUNT);
    float averageVoltage = medianValue * (float)VREF / 4095.0;
    float compensationCoefficient = 1.0 + 0.02 * (25.0 - 25.0); // temperature compensation
    float compensationVoltage = averageVoltage / compensationCoefficient;
    lastTDSValue = (133.42 * compensationVoltage * compensationVoltage * compensationVoltage - 255.86 * compensationVoltage * compensationVoltage + 857.39 * compensationVoltage) * 0.5;
    
    Serial.print("[TDS] Debug - Raw: ");
    Serial.print(medianValue);
    Serial.print(", Voltage: ");
    Serial.print(averageVoltage, 3);
    Serial.print(", TDS: ");
    Serial.println(lastTDSValue, 2);
  }
  
  return lastTDSValue;
}

void publishRelayStatus(bool isOn) {
  char payload[128];
  int n = snprintf(payload, sizeof(payload), 
                   "{\"relay\":{\"state\":\"%s\",\"timestamp\":%lu}}", 
                   isOn ? "on" : "off", millis());
  if (n > 0 && n < (int)sizeof(payload)) {
    bool ok = mqttClient.publish(statusTopic, payload, false);
    Serial.print("[STATUS] Relay -> ");
    Serial.print(statusTopic);
    Serial.print(" | "); 
    Serial.println(ok ? payload : "publish failed");
  }
}

void publishLEDStatus(bool isOn) {
  char payload[128];
  int n = snprintf(payload, sizeof(payload), 
                   "{\"light\":{\"state\":\"%s\",\"timestamp\":%lu}}", 
                   isOn ? "on" : "off", millis());
  if (n > 0 && n < (int)sizeof(payload)) {
    bool ok = mqttClient.publish(statusTopic, payload, false);
    Serial.print("[STATUS] Light -> ");
    Serial.print(statusTopic);
    Serial.print(" | "); 
    Serial.println(ok ? payload : "publish failed");
  }
}

String getTDSQuality(float tdsValue) {
  if (tdsValue < TDS_EXCELLENT) {
    return "EXCELLENT";
  } else if (tdsValue < TDS_GOOD) {
    return "GOOD";
  } else if (tdsValue < TDS_FAIR) {
    return "FAIR";
  } else if (tdsValue < TDS_POOR) {
    return "POOR";
  } else {
    return "UNSAFE";
  }
}

void setRGBColor(int red, int green, int blue) {
  analogWrite(RGB_RED_PIN, red);
  analogWrite(RGB_GREEN_PIN, green);
  analogWrite(RGB_BLUE_PIN, blue);
}

void updateStatusLED() {
  bool allGood = wifiConnected && mqttConnected;
  
  if (allGood) {
    // Both OK - Green color
    setRGBColor(0, 255, 0);  // Green
  } else if (wifiConnected && !mqttConnected) {
    // WiFi OK but MQTT failed - Yellow color
    setRGBColor(255, 255, 0);  // Yellow
  } else if (!wifiConnected) {
    // WiFi failed - Blue color (blinking)
    if (millis() - lastStatusBlink > 500) {
      statusLedState = !statusLedState;
      if (statusLedState) {
        setRGBColor(0, 0, 255);  // Blue ON
      } else {
        setRGBColor(0, 0, 0);    // All OFF
      }
      lastStatusBlink = millis();
    }
  } else {
    // Unknown state - Red color
    setRGBColor(255, 0, 0);  // Red
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
    // Update status LED during WiFi connection attempts
    updateStatusLED();
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
  wifiConnected = true;
}

void handleControlMessage(char* topic, byte* payload, unsigned int length) {
  Serial.print("[MQTT] Message on ");
  Serial.print(topic);
  Serial.print(" len=");
  Serial.println(length);
  
  String s;
  s.reserve(length + 1);
  for (unsigned int i = 0; i < length; ++i) s += (char)payload[i];
  Serial.print("[MQTT] Payload: ");
  Serial.println(s);

  // Check if this is a status request
  String topicStr = String(topic);
  if (topicStr.indexOf("/status/request") >= 0) {
    Serial.println("[STATUS] Status request received");
    // Publish current relay status
    bool currentRelayState = digitalRead(RELAY_PIN) == LOW; // LOW = ON (as per your logic)
    publishRelayStatus(currentRelayState);
    
    // Publish current LED status (reverse logic for LED_ACTIVE_LOW)
    bool currentLEDState = digitalRead(LED_BUILTIN) == (LED_ACTIVE_LOW ? LOW : HIGH);
    publishLEDStatus(currentLEDState);
    return;
  }

  // Check if this is a relay control message
  if (topicStr.indexOf("/relay") >= 0) {
    // Relay control: {"target": "relay", "desired_state": "on"}
    bool turnOn = false;
    int keyPos = s.indexOf("\"desired_state\"");
    if (keyPos >= 0) {
      int colonPos = s.indexOf(':', keyPos);
      if (colonPos >= 0) {
        int openQ = s.indexOf('"', colonPos + 1);
        if (openQ >= 0) {
          int closeQ = s.indexOf('"', openQ + 1);
          if (closeQ > openQ) {
            String val = s.substring(openQ + 1, closeQ);
            val.toLowerCase();
            Serial.print("[RELAY] desired_state=\"");
            Serial.print(val);
            Serial.println("\"");
            if (val == "on") turnOn = true;
            if (val == "off") turnOn = false;
          }
        }
      }
    }
    digitalWrite(RELAY_PIN, turnOn ? LOW : HIGH);
    Serial.print("[RELAY] State -> ");
    Serial.print(turnOn ? "OFF" : "ON");
    Serial.print(" (pin level=");
    Serial.print(turnOn ? "HIGH" : "LOW");
    Serial.println(")");
    
    // Publish current relay state
    publishRelayStatus(turnOn);
  } else {
    // LED control: {"command":"light","desired_state":"on",...}
    bool turnOn = false;
    int keyPos = s.indexOf("\"desired_state\"");
    if (keyPos >= 0) {
      int colonPos = s.indexOf(':', keyPos);
      if (colonPos >= 0) {
        int openQ = s.indexOf('"', colonPos + 1);
        if (openQ >= 0) {
          int closeQ = s.indexOf('"', openQ + 1);
          if (closeQ > openQ) {
            String val = s.substring(openQ + 1, closeQ);
            val.toLowerCase();
            Serial.print("[LED] desired_state=\"");
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
    
    // Publish current LED state (reverse logic)
    publishLEDStatus(turnOn);
  }
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
      mqttConnected = true;
      if (mqttClient.subscribe(controlTopic, 1)) {
        Serial.print("[MQTT] Subscribed: ");
        Serial.println(controlTopic);
      } else {
        Serial.println("[MQTT] Subscribe failed");
      }
      if (mqttClient.subscribe(relayTopic, 1)) {
        Serial.print("[MQTT] Subscribed: ");
        Serial.println(relayTopic);
      } else {
        Serial.println("[MQTT] Relay subscribe failed");
      }
      if (mqttClient.subscribe(statusRequestTopic, 1)) {
        Serial.print("[MQTT] Subscribed: ");
        Serial.println(statusRequestTopic);
      } else {
        Serial.println("[MQTT] Status request subscribe failed");
      }
    } else {
      Serial.print("[MQTT] Connect failed, state=");
      Serial.println(mqttClient.state());
      mqttConnected = false;
      // Update status LED during connection attempts
      updateStatusLED();
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
  
  // Setup RGB LED pins
  pinMode(RGB_RED_PIN, OUTPUT);
  pinMode(RGB_GREEN_PIN, OUTPUT);
  pinMode(RGB_BLUE_PIN, OUTPUT);
  setRGBColor(0, 0, 0); // Start with all LEDs OFF
  
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, LOW); // Start with relay OFF

  snprintf(controlTopic, sizeof(controlTopic), "farm/%s/control/light", DEVICE_ID);
  Serial.print("[Topic] Control: "); Serial.println(controlTopic);
  snprintf(relayTopic, sizeof(relayTopic), "farm/%s/control/relay", DEVICE_ID);
  Serial.print("[Topic] Relay: "); Serial.println(relayTopic);
  snprintf(statusTopic, sizeof(statusTopic), "farm/%s/status", DEVICE_ID);
  Serial.print("[Topic] Status: "); Serial.println(statusTopic);
  snprintf(statusRequestTopic, sizeof(statusRequestTopic), "farm/%s/status/request", DEVICE_ID);
  Serial.print("[Topic] Status Request: "); Serial.println(statusRequestTopic);
  snprintf(tempTopic, sizeof(tempTopic), "farm/%s/sensor/temperature", DEVICE_ID);
  Serial.print("[Topic] Temperature: "); Serial.println(tempTopic);
  snprintf(humTopic, sizeof(humTopic), "farm/%s/sensor/humidity", DEVICE_ID);
  Serial.print("[Topic] Humidity: "); Serial.println(humTopic);
  snprintf(waterflowTopic, sizeof(waterflowTopic), "farm/%s/sensor/waterflow", DEVICE_ID);
  Serial.print("[Topic] Waterflow: "); Serial.println(waterflowTopic);
  snprintf(tdsTopic, sizeof(tdsTopic), "farm/%s/sensor/tds", DEVICE_ID);
  Serial.print("[Topic] TDS: "); Serial.println(tdsTopic);

  // Setup water flow sensor
  pinMode(WATERFLOW_PIN, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(WATERFLOW_PIN), flowPulse, RISING);

  connectWiFi();
  mqttClient.setServer(MQTT_HOST, MQTT_PORT);
  mqttClient.setCallback(handleControlMessage);
  
  // Publish initial status
  delay(1000);
  publishRelayStatus(false); // Start with relay OFF
  publishLEDStatus(true);    // Start with LED OFF (but send "on" because LED_ACTIVE_LOW makes it OFF)
}

void loop() {
  // Check WiFi status
  if (WiFi.status() != WL_CONNECTED) {
    wifiConnected = false;
    connectWiFi();
  } else {
    wifiConnected = true;
  }
  
  // Check MQTT status
  if (!mqttClient.connected()) {
    mqttConnected = false;
    ensureMqttConnected();
  } else {
    mqttConnected = true;
  }
  
  mqttClient.loop();
  
  // Update status LED
  updateStatusLED();
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
    
    // TDS reading
    float tdsValue = readTDS();
    Serial.print("[TDS] Raw reading: "); Serial.println(tdsValue);
    if (tdsValue > 0) {
      String quality = getTDSQuality(tdsValue);
      char payloadTDS[128];
      int n4 = snprintf(payloadTDS, sizeof(payloadTDS), 
                       "{\"ppm\":%.2f,\"quality\":\"%s\"}", 
                       tdsValue, quality.c_str());
      if (n4 > 0 && n4 < (int)sizeof(payloadTDS)) {
        bool ok4 = mqttClient.publish(tdsTopic, payloadTDS, false);
        Serial.print("[PUB] TDS -> "); Serial.print(tdsTopic);
        Serial.print(" | "); Serial.println(ok4 ? payloadTDS : "publish failed");
        Serial.print("[TDS] Quality: "); Serial.print(quality);
        Serial.print(" | PPM: "); Serial.println(tdsValue);
      }
    } else {
      Serial.println("[TDS] No reading available yet (still sampling)");
    }
  }
  delay(10);
}
