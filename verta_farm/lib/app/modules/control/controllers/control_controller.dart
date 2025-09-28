import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ControlController extends GetxController {
  // Device control states
  var pumpStatus = false.obs;
  var lightStatus = false.obs;
  var fanStatus = false.obs;
  var autoMode = true.obs;

  // Pump control
  var flowRate = 60.0.obs; // 0-100%
  var pumpMode = 'Auto'.obs; // Auto, Manual
  var isManualWatering = false.obs;
  var manualWateringTime = 30.obs; // seconds

  // Light control
  var lightMode = 'Auto'.obs; // Auto, Manual
  var lightDuration = 12.obs; // hours per day
  var lightSchedule = {'start': '06:00', 'end': '18:00'}.obs;

  // Fan control
  var fanMode = 'Auto'.obs; // Auto, Manual
  var fanSpeed = 'Medium'.obs; // Low, Medium, High

  // Auto mode configuration
  var autoWatering = true.obs;
  var autoLighting = true.obs;
  var smartMode = false.obs;

  // Schedule settings
  var scheduleEnabled = false.obs;
  var wateringSchedule = ['09:00', '16:00'].obs;

  // Live status indicators
  var temperature = 27.0.obs;
  var moisture = 'Low'.obs;
  var diseaseStatus = 'None'.obs;

  // Device status indicators
  var pumpIcon = '💧'.obs;
  var lightIcon = '💡'.obs;
  var fanIcon = '🌪️'.obs;
  var autoIcon = '🤖'.obs;

  @override
  void onInit() {
    super.onInit();
    updateIcons();
    startStatusUpdates();
  }

  void startStatusUpdates() {
    // Simulate real-time status updates
    Future.delayed(const Duration(seconds: 3), () {
      temperature.value = 25.0 + (DateTime.now().millisecond % 10);
      moisture.value = [
        'Low',
        'Medium',
        'High',
      ][DateTime.now().millisecond % 3];
      startStatusUpdates();
    });
  }

  // Pump Control Methods
  void togglePump() {
    pumpStatus.value = !pumpStatus.value;
    updateIcons();
    showStatusSnackbar(
      'Pump Status',
      pumpStatus.value ? 'Water pump turned ON' : 'Water pump turned OFF',
      pumpStatus.value ? Colors.green : Colors.grey,
    );
  }

  void setFlowRate(double value) {
    flowRate.value = value;
    if (pumpStatus.value && value == 0) {
      Get.snackbar(
        'Warning',
        'Flow rate is 0% but pump is ON',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  void setPumpMode(String mode) {
    pumpMode.value = mode;
    showStatusSnackbar('Pump Mode', 'Switched to $mode mode', Colors.blue);
  }

  void startManualWatering() {
    if (isManualWatering.value) return;

    isManualWatering.value = true;
    pumpStatus.value = true;

    showStatusSnackbar(
      'Manual Watering',
      'Started watering for ${manualWateringTime.value} seconds',
      Colors.blue,
    );

    Future.delayed(Duration(seconds: manualWateringTime.value), () {
      isManualWatering.value = false;
      if (pumpMode.value == 'Manual') {
        pumpStatus.value = false;
      }
      showStatusSnackbar('Manual Watering', 'Watering completed', Colors.green);
    });
  }

  void setManualWateringTime(int seconds) {
    manualWateringTime.value = seconds;
  }

  // Light Control Methods
  void toggleLight() {
    lightStatus.value = !lightStatus.value;
    updateIcons();
    showStatusSnackbar(
      'Light Status',
      lightStatus.value ? 'Grow lights turned ON' : 'Grow lights turned OFF',
      lightStatus.value ? Colors.green : Colors.grey,
    );
  }

  void setLightMode(String mode) {
    lightMode.value = mode;
    showStatusSnackbar('Light Mode', 'Switched to $mode mode', Colors.blue);
  }

  void setLightDuration(int hours) {
    lightDuration.value = hours;
  }

  void setLightSchedule(String start, String end) {
    lightSchedule.value = {'start': start, 'end': end};
  }

  // Fan Control Methods
  void toggleFan() {
    fanStatus.value = !fanStatus.value;
    updateIcons();
    showStatusSnackbar(
      'Fan Status',
      fanStatus.value
          ? 'Ventilation fan turned ON'
          : 'Ventilation fan turned OFF',
      fanStatus.value ? Colors.green : Colors.grey,
    );
  }

  void setFanMode(String mode) {
    fanMode.value = mode;
    showStatusSnackbar('Fan Mode', 'Switched to $mode mode', Colors.blue);
  }

  void setFanSpeed(String speed) {
    fanSpeed.value = speed;
    showStatusSnackbar('Fan Speed', 'Speed set to $speed', Colors.blue);
  }

  // Auto Mode Configuration
  void toggleAutoMode() {
    autoMode.value = !autoMode.value;
    updateIcons();
    showStatusSnackbar(
      'Auto Mode',
      autoMode.value ? 'Automatic control enabled' : 'Manual control enabled',
      autoMode.value ? Colors.green : Colors.orange,
    );
  }

  void toggleAutoWatering() {
    autoWatering.value = !autoWatering.value;
    showStatusSnackbar(
      'Auto Watering',
      autoWatering.value ? 'Auto watering enabled' : 'Auto watering disabled',
      autoWatering.value ? Colors.green : Colors.grey,
    );
  }

  void toggleAutoLighting() {
    autoLighting.value = !autoLighting.value;
    showStatusSnackbar(
      'Auto Lighting',
      autoLighting.value ? 'Auto lighting enabled' : 'Auto lighting disabled',
      autoLighting.value ? Colors.green : Colors.grey,
    );
  }

  void toggleSmartMode() {
    smartMode.value = !smartMode.value;
    showStatusSnackbar(
      'Smart Mode',
      smartMode.value ? 'AI optimization enabled' : 'AI optimization disabled',
      smartMode.value ? Colors.green : Colors.grey,
    );
  }

  // Schedule Settings
  void toggleSchedule() {
    scheduleEnabled.value = !scheduleEnabled.value;
    showStatusSnackbar(
      'Schedule',
      scheduleEnabled.value ? 'Schedule enabled' : 'Schedule disabled',
      scheduleEnabled.value ? Colors.green : Colors.grey,
    );
  }

  void addWateringTime(String time) {
    if (!wateringSchedule.contains(time)) {
      wateringSchedule.add(time);
      wateringSchedule.sort();
    }
  }

  void removeWateringTime(String time) {
    wateringSchedule.remove(time);
  }

  // Utility Methods
  void showStatusSnackbar(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void updateIcons() {
    pumpIcon.value = pumpStatus.value ? '💧' : '💧';
    lightIcon.value = lightStatus.value ? '💡' : '💡';
    fanIcon.value = fanStatus.value ? '🌪️' : '🌪️';
    autoIcon.value = autoMode.value ? '🤖' : '👤';
  }

  // Status getters
  String get pumpStatusText => pumpStatus.value ? 'Running' : 'Stopped';
  String get lightStatusText => lightStatus.value ? 'ON' : 'OFF';
  String get fanStatusText => fanStatus.value ? 'Running' : 'Stopped';

  Color get pumpStatusColor => pumpStatus.value ? Colors.green : Colors.grey;
  Color get lightStatusColor => lightStatus.value ? Colors.green : Colors.grey;
  Color get fanStatusColor => fanStatus.value ? Colors.green : Colors.grey;
}
