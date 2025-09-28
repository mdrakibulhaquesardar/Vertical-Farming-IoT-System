import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/thresholds_model.dart';

class ThresholdsService extends GetxService {
  static ThresholdsService get to => Get.find();

  final String baseUrl = 'http://192.168.0.134:8000/api/v1';
  var currentThresholds = ThresholdsModel.getDefaultThresholds('esp32-001').obs;
  var isLoading = false.obs;
  var lastFetchTime = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch thresholds on service initialization
    fetchThresholds('esp32-001');
  }

  Future<ThresholdsModel?> fetchThresholds(String deviceId) async {
    try {
      isLoading.value = true;

      final url = Uri.parse('$baseUrl/thresholds/$deviceId');
      print('Fetching thresholds from: $url');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Thresholds API response: $data');

        // Handle different response formats
        ThresholdsModel thresholds;
        if (data is List && data.isNotEmpty) {
          // Handle new API format: [{sensor_type: temperature, min_value: 40.0, max_value: 50.0}]
          thresholds = _parseThresholdsFromList(data);
        } else if (data is Map<String, dynamic>) {
          // If response is a single object
          thresholds = ThresholdsModel.fromJson(data);
        } else {
          throw Exception('Unexpected response format');
        }

        currentThresholds.value = thresholds;
        lastFetchTime.value = DateTime.now();

        print('Thresholds loaded successfully: $thresholds');
        return thresholds;
      } else {
        print(
          'Failed to fetch thresholds: ${response.statusCode} - ${response.body}',
        );
        // Use default thresholds on API failure
        currentThresholds.value = ThresholdsModel.getDefaultThresholds(
          deviceId,
        );
        return currentThresholds.value;
      }
    } catch (e) {
      print('Error fetching thresholds: $e');
      // Use default thresholds on error
      currentThresholds.value = ThresholdsModel.getDefaultThresholds(deviceId);
      return currentThresholds.value;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshThresholds(String deviceId) async {
    await fetchThresholds(deviceId);
  }

  // Parse thresholds from the new API format
  ThresholdsModel _parseThresholdsFromList(List<dynamic> data) {
    final Map<String, dynamic> thresholdsMap = {'device_id': 'esp32-001'};

    for (var item in data) {
      if (item is Map<String, dynamic>) {
        final sensorType = item['sensor_type'] as String?;
        final minValue = item['min_value'] as num?;
        final maxValue = item['max_value'] as num?;

        if (sensorType != null && minValue != null && maxValue != null) {
          switch (sensorType.toLowerCase()) {
            case 'temperature':
              thresholdsMap['temperature_min'] = minValue.toDouble();
              thresholdsMap['temperature_max'] = maxValue.toDouble();
              break;
            case 'humidity':
              thresholdsMap['humidity_min'] = minValue.toDouble();
              thresholdsMap['humidity_max'] = maxValue.toDouble();
              break;
            case 'light':
            case 'light_level':
              thresholdsMap['light_min'] = minValue.toDouble();
              thresholdsMap['light_max'] = maxValue.toDouble();
              break;
            case 'water':
            case 'water_level':
            case 'moisture':
              thresholdsMap['water_min'] = minValue.toDouble();
              thresholdsMap['water_max'] = maxValue.toDouble();
              break;
            case 'ph':
            case 'ph_level':
              thresholdsMap['ph_min'] = minValue.toDouble();
              thresholdsMap['ph_max'] = maxValue.toDouble();
              break;
            case 'ec':
            case 'ec_level':
              thresholdsMap['ec_min'] = minValue.toDouble();
              thresholdsMap['ec_max'] = maxValue.toDouble();
              break;
            case 'tds':
            case 'tds_level':
              thresholdsMap['tds_min'] = minValue.toDouble();
              thresholdsMap['tds_max'] = maxValue.toDouble();
              break;
          }
        }
      }
    }

    print('Parsed thresholds map: $thresholdsMap');
    return ThresholdsModel.fromJson(thresholdsMap);
  }

  // Helper methods to get specific threshold values
  double getTemperatureMin() => currentThresholds.value.temperatureMin ?? 20.0;
  double getTemperatureMax() => currentThresholds.value.temperatureMax ?? 30.0;
  double getHumidityMin() => currentThresholds.value.humidityMin ?? 50.0;
  double getHumidityMax() => currentThresholds.value.humidityMax ?? 80.0;
  double getLightMin() => currentThresholds.value.lightMin ?? 500.0;
  double getLightMax() => currentThresholds.value.lightMax ?? 1000.0;
  double getWaterMin() => currentThresholds.value.waterMin ?? 50.0;
  double getWaterMax() => currentThresholds.value.waterMax ?? 100.0;
  double getPhMin() => currentThresholds.value.phMin ?? 6.0;
  double getPhMax() => currentThresholds.value.phMax ?? 7.5;
  double getEcMin() => currentThresholds.value.ecMin ?? 0.8;
  double getEcMax() => currentThresholds.value.ecMax ?? 2.0;
  double getTdsMin() => currentThresholds.value.tdsMin ?? 300.0;
  double getTdsMax() => currentThresholds.value.tdsMax ?? 800.0;

  // Check if a value is within threshold
  bool isTemperatureOk(double value) {
    return value >= getTemperatureMin() && value <= getTemperatureMax();
  }

  bool isHumidityOk(double value) {
    return value >= getHumidityMin() && value <= getHumidityMax();
  }

  bool isLightOk(double value) {
    return value >= getLightMin() && value <= getLightMax();
  }

  bool isWaterOk(double value) {
    return value >= getWaterMin() && value <= getWaterMax();
  }

  bool isPhOk(double value) {
    return value >= getPhMin() && value <= getPhMax();
  }

  bool isEcOk(double value) {
    return value >= getEcMin() && value <= getEcMax();
  }

  bool isTdsOk(double value) {
    return value >= getTdsMin() && value <= getTdsMax();
  }
}
