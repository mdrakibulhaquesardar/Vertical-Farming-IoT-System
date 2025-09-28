import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ScannerController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  var selectedImage = Rx<File?>(null);
  var isAnalyzing = false.obs;
  var diseaseName = ''.obs;
  var solution = ''.obs;
  var hasResult = false.obs;

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

    isAnalyzing.value = true;
    hasResult.value = false;

    // Simulate AI analysis delay
    await Future.delayed(const Duration(seconds: 3));

    // Simulate disease detection (in real app, this would call an AI API)
    final random = DateTime.now().millisecond % 4;
    switch (random) {
      case 0:
        diseaseName.value = 'Leaf Blight';
        solution.value =
            'Remove affected leaves and apply fungicide. Ensure proper air circulation.';
        break;
      case 1:
        diseaseName.value = 'Powdery Mildew';
        solution.value =
            'Apply neem oil or baking soda solution. Increase air circulation and reduce humidity.';
        break;
      case 2:
        diseaseName.value = 'Root Rot';
        solution.value =
            'Improve drainage, reduce watering frequency, and apply beneficial bacteria.';
        break;
      case 3:
        diseaseName.value = 'Healthy Plant';
        solution.value =
            'Your plant is healthy! Continue with current care routine.';
        break;
    }

    isAnalyzing.value = false;
    hasResult.value = true;

    Get.snackbar(
      'Analysis Complete',
      'Plant disease analysis finished',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
    );
  }

  void clearResults() {
    selectedImage.value = null;
    diseaseName.value = '';
    solution.value = '';
    hasResult.value = false;
  }
}
