import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/snackbar_utils.dart';
import '../controllers/scanner_controller.dart';

class ScannerView extends GetView<ScannerController> {
  const ScannerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Floating colored dots
          Positioned(top: 40, left: 20, child: _buildDot(Colors.yellow, 32)),
          Positioned(bottom: 80, right: 30, child: _buildDot(Colors.green, 24)),
          Positioned(
            top: 150,
            left: 25,
            child: _buildDot(Colors.lightGreen, 24),
          ),
          Positioned(
            bottom: 150,
            left: 50,
            child: _buildDot(Colors.orange, 24),
          ),
          Positioned(
            bottom: 30,
            left: 40,
            child: _buildDot(Colors.yellow.withOpacity(0.7), 18),
          ),
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Plant Scanner',
                            style: GoogleFonts.lato(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            ' (Beta)',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                      Icon(Icons.add, color: Colors.black54),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Scan frame with plant image
                  Center(
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Scan frame
                          CustomPaint(
                            size: const Size(200, 200),
                            painter: _ScanFramePainter(),
                          ),
                          // Plant image
                          Obx(() {
                            if (controller.selectedImage.value != null) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.file(
                                  controller.selectedImage.value!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.contain,
                                ),
                              );
                            } else {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.network(
                                  'https://images.squarespace-cdn.com/content/v1/57d2a26b20099eb50e305b38/1543953057869-4XCR18WA5YQ3OPQ0LJ55/kava-kava-illustration.jpg',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.fill,
                                ),
                              );
                            }
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Message
                  Obx(() {
                    if (controller.isAnalyzing.value) {
                      return Text(
                        'Analyzing... Please wait.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          color: Colors.grey[700],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    } else if (controller.hasResult.value) {
                      Future.delayed(Duration.zero, () {
                        if (ModalRoute.of(context)?.isCurrent ?? true) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            builder: (context) =>
                                _buildAnalysisResultsModal(context),
                          );
                          controller.hasResult.value =
                              false; // Reset to prevent multiple modals
                        }
                      });
                      return SizedBox.shrink();
                    } else {
                      return Text(
                        'Your plant looks good.\nKeep grooming!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          color: Colors.grey[800],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }
                  }),
                  const SizedBox(height: 16),
                  // How to use instructions
                  Text(
                    'How to use:',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Take a picture of your plant.\n'
                    '2. Wait for the analysis to complete.\n'
                    '3. View the results and take action if needed.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Status indicators Server Online and Camera Ready
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Server Online',
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: Colors.blue,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Camera Ready',
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Spacer(),
                  // Action Buttons (keep as before)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: controller.takePicture,
                          icon: const Icon(Icons.camera_alt),
                          label: Text(
                            'Take Picture',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: controller.uploadImage,
                          icon: const Icon(Icons.upload),
                          label: Text(
                            'Upload Image',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF81D4FA),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildAnalysisResultsModal(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.health_and_safety,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 Analysis Results',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AI-powered plant health assessment',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bug_report, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Detected Issue:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  controller.diseaseName.value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Recommended Solution:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  controller.solution.value,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                controller.clearResults();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Clear Results'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final radius = 32.0;
    // Draw only corners
    // Top left
    canvas.drawArc(
      Rect.fromLTWH(0, 0, radius, radius),
      3.14,
      1.57,
      false,
      paint,
    );
    // Top right
    canvas.drawArc(
      Rect.fromLTWH(size.width - radius, 0, radius, radius),
      -1.57,
      1.57,
      false,
      paint,
    );
    // Bottom left
    canvas.drawArc(
      Rect.fromLTWH(0, size.height - radius, radius, radius),
      1.57,
      1.57,
      false,
      paint,
    );
    // Bottom right
    canvas.drawArc(
      Rect.fromLTWH(size.width - radius, size.height - radius, radius, radius),
      0,
      1.57,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
