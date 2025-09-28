import 'package:get/get.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../services/websocket_service.dart';
import '../../../services/thresholds_service.dart';
import '../../../services/control_service.dart';

class DashboardController extends GetxController {
  // Real-time sensor data
  var temperature = 0.00.obs;
  var humidity = 0.00.obs;
  var lightLevel = 0.00.obs;
  var waterLevel = 0.00.obs;
  var phLevel = 0.00.obs;
  var ecLevel = 0.00.obs;
  var waterFlow = 0.0.obs;
  var totalLiters = 0.0.obs;
  var avgLitersPerMin = 0.0.obs;
  var pulses = 0.obs;
  var tdsLevel = 0.0.obs;

  // System status
  var pumpStatus = true.obs; // true = ON, false = OFF
  var growLightStatus = true.obs;
  var motorStatus = false.obs; // true = ON, false = OFF
  var ventilationStatus = 'Auto'.obs; // Auto, Manual, Off
  var lastWateredTime = DateTime.now().subtract(Duration(hours: 2)).obs;
  var growLightDuration = Duration(hours: 8).obs;

  // Plant health status
  var plantHealth = 'Healthy'.obs;
  var healthIcon = '🌱'.obs;
  var healthStatus = 'OK'.obs; // OK, Warning, Critical
  var healthColor = 0xFF4CAF50.obs; // Green for OK
  var aiSummary = 'All plants look healthy'.obs;
  var diseaseDetected = false.obs;

  // Historical data for mini graphs (last 5 hours)
  var temperatureHistory = <double>[].obs;
  var humidityHistory = <double>[].obs;
  var moistureHistory = <double>[].obs;
  var waterFlowHistory = <double>[].obs;

  // WebSocket service
  late WebSocketService _webSocketService;

  // Thresholds service
  late ThresholdsService _thresholdsService;

  // Control service
  late ControlService _controlService;

  // Device status
  var isDeviceOnline = false.obs;
  var deviceStatus = 'Device Offline'.obs;
  var lastDeviceActivity = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize historical data
    _initializeHistoricalData();

    // Initialize WebSocket service
    _initializeWebSocket();

    // Initialize Thresholds service
    _initializeThresholds();

    // Initialize Control service
    _initializeControl();

    // Simulate real-time data updates
    ever(temperature, (value) => updateHealthStatus());
    ever(humidity, (value) => updateHealthStatus());
    ever(lightLevel, (value) => updateHealthStatus());
    ever(waterLevel, (value) => updateHealthStatus());
    ever(phLevel, (value) => updateHealthStatus());
    ever(ecLevel, (value) => updateHealthStatus());

    // Start periodic updates (simulate IoT data) - fallback if WebSocket fails
    startDataUpdates();

    // Start device timeout check
    startDeviceTimeoutCheck();

