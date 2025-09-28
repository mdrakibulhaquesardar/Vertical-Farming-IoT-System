class ThresholdsModel {
  final String deviceId;
  final double? temperatureMin;
  final double? temperatureMax;
  final double? humidityMin;
  final double? humidityMax;
  final double? lightMin;
  final double? lightMax;
  final double? waterMin;
  final double? waterMax;
  final double? phMin;
  final double? phMax;
  final double? ecMin;
  final double? ecMax;
  final double? tdsMin;
  final double? tdsMax;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ThresholdsModel({
    required this.deviceId,
    this.temperatureMin,
    this.temperatureMax,
    this.humidityMin,
    this.humidityMax,
    this.lightMin,
    this.lightMax,
    this.waterMin,
    this.waterMax,
    this.phMin,
    this.phMax,
    this.ecMin,
    this.ecMax,
    this.tdsMin,
    this.tdsMax,
    this.createdAt,
    this.updatedAt,
  });

  factory ThresholdsModel.fromJson(Map<String, dynamic> json) {
    return ThresholdsModel(
      deviceId: json['device_id'] ?? '',
      temperatureMin: json['temperature_min']?.toDouble(),
      temperatureMax: json['temperature_max']?.toDouble(),
      humidityMin: json['humidity_min']?.toDouble(),
      humidityMax: json['humidity_max']?.toDouble(),
      lightMin: json['light_min']?.toDouble(),
      lightMax: json['light_max']?.toDouble(),
      waterMin: json['water_min']?.toDouble(),
      waterMax: json['water_max']?.toDouble(),
      phMin: json['ph_min']?.toDouble(),
      phMax: json['ph_max']?.toDouble(),
      ecMin: json['ec_min']?.toDouble(),
      ecMax: json['ec_max']?.toDouble(),
      tdsMin: json['tds_min']?.toDouble(),
      tdsMax: json['tds_max']?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'temperature_min': temperatureMin,
      'temperature_max': temperatureMax,
      'humidity_min': humidityMin,
      'humidity_max': humidityMax,
      'light_min': lightMin,
      'light_max': lightMax,
      'water_min': waterMin,
      'water_max': waterMax,
      'ph_min': phMin,
      'ph_max': phMax,
      'ec_min': ecMin,
      'ec_max': ecMax,
      'tds_min': tdsMin,
      'tds_max': tdsMax,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Default thresholds if API data is not available
  static ThresholdsModel getDefaultThresholds(String deviceId) {
    return ThresholdsModel(
      deviceId: deviceId,
      temperatureMin: 20.0,
      temperatureMax: 30.0,
      humidityMin: 50.0,
      humidityMax: 80.0,
      lightMin: 500.0,
      lightMax: 1000.0,
      waterMin: 50.0,
      waterMax: 100.0,
      phMin: 6.0,
      phMax: 7.5,
      ecMin: 0.8,
      ecMax: 2.0,
      tdsMin: 300.0,
      tdsMax: 800.0,
    );
  }
}
