import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../services/thresholds_service.dart';

class ThresholdsEditModal extends StatefulWidget {
  final String deviceId;

  const ThresholdsEditModal({Key? key, required this.deviceId})
    : super(key: key);

  @override
  State<ThresholdsEditModal> createState() => _ThresholdsEditModalState();
}

class _ThresholdsEditModalState extends State<ThresholdsEditModal> {
  final ThresholdsService _thresholdsService = ThresholdsService.to;

  // Controllers for text fields
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  var isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final thresholds = _thresholdsService.currentThresholds.value;

    // Initialize controllers with current values
    _controllers['temperature_min'] = TextEditingController(
      text: thresholds.temperatureMin?.toString() ?? '20.0',
    );
    _controllers['temperature_max'] = TextEditingController(
      text: thresholds.temperatureMax?.toString() ?? '30.0',
    );
    _controllers['humidity_min'] = TextEditingController(
      text: thresholds.humidityMin?.toString() ?? '50.0',
    );
    _controllers['humidity_max'] = TextEditingController(
      text: thresholds.humidityMax?.toString() ?? '80.0',
    );
    _controllers['light_min'] = TextEditingController(
      text: thresholds.lightMin?.toString() ?? '500.0',
    );
    _controllers['light_max'] = TextEditingController(
      text: thresholds.lightMax?.toString() ?? '1000.0',
    );
    _controllers['water_min'] = TextEditingController(
      text: thresholds.waterMin?.toString() ?? '50.0',
    );
    _controllers['water_max'] = TextEditingController(
      text: thresholds.waterMax?.toString() ?? '100.0',
    );
    _controllers['ph_min'] = TextEditingController(
      text: thresholds.phMin?.toString() ?? '6.0',
    );
    _controllers['ph_max'] = TextEditingController(
      text: thresholds.phMax?.toString() ?? '7.5',
    );
    _controllers['ec_min'] = TextEditingController(
      text: thresholds.ecMin?.toString() ?? '0.8',
    );
    _controllers['ec_max'] = TextEditingController(
      text: thresholds.ecMax?.toString() ?? '2.0',
    );

    // Initialize focus nodes
    for (String key in _controllers.keys) {
      _focusNodes[key] = FocusNode();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _updateThreshold(
    String sensorType,
    double minValue,
    double maxValue,
  ) async {
    try {
      isLoading.value = true;

      final url = Uri.parse(
        '${_thresholdsService.baseUrl}/thresholds/${widget.deviceId}',
      );
      print('Updating threshold for $sensorType: min=$minValue, max=$maxValue');

      final body = {
        'sensor_type': sensorType,
        'min_value': minValue,
        'max_value': maxValue,
      };

      print('Threshold update body: $body');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = json.decode(response.body);
        print('Threshold update response: $data');

        Get.snackbar(
          'Success',
          '$sensorType thresholds updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh thresholds
        await _thresholdsService.refreshThresholds(widget.deviceId);
      } else {
        print(
          'Failed to update threshold: ${response.statusCode} - ${response.body}',
        );

        Get.snackbar(
          'Error',
          'Failed to update $sensorType thresholds: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error updating threshold: $e');

      Get.snackbar(
        'Error',
        'Failed to update $sensorType thresholds: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Widget _buildThresholdField(
    String sensorType,
    String label,
    String minKey,
    String maxKey,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Minimum',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    TextField(
                      controller: _controllers[minKey],
                      focusNode: _focusNodes[minKey],
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Min value',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maximum',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    TextField(
                      controller: _controllers[maxKey],
                      focusNode: _focusNodes[maxKey],
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Max value',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Obx(
                () => ElevatedButton(
                  onPressed: isLoading.value
                      ? null
                      : () async {
                          final minValue =
                              double.tryParse(_controllers[minKey]!.text) ??
                              0.0;
                          final maxValue =
                              double.tryParse(_controllers[maxKey]!.text) ??
                              0.0;

                          if (minValue >= maxValue) {
                            Get.snackbar(
                              'Error',
                              'Minimum value must be less than maximum value',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          await _updateThreshold(
                            sensorType,
                            minValue,
                            maxValue,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading.value
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text('Update'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.settings, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Edit Thresholds',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildThresholdField(
                    'temperature',
                    'Temperature',
                    'temperature_min',
                    'temperature_max',
                    Icons.thermostat,
                    Colors.red,
                  ),
                  _buildThresholdField(
                    'humidity',
                    'Humidity',
                    'humidity_min',
                    'humidity_max',
                    Icons.water_drop,
                    Colors.blue,
                  ),
                  _buildThresholdField(
                    'light',
                    'Light Level',
                    'light_min',
                    'light_max',
                    Icons.lightbulb,
                    Colors.amber,
                  ),
                  _buildThresholdField(
                    'water',
                    'Water Level',
                    'water_min',
                    'water_max',
                    Icons.water,
                    Colors.cyan,
                  ),
                  _buildThresholdField(
                    'ph',
                    'pH Level',
                    'ph_min',
                    'ph_max',
                    Icons.science,
                    Colors.purple,
                  ),
                  _buildThresholdField(
                    'ec',
                    'EC Level',
                    'ec_min',
                    'ec_max',
                    Icons.electric_bolt,
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
