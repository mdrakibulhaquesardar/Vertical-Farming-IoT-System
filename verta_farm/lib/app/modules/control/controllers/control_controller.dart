import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../modules/dashboard/controllers/dashboard_controller.dart';

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

  // Live status indicators - will get real data from dashboard controller
  var temperature = 0.0.obs;
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
    _syncWithDashboardData();
  }

  void _syncWithDashboardData() {
    // Get dashboard controller instance
    try {
      final dashboardController = Get.find<DashboardController>();

      // Sync real data from dashboard
      ever(dashboardController.temperature, (value) {
        temperature.value = value;
      });

      ever(dashboardController.waterLevel, (value) {
        if (value < 30) {
          moisture.value = 'Low';
        } else if (value < 70) {
          moisture.value = 'Medium';
        } else {
          moisture.value = 'High';
        }
      });

      ever(dashboardController.diseaseDetected, (value) {
        diseaseStatus.value = value ? 'Detected' : 'None';
      });

      ever(dashboardController.pumpStatus, (value) {
        pumpStatus.value = value;
      });

      ever(dashboardController.growLightStatus, (value) {
        lightStatus.value = value;
      });

      // Initialize with current values
      temperature.value = dashboardController.temperature.value;
      final waterLevel = dashboardController.waterLevel.value;
      if (waterLevel < 30) {
        moisture.value = 'Low';
      } else if (waterLevel < 70) {
        moisture.value = 'Medium';
      } else {
        moisture.value = 'High';
      }
      diseaseStatus.value = dashboardController.diseaseDetected.value
          ? 'Detected'
          : 'None';
      pumpStatus.value = dashboardController.pumpStatus.value;
      lightStatus.value = dashboardController.growLightStatus.value;
    } catch (e) {
      print('Dashboard controller not found, using default values: $e');
    }
  }

  void startStatusUpdates() {
    // Real data is now synced from dashboard controller
    // No need for simulated updates
  }

  // Pump Control Methods
  void togglePump() {
    try {
      final dashboardController = Get.find<DashboardController>();
      dashboardController.togglePump();
      updateIcons();
    } catch (e) {
      print('Dashboard controller not found: $e');
      pumpStatus.value = !pumpStatus.value;
      updateIcons();
    }
  }

  void setFlowRate(double value) {
    flowRate.value = value;
    if (pumpStatus.value && value == 0) {
      Fluttertoast.showToast(
        msg: 'Warning: Flow rate is 0% but pump is ON',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
    }
  }

  void setPumpMode(String mode) {
    pumpMode.value = mode;
    Fluttertoast.showToast(
      msg: 'Pump Mode: Switched to $mode mode',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }

  void startManualWatering() {
    if (isManualWatering.value) return;

    isManualWatering.value = true;
    pumpStatus.value = true;

    Fluttertoast.showToast(
      msg: 'Manual Watering: Started for ${manualWateringTime.value} seconds',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );

    Future.delayed(Duration(seconds: manualWateringTime.value), () {
      isManualWatering.value = false;
      if (pumpMode.value == 'Manual') {
        pumpStatus.value = false;
      }
      Fluttertoast.showToast(
        msg: 'Manual Watering: Completed',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    });
  }

  void setManualWateringTime(int seconds) {
    manualWateringTime.value = seconds;
  }

  // Light Control Methods
  void toggleLight() {
    try {
      final dashboardController = Get.find<DashboardController>();
      dashboardController.toggleGrowLight();
      updateIcons();
    } catch (e) {
      print('Dashboard controller not found: $e');
      lightStatus.value = !lightStatus.value;
      updateIcons();
    }
  }

  void setLightMode(String mode) {
    lightMode.value = mode;
    Fluttertoast.showToast(
      msg: 'Light Mode: Switched to $mode mode',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
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
    Fluttertoast.showToast(
      msg: fanStatus.value
          ? 'Fan Status: Ventilation fan turned ON'
          : 'Fan Status: Ventilation fan turned OFF',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: fanStatus.value ? Colors.green : Colors.grey,
      textColor: Colors.white,
    );
  }

  void setFanMode(String mode) {
    fanMode.value = mode;
    Fluttertoast.showToast(
      msg: 'Fan Mode: Switched to $mode mode',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }

  void setFanSpeed(String speed) {
    fanSpeed.value = speed;
    Fluttertoast.showToast(
      msg: 'Fan Speed: Speed set to $speed',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
    );
  }

  // Auto Mode Configuration
  void toggleAutoMode() {
    autoMode.value = !autoMode.value;
    updateIcons();
    Fluttertoast.showToast(
      msg: autoMode.value
          ? 'Auto Mode: Automatic control enabled'
          : 'Auto Mode: Manual control enabled',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: autoMode.value ? Colors.green : Colors.orange,
      textColor: Colors.white,
    );
  }

  void toggleAutoWatering() {
    autoWatering.value = !autoWatering.value;
    Fluttertoast.showToast(
      msg: autoWatering.value
          ? 'Auto Watering: Enabled'
          : 'Auto Watering: Disabled',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: autoWatering.value ? Colors.green : Colors.grey,
      textColor: Colors.white,
    );
  }

  void toggleAutoLighting() {
    autoLighting.value = !autoLighting.value;
    Fluttertoast.showToast(
      msg: autoLighting.value
          ? 'Auto Lighting: Enabled'
          : 'Auto Lighting: Disabled',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: autoLighting.value ? Colors.green : Colors.grey,
      textColor: Colors.white,
    );
  }

  void toggleSmartMode() {
    smartMode.value = !smartMode.value;
    Fluttertoast.showToast(
      msg: smartMode.value
          ? 'Smart Mode: AI optimization enabled'
          : 'Smart Mode: AI optimization disabled',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: smartMode.value ? Colors.green : Colors.grey,
      textColor: Colors.white,
    );
  }

  // Schedule Settings
  void toggleSchedule() {
    scheduleEnabled.value = !scheduleEnabled.value;
    Fluttertoast.showToast(
      msg: scheduleEnabled.value ? 'Schedule: Enabled' : 'Schedule: Disabled',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: scheduleEnabled.value ? Colors.green : Colors.grey,
      textColor: Colors.white,
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

  void updateIcons() {
    pumpIcon.value = pumpStatus.value ? '💧' : '💧';
    lightIcon.value = lightStatus.value ? '💡' : '💡';
    fanIcon.value = fanStatus.value ? '🌪️' : '🌪️';
    autoIcon.value = autoMode.value ? '🤖' : '👤';
  }
}
