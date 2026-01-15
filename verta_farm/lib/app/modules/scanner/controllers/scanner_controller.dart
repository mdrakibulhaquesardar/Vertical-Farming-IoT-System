import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ScannerController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  late Interpreter _interpreter;
  List<String> _labels = [];
  bool _isModelReady = false;

  var selectedImage = Rx<File?>(null);
  var isAnalyzing = false.obs;
  var diseaseName = ''.obs;
  var solution = ''.obs;
  var hasResult = false.obs;
  var confidence = 0.0.obs;
  var topPredictions = <Map<String, dynamic>>[].obs;
  var severity = ''.obs;
  var riskLevel = ''.obs;
  var plantType = ''.obs;
  var treatmentUrgency = ''.obs;
  var analysisDate = DateTime.now().obs;
  var isPlantMissing = false.obs;

  static const int _inputSize = 224;

  @override
  void onInit() {
    super.onInit();
    _loadModelAndLabels();
  }

  @override
  void onClose() {
    if (_isModelReady) {
      _interpreter.close();
    }
    super.onClose();
  }

  Future<void> _loadModelAndLabels() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/plant_disease_model.tflite',
      );
      final labelsRaw = await rootBundle.loadString(
        'assets/models/plant_disease_model_labels.txt',
      );
      _labels = labelsRaw
          .split('\n')
          .map((label) => label.trim())
          .where((label) => label.isNotEmpty)
          .toList();
      _isModelReady = true;
    } catch (e) {
      _isModelReady = false;
      Get.snackbar(
        'Model Error',
        'Failed to load AI model: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        selectedImage.value = File(photo.path);
        await analyzePlant();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take picture: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> uploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImage.value = File(image.path);
        await analyzePlant();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> analyzePlant() async {
    if (selectedImage.value == null) return;
    if (!_isModelReady || _labels.isEmpty) {
      Get.snackbar(
        'Model Not Ready',
        'AI model is still loading. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isAnalyzing.value = true;
    hasResult.value = false;
    confidence.value = 0.0;
    topPredictions.clear();
    severity.value = '';
    riskLevel.value = '';
    plantType.value = '';
    treatmentUrgency.value = '';
    isPlantMissing.value = false;

    try {
      final bytes = await selectedImage.value!.readAsBytes();
      final img.Image? decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw Exception('Could not decode image.');
      }

      final img.Image resized = img.copyResize(
        decoded,
        width: _inputSize,
        height: _inputSize,
      );

      // Create a flat Float32List (1 * 224 * 224 * 3)
      var input = Float32List(1 * _inputSize * _inputSize * 3);
      var bufferIndex = 0;

      // Fill the flat list with normalized values
      for (int y = 0; y < _inputSize; y++) {
        for (int x = 0; x < _inputSize; x++) {
          final pixel = resized.getPixel(x, y);
          // Normalize to [-1, 1] range
          input[bufferIndex++] = (pixel.r.toDouble() / 127.5) - 1.0;
          input[bufferIndex++] = (pixel.g.toDouble() / 127.5) - 1.0;
          input[bufferIndex++] = (pixel.b.toDouble() / 127.5) - 1.0;
        }
      }

      var output = List.filled(
        _labels.length,
        0.0,
      ).reshape([1, _labels.length]);

      // Reshape the flat list on the fly for the interpreter
      _interpreter.run(input.reshape([1, _inputSize, _inputSize, 3]), output);

      final scores = output[0];

      // Get top 3 predictions
      List<Map<String, dynamic>> predictions = [];
      for (int i = 0; i < scores.length; i++) {
        predictions.add({'label': _labels[i], 'confidence': scores[i]});
      }
      predictions.sort((a, b) => b['confidence'].compareTo(a['confidence']));
      topPredictions.value = predictions.take(3).toList();

      // Set primary prediction
      diseaseName.value = topPredictions[0]['label'];
      confidence.value = topPredictions[0]['confidence'];

      if (diseaseName.value.toLowerCase() == 'background_without_leaves') {
        isAnalyzing.value = false;
        hasResult.value = false;
        isPlantMissing.value = true;
        return;
      }

      // Extract plant type from label
      plantType.value = _extractPlantType(diseaseName.value);

      // Calculate severity and risk level
      _calculateSeverityAndRisk();

      // Generate detailed solution
      solution.value = _generateDetailedSolution(
        diseaseName.value,
        confidence.value,
      );

      // Set analysis date
      analysisDate.value = DateTime.now();

      isAnalyzing.value = false;
      hasResult.value = true;

      Get.snackbar(
        'Analysis Complete',
        'Plant disease analysis finished',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } catch (e) {
      isAnalyzing.value = false;
      Get.snackbar(
        'Analysis Failed',
        'Unable to analyze image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String _extractPlantType(String label) {
    if (label.toLowerCase().contains('tomato')) return 'Tomato';
    if (label.toLowerCase().contains('potato')) return 'Potato';
    if (label.toLowerCase().contains('pepper')) return 'Pepper';
    if (label.toLowerCase().contains('strawberry')) return 'Strawberry';
    return 'Unknown';
  }

  void _calculateSeverityAndRisk() {
    final isHealthy = diseaseName.value.toLowerCase().contains('healthy');
    final conf = confidence.value;

    if (isHealthy) {
      severity.value = 'None';
      riskLevel.value = 'Low';
      treatmentUrgency.value = 'Not Required';
    } else {
      // Calculate severity based on confidence and disease type
      if (conf >= 0.85) {
        severity.value = 'High';
        riskLevel.value = 'Critical';
        treatmentUrgency.value = 'Immediate';
      } else if (conf >= 0.70) {
        severity.value = 'Medium';
        riskLevel.value = 'High';
        treatmentUrgency.value = 'Urgent';
      } else {
        severity.value = 'Low';
        riskLevel.value = 'Moderate';
        treatmentUrgency.value = 'Soon';
      }

      // Adjust based on disease type
      final diseaseLower = diseaseName.value.toLowerCase();
      if (diseaseLower.contains('blight') ||
          diseaseLower.contains('virus') ||
          diseaseLower.contains('mosaic')) {
        if (severity.value == 'Low') {
          severity.value = 'Medium';
          riskLevel.value = 'High';
        }
      }
    }
  }

  String _generateDetailedSolution(String disease, double conf) {
    final diseaseLower = disease.toLowerCase();

    if (diseaseLower.contains('healthy')) {
      return 'Your plant appears to be in good health. Continue with regular watering, proper sunlight exposure, and maintain good soil conditions. Monitor regularly for any changes.';
    }

    String baseSolution = '';
    String specificAdvice = '';

    if (diseaseLower.contains('bacterial spot')) {
      baseSolution =
          'Bacterial spot detected. This is a common bacterial disease.';
      specificAdvice =
          'Remove affected leaves immediately. Apply copper-based fungicide. Avoid overhead watering. Ensure good air circulation.';
    } else if (diseaseLower.contains('early blight')) {
      baseSolution =
          'Early blight identified. This fungal disease spreads quickly.';
      specificAdvice =
          'Remove infected leaves. Apply fungicide containing chlorothalonil or mancozeb. Water at the base, not on leaves. Mulch around plants.';
    } else if (diseaseLower.contains('late blight')) {
      baseSolution = 'Late blight detected - this is a serious disease.';
      specificAdvice =
          'URGENT: Remove and destroy all infected plant parts immediately. Apply fungicide with metalaxyl or copper. Isolate from other plants.';
    } else if (diseaseLower.contains('leaf mold')) {
      baseSolution =
          'Leaf mold detected. This fungal disease thrives in humidity.';
      specificAdvice =
          'Improve air circulation. Reduce humidity. Remove affected leaves. Apply fungicide. Water early in the day.';
    } else if (diseaseLower.contains('septoria')) {
      baseSolution = 'Septoria leaf spot identified.';
      specificAdvice =
          'Remove infected leaves. Apply copper fungicide. Avoid overhead watering. Rotate crops next season.';
    } else if (diseaseLower.contains('spider mite') ||
        diseaseLower.contains('mites')) {
      baseSolution = 'Spider mite infestation detected.';
      specificAdvice =
          'Spray with neem oil or insecticidal soap. Increase humidity. Remove heavily infested leaves. Consider introducing beneficial insects.';
    } else if (diseaseLower.contains('target spot')) {
      baseSolution = 'Target spot disease identified.';
      specificAdvice =
          'Remove affected leaves. Apply fungicide. Improve air circulation. Avoid wetting foliage.';
    } else if (diseaseLower.contains('virus') ||
        diseaseLower.contains('mosaic')) {
      baseSolution = 'Viral disease detected. Viruses cannot be cured.';
      specificAdvice =
          'Remove and destroy infected plants immediately to prevent spread. Control insect vectors (aphids, whiteflies). Use virus-free seeds.';
    } else if (diseaseLower.contains('leaf scorch')) {
      baseSolution = 'Leaf scorch detected.';
      specificAdvice =
          'Ensure adequate watering. Check for root damage. Provide shade during hottest hours. Mulch to retain moisture.';
    } else {
      baseSolution = 'Plant disease detected.';
      specificAdvice =
          'Isolate the plant. Remove affected parts. Apply appropriate treatment based on disease type. Monitor closely.';
    }

    String confidenceNote = '';
    if (conf >= 0.85) {
      confidenceNote = ' High confidence diagnosis.';
    } else if (conf >= 0.70) {
      confidenceNote =
          ' Moderate confidence. Consider consulting an expert for confirmation.';
    } else {
      confidenceNote =
          ' Lower confidence. Please verify with additional testing or expert consultation.';
    }

    return '$baseSolution\n\n$specificAdvice\n\nNote:$confidenceNote';
  }

  void clearResults() {
    selectedImage.value = null;
    diseaseName.value = '';
    solution.value = '';
    hasResult.value = false;
    confidence.value = 0.0;
    topPredictions.clear();
    severity.value = '';
    riskLevel.value = '';
    plantType.value = '';
    treatmentUrgency.value = '';
    isPlantMissing.value = false;
  }
}
