import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphsController extends GetxController {
  var selectedPeriod = '7 Days'.obs;
  var periods = ['7 Days', '30 Days'];

  // Sample sensor data for charts
  var temperatureData = <double>[].obs;
  var humidityData = <double>[].obs;
  var lightData = <double>[].obs;
  var moistureData = <double>[].obs;
  var timeLabels = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    generateSampleData();
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    generateSampleData();
  }

  void generateSampleData() {
    final days = selectedPeriod.value == '7 Days' ? 7 : 30;
    final dataPoints = days * 24; // 24 data points per day

    temperatureData.clear();
    humidityData.clear();
    lightData.clear();
    moistureData.clear();
    timeLabels.clear();

    for (int i = 0; i < dataPoints; i++) {
      // Generate realistic sensor data with some variation
      final baseTemp = 24.0;
      final baseHumidity = 65.0;
      final baseLight = 800.0;
      final baseMoisture = 70.0;

      // Add some realistic variation based on time of day
      final hour = i % 24;
      final dayVariation = (i / 24).floor() * 0.5;

      // Temperature variation (cooler at night, warmer during day)
      final tempVariation = hour < 6 || hour > 20 ? -3.0 : 3.0;
      temperatureData.add(
        baseTemp + tempVariation + dayVariation + (i % 5 - 2.5),
      );

      // Humidity variation (higher at night)
      final humidityVariation = hour < 6 || hour > 20 ? 10.0 : -5.0;
      humidityData.add(baseHumidity + humidityVariation + (i % 8 - 4));

      // Light variation (lower at night, higher during day)
      final lightVariation = hour < 6 || hour > 20 ? -400.0 : 200.0;
      lightData.add(baseLight + lightVariation + (i % 100 - 50));

      // Moisture variation (gradual decrease, periodic increase)
      final moistureVariation = (i % 48 == 0) ? 20.0 : -0.5;
      moistureData.add(
        (baseMoisture + moistureVariation + (i % 10 - 5)).clamp(30.0, 100.0),
      );

      // Time labels (show every 6 hours)
      if (i % 6 == 0) {
        final day = (i / 24).floor() + 1;
        final hour = i % 24;
        timeLabels.add('D${day} ${hour.toString().padLeft(2, '0')}:00');
      } else {
        timeLabels.add('');
      }
    }
  }

  List<FlSpot> getTemperatureSpots() {
    return temperatureData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();
  }

  List<FlSpot> getHumiditySpots() {
    return humidityData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();
  }

  List<FlSpot> getLightSpots() {
    return lightData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();
  }

  List<FlSpot> getMoistureSpots() {
    return moistureData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();
  }
}