    // Start initial device status check after a delay
    _startInitialDeviceCheck();
  }

  void _initializeHistoricalData() {
    // Generate some initial historical data
    final random = Random();
    for (int i = 0; i < 5; i++) {
      temperatureHistory.add(24.0 + random.nextDouble() * 4);
      humidityHistory.add(55.0 + random.nextDouble() * 20);
      moistureHistory.add(60.0 + random.nextDouble() * 30);
      waterFlowHistory.add(random.nextDouble() * 5.0);
    }
  }

  void _initializeWebSocket() {
    // Initialize WebSocket service
    Get.put(WebSocketService());
    _webSocketService = WebSocketService.to;

    // Set up WebSocket callbacks
    _webSocketService.onDataReceived = (data) {
      _handleWebSocketData(data);
    };

    _webSocketService.onError = (error) {
      Fluttertoast.showToast(
        msg: 'WebSocket Error: $error',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    };

    _webSocketService.onConnected = () {
      Fluttertoast.showToast(
        msg: 'Connected - Real-time data connection established',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      // Request current status from ESP32 after connection
      requestCurrentStatus();
    };

    _webSocketService.onDisconnected = () {
      Fluttertoast.showToast(
        msg: 'Disconnected - Real-time data connection lost',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

      // Mark device as offline when WebSocket disconnects
      isDeviceOnline.value = false;
      deviceStatus.value = 'Device Offline';
      print('Device marked offline due to WebSocket disconnect');
    };
  }

  void _initializeThresholds() {
    // Initialize Thresholds service
    Get.put(ThresholdsService());
    _thresholdsService = ThresholdsService.to;

    // Listen for thresholds changes
    ever(_thresholdsService.currentThresholds, (thresholds) {
      print('Thresholds updated: $thresholds');
      // Recalculate health status when thresholds change
      updateHealthStatus();
    });
  }

  void _initializeControl() {
    // Initialize Control service
    Get.put(ControlService());
    _controlService = ControlService.to;
  }

  void requestCurrentStatus() {
    // Request current status from ESP32 by sending a status request
    // This will trigger ESP32 to publish its current relay state
    print('Requesting current status from ESP32...');

    // Send a status request via MQTT (this will be handled by backend)
    _controlService.requestStatus('esp32-001').then((success) {
      if (success) {
        print('Status request sent successfully');
      } else {
        print('Failed to send status request');
      }
    });
  }

  void _updateDeviceStatus() {
    lastDeviceActivity.value = DateTime.now();
    // Only update to online if WebSocket is connected
    if (!isDeviceOnline.value && _webSocketService.isConnected.value) {
      isDeviceOnline.value = true;
      deviceStatus.value = 'Device Online';
      print('Device came online');
    }
  }

  void _checkDeviceTimeout() {
    final now = DateTime.now();
    final timeSinceLastActivity = now.difference(lastDeviceActivity.value);

    // Check if WebSocket is disconnected
    if (!_webSocketService.isConnected.value) {
      if (isDeviceOnline.value) {
        isDeviceOnline.value = false;
        deviceStatus.value = 'Device Offline';
        print('Device marked offline - WebSocket disconnected');
      }
      return;
    }

    if (timeSinceLastActivity.inSeconds > 30) {
      // 30 seconds timeout
      if (isDeviceOnline.value) {
        isDeviceOnline.value = false;
        deviceStatus.value = 'Device Offline';
        print(
          'Device went offline - no activity for ${timeSinceLastActivity.inSeconds}s',
        );
      }
    }
  }

  void _handleWebSocketData(Map<String, dynamic> data) {
    try {
      print('Processing WebSocket data: $data');

      // Update device activity
      _updateDeviceStatus();

      // Handle status messages (relay and light state)
      if (data.containsKey('type') && data['type'] == 'status') {
        final statusData = data['data'] as Map<String, dynamic>;

        // Handle relay status
        if (statusData.containsKey('relay')) {
          final relayData = statusData['relay'] as Map<String, dynamic>;
          if (relayData.containsKey('state')) {
            final relayState = relayData['state'] as String;
            pumpStatus.value = relayState == 'on';
            print('Updated pump status from ESP32: $relayState');
          }
        }

        // Handle light status (reverse logic for LED_ACTIVE_LOW)
        if (statusData.containsKey('light')) {
          final lightData = statusData['light'] as Map<String, dynamic>;
          if (lightData.containsKey('state')) {
            final lightState = lightData['state'] as String;
            // ESP32 sends "on" when LED pin is LOW (LED actually ON due to LED_ACTIVE_LOW)
            // ESP32 sends "off" when LED pin is HIGH (LED actually OFF due to LED_ACTIVE_LOW)
            // So we reverse: "on" means app button should be OFF, "off" means app button should be ON
            growLightStatus.value = lightState == 'off';
            print(
              'Updated grow light status from ESP32: $lightState (app button: ${lightState == 'off'})',
            );
          }
        }
        return;
      }

      // Handle the new data structure from ESP32
      // Data format: {device_id: esp32-001, sensor_id: esp32-001-temperature, type: temperature, ts: 2025-09-26T18:29:56, value_numeric: 50.5, value_text: null}

      if (data.containsKey('type') && data.containsKey('value_numeric')) {
        // Update device activity for sensor data
        _updateDeviceStatus();

        final sensorType = data['type'] as String;
        final value = (data['value_numeric'] as num).toDouble();

        print('Updating $sensorType with value: $value');

        switch (sensorType.toLowerCase()) {
          case 'temperature':
            temperature.value = value;
            break;
          case 'humidity':
            humidity.value = value;
            break;
          case 'light':
          case 'light_level':
            lightLevel.value = value;
            break;
          case 'water':
          case 'water_level':
          case 'moisture':
            waterLevel.value = value;
            break;
          case 'ph':
          case 'ph_level':
            phLevel.value = value;
            break;
          case 'ec':
          case 'ec_level':
            ecLevel.value = value;
            break;
          case 'waterflow':
            waterFlow.value = value;
            // Also update additional waterflow data if available
            if (data.containsKey('total_liters')) {
              totalLiters.value = (data['total_liters'] as num).toDouble();
            }
            if (data.containsKey('avg_l_per_min')) {
              avgLitersPerMin.value = (data['avg_l_per_min'] as num).toDouble();
            }
            if (data.containsKey('pulses')) {
              pulses.value = data['pulses'] as int;
            }
            break;
          case 'tds':
            tdsLevel.value = value;
            break;
          default:
            print('Unknown sensor type: $sensorType');
        }

        // Update historical data
        _updateHistoricalData();
      } else {
        // Fallback to old data structure for backward compatibility
        if (data.containsKey('temperature') || data.containsKey('temp')) {
          temperature.value = (data['temperature'] ?? data['temp'] as num)
              .toDouble();
        }
        if (data.containsKey('humidity') || data.containsKey('hum')) {
          humidity.value = (data['humidity'] ?? data['hum'] as num).toDouble();
        }
        if (data.containsKey('light_level') || data.containsKey('light')) {
          lightLevel.value = (data['light_level'] ?? data['light'] as num)
              .toDouble();
        }
        if (data.containsKey('water_level') ||
            data.containsKey('water') ||
            data.containsKey('moisture')) {
          waterLevel.value =
              (data['water_level'] ?? data['water'] ?? data['moisture'] as num)
                  .toDouble();
        }
        if (data.containsKey('ph_level') || data.containsKey('ph')) {
          phLevel.value = (data['ph_level'] ?? data['ph'] as num).toDouble();
        }
        if (data.containsKey('ec_level') || data.containsKey('ec')) {
          ecLevel.value = (data['ec_level'] ?? data['ec'] as num).toDouble();
        }

        // Update historical data
        _updateHistoricalData();
      }
    } catch (e) {
      print('Error handling WebSocket data: $e');
    }
  }

  void _updateHistoricalData() {
    // Update historical data (shift and add new values)
    if (temperatureHistory.length >= 5) {
      temperatureHistory.removeAt(0);
    }
    temperatureHistory.add(temperature.value);

    if (humidityHistory.length >= 5) {
      humidityHistory.removeAt(0);
    }
    humidityHistory.add(humidity.value);

    if (moistureHistory.length >= 5) {
      moistureHistory.removeAt(0);
    }
    moistureHistory.add(waterLevel.value);

    if (waterFlowHistory.length >= 5) {
      waterFlowHistory.removeAt(0);
    }
    waterFlowHistory.add(waterFlow.value);
  }

  void updateHealthStatus() {
    // Enhanced logic to determine plant health using dynamic thresholds
    bool tempOk = _thresholdsService.isTemperatureOk(temperature.value);
    bool humidityOk = _thresholdsService.isHumidityOk(humidity.value);
    bool lightOk = _thresholdsService.isLightOk(lightLevel.value);
    bool waterOk = _thresholdsService.isWaterOk(waterLevel.value);
    bool phOk = _thresholdsService.isPhOk(phLevel.value);
    bool ecOk = _thresholdsService.isEcOk(ecLevel.value);

    // Debug logging
    print('Health Status Check:');
    print(
      'Temperature: ${temperature.value}°C (${tempOk ? 'OK' : 'OUT OF RANGE'}) - Range: ${_thresholdsService.getTemperatureMin()}-${_thresholdsService.getTemperatureMax()}°C',
    );
    print(
      'Humidity: ${humidity.value}% (${humidityOk ? 'OK' : 'OUT OF RANGE'}) - Range: ${_thresholdsService.getHumidityMin()}-${_thresholdsService.getHumidityMax()}%',
    );
    print(
      'Light: ${lightLevel.value} (${lightOk ? 'OK' : 'OUT OF RANGE'}) - Range: ${_thresholdsService.getLightMin()}-${_thresholdsService.getLightMax()}',
    );
    print(
      'Water: ${waterLevel.value}% (${waterOk ? 'OK' : 'OUT OF RANGE'}) - Range: ${_thresholdsService.getWaterMin()}-${_thresholdsService.getWaterMax()}%',
    );
    print(
      'pH: ${phLevel.value} (${phOk ? 'OK' : 'OUT OF RANGE'}) - Range: ${_thresholdsService.getPhMin()}-${_thresholdsService.getPhMax()}',
    );
    print(
      'EC: ${ecLevel.value} (${ecOk ? 'OK' : 'OUT OF RANGE'}) - Range: ${_thresholdsService.getEcMin()}-${_thresholdsService.getEcMax()}',
    );

    int okCount = [
      tempOk,
      humidityOk,
      lightOk,
      waterOk,
      phOk,
      ecOk,
    ].where((condition) => condition).length;

    if (okCount >= 5) {
      plantHealth.value = 'Healthy';
      healthIcon.value = '🌱';
      healthStatus.value = 'OK';
      healthColor.value = 0xFF4CAF50; // Green
      aiSummary.value = 'All plants look healthy';
      diseaseDetected.value = false;
    } else if (okCount >= 3) {
      plantHealth.value = 'Warning';
      healthIcon.value = '⚠️';
      healthStatus.value = 'Warning';
      healthColor.value = 0xFFFF9800; // Orange
      aiSummary.value = 'Some parameters need attention';
      diseaseDetected.value = false;
    } else {
      plantHealth.value = 'Critical';
      healthIcon.value = '🥀';
      healthStatus.value = 'Critical';
      healthColor.value = 0xFFF44336; // Red
      aiSummary.value = 'Leaf disease detected in 1 plant';
      diseaseDetected.value = true;
    }
  }

  void startDataUpdates() {
    // Simulate IoT sensor data updates every 30 seconds (fallback when WebSocket is not connected)
    Future.delayed(const Duration(seconds: 30), () {
      // Only update if WebSocket is not connected
      if (!_webSocketService.isConnected.value) {
        final random = Random();

        // Update current sensor values
        temperature.value = 24.0 + random.nextDouble() * 4;
        humidity.value = 55.0 + random.nextDouble() * 20;
        lightLevel.value = 600 + random.nextDouble() * 500;
        waterLevel.value = 60 + random.nextDouble() * 30;
        phLevel.value = 6.5 + random.nextDouble() * 1.0;
        ecLevel.value = 1.0 + random.nextDouble() * 1.0;

        // Update historical data
        _updateHistoricalData();
      }

      startDataUpdates(); // Continue updates
    });
  }

  void startDeviceTimeoutCheck() {
    Timer.periodic(Duration(seconds: 10), (timer) {
      _checkDeviceTimeout();
    });
  }

  void _startInitialDeviceCheck() {
    // Wait 5 seconds for WebSocket to connect, then check device status
    Future.delayed(Duration(seconds: 5), () {
      if (!_webSocketService.isConnected.value) {
        // WebSocket not connected, mark device as offline
        isDeviceOnline.value = false;
        deviceStatus.value = 'Device Offline';
        print('Initial check: WebSocket not connected, device marked offline');
      } else {
        // WebSocket connected, request device status
        requestCurrentStatus();
        print('Initial check: WebSocket connected, requesting device status');

        // If no response from device within 10 seconds, mark as offline
        Future.delayed(Duration(seconds: 10), () {
          if (!isDeviceOnline.value) {
            isDeviceOnline.value = false;
            deviceStatus.value = 'Device Offline';
            print('Initial check: No device response, marked as offline');
          }
        });
      }
    });
  }

  void reconnectWebSocket() {
    print('Attempting to reconnect WebSocket...');
    _webSocketService.connect();
  }

  // System control methods
  void togglePump() async {
    final newStatus = !pumpStatus.value;
    final success = await _controlService.controlPump('esp32-001', newStatus);

    if (success) {
      pumpStatus.value = newStatus;
      if (pumpStatus.value) {
        lastWateredTime.value = DateTime.now();
      }
    }
  }

  void toggleGrowLight() async {
    final newStatus = !growLightStatus.value;
    // Reverse the control command for LED_ACTIVE_LOW logic
    // App button ON means ESP32 should turn LED OFF (send false)
    // App button OFF means ESP32 should turn LED ON (send true)
    final esp32Command = !newStatus;
    final success = await _controlService.controlLight(
      'esp32-001',
      esp32Command,
    );

    if (success) {
      growLightStatus.value = newStatus;
    }
  }

  void toggleMotor() async {
    final newStatus = !motorStatus.value;
    final success = await _controlService.controlMotor('esp32-001', newStatus);

    if (success) {
      motorStatus.value = newStatus;
    }
  }

  void setVentilationStatus(String status) {
    ventilationStatus.value = status;
  }

  void scanNow() {
    // Simulate AI scan
    Fluttertoast.showToast(
      msg: 'Scanning... AI is analyzing plant health...',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );

    Future.delayed(Duration(seconds: 2), () {
      updateHealthStatus();
      Fluttertoast.showToast(
        msg: 'Scan Complete: ${aiSummary.value}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    });
  }

  String getLightLevelText() {
    if (lightLevel.value < 300) return 'Low';
    if (lightLevel.value < 700) return 'Medium';
    return 'High';
  }

  String getWaterLevelText() {
    if (waterLevel.value < 30) return 'Low';
    if (waterLevel.value < 70) return 'Medium';
    return 'High';
  }

  String getWaterFlowText() {
    if (waterFlow.value == 0) return 'No Flow';
    if (waterFlow.value < 1.0) return 'Low Flow';
    if (waterFlow.value < 5.0) return 'Medium Flow';
    return 'High Flow';
  }

  String getTimeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void disconnectWebSocket() {
    _webSocketService.disconnect();
  }

  bool get isWebSocketConnected => _webSocketService.isConnected.value;
  String get connectionStatus => _webSocketService.connectionStatus.value;

  // Thresholds control methods
  Future<void> refreshThresholds() async {
    await _thresholdsService.refreshThresholds('esp32-001');
  }

  bool get isThresholdsLoading => _thresholdsService.isLoading.value;
  DateTime get lastThresholdsUpdate => _thresholdsService.lastFetchTime.value;

  // Get current threshold values for display
  double get temperatureMin => _thresholdsService.getTemperatureMin();
  double get temperatureMax => _thresholdsService.getTemperatureMax();
  double get humidityMin => _thresholdsService.getHumidityMin();
  double get humidityMax => _thresholdsService.getHumidityMax();
  double get lightMin => _thresholdsService.getLightMin();
  double get lightMax => _thresholdsService.getLightMax();
  double get waterMin => _thresholdsService.getWaterMin();
  double get waterMax => _thresholdsService.getWaterMax();
  double get phMin => _thresholdsService.getPhMin();
  double get phMax => _thresholdsService.getPhMax();
  double get ecMin => _thresholdsService.getEcMin();
  double get ecMax => _thresholdsService.getEcMax();
  double get tdsMin => _thresholdsService.getTdsMin();
  double get tdsMax => _thresholdsService.getTdsMax();

  // Status check methods for sensor cards
  bool get isTemperatureOk =>
      _thresholdsService.isTemperatureOk(temperature.value);
  bool get isHumidityOk => _thresholdsService.isHumidityOk(humidity.value);
  bool get isLightOk => _thresholdsService.isLightOk(lightLevel.value);
  bool get isWaterOk => _thresholdsService.isWaterOk(waterLevel.value);
  bool get isPhOk => _thresholdsService.isPhOk(phLevel.value);
  bool get isEcOk => _thresholdsService.isEcOk(ecLevel.value);
  bool get isTdsOk => _thresholdsService.isTdsOk(tdsLevel.value);

  // Control service status
  bool get isControlling => _controlService.isControlling.value;
  bool get isControllingLight => _controlService.isControllingLight.value;
  bool get isControllingPump => _controlService.isControllingPump.value;
  bool get isControllingMotor => _controlService.isControllingMotor.value;
}
