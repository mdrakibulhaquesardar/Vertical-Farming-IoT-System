import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/scanner_controller.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({Key? key}) : super(key: key);

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView>
    with SingleTickerProviderStateMixin {
  late final ScannerController controller;
  late final AnimationController _scanController;
  late final Animation<double> _scanPosition;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ScannerController>();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scanPosition = CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                          // Scanning animation overlay
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: AnimatedBuilder(
                                  animation: _scanPosition,
                                  builder: (context, child) {
                                    return CustomPaint(
                                      painter: _ScanLinePainter(
                                        progress: _scanPosition.value,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
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
                    } else if (controller.isPlantMissing.value) {
                      return Text(
                        'Oops! Plant is missing.\nPlease capture a plant image.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          color: Colors.orange[700],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    } else if (controller.hasResult.value) {
                      Future.delayed(Duration.zero, () {
                        if (ModalRoute.of(context)?.isCurrent ?? true) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => _buildAnalysisResultsModal(context),
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
    final isHealthy = controller.diseaseName.value.toLowerCase().contains('healthy');
    
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isHealthy 
                              ? Colors.green.withOpacity(0.15)
                              : Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isHealthy ? Icons.health_and_safety : Icons.bug_report,
                          color: isHealthy ? Colors.green : Colors.orange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🌿 Plant Analysis Report',
                              style: GoogleFonts.lato(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'AI-powered health assessment',
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Plant Type & Date Card
                  _buildInfoCard(
                    context,
                    [
                      _buildInfoItem(
                        Icons.local_florist,
                        'Plant Type',
                        controller.plantType.value.isEmpty 
                            ? 'Unknown' 
                            : controller.plantType.value,
                        Colors.blue,
                      ),
                      _buildInfoItem(
                        Icons.calendar_today,
                        'Analysis Date',
                        '${controller.analysisDate.value.day}/${controller.analysisDate.value.month}/${controller.analysisDate.value.year}',
                        Colors.purple,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Primary Detection Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isHealthy 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isHealthy 
                            ? Colors.green.withOpacity(0.3)
                            : Colors.red.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isHealthy ? Icons.check_circle : Icons.warning,
                              color: isHealthy ? Colors.green : Colors.red,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Primary Detection',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          controller.diseaseName.value,
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isHealthy ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Confidence Bar
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Confidence',
                                        style: GoogleFonts.lato(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                      ),
                                      Text(
                                        '${(controller.confidence.value * 100).toStringAsFixed(1)}%',
                                        style: GoogleFonts.lato(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: controller.confidence.value,
                                      minHeight: 8,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        controller.confidence.value >= 0.7
                                            ? Colors.green
                                            : controller.confidence.value >= 0.5
                                                ? Colors.orange
                                                : Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Risk & Severity Metrics
                  if (!isHealthy) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            context,
                            'Severity',
                            controller.severity.value,
                            _getSeverityColor(controller.severity.value),
                            Icons.assessment,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            context,
                            'Risk Level',
                            controller.riskLevel.value,
                            _getRiskColor(controller.riskLevel.value),
                            Icons.priority_high,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildMetricCard(
                      context,
                      'Treatment Urgency',
                      controller.treatmentUrgency.value,
                      _getUrgencyColor(controller.treatmentUrgency.value),
                      Icons.schedule,
                      fullWidth: true,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Top 3 Predictions
                  if (controller.topPredictions.isNotEmpty) ...[
                    Text(
                      'Top Predictions',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...controller.topPredictions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final prediction = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: index == 0 
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: index == 0 
                                ? Colors.blue.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: index == 0 
                                    ? Colors.blue.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold,
                                    color: index == 0 ? Colors.blue : Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    prediction['label'],
                                    style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(prediction['confidence'] * 100).toStringAsFixed(1)}% confidence',
                                    style: GoogleFonts.lato(
                                      fontSize: 12,
                                      color: colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                  
                  // Detailed Solution
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.orange[700],
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Treatment Recommendations',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          controller.solution.value,
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            height: 1.6,
                            color: colorScheme.onSurface.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            controller.clearResults();
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('New Scan'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Close'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
                ],
              ),
            ),
          ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: children,
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.lato(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow[700]!;
      default:
        return Colors.green;
    }
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'moderate':
        return Colors.yellow[700]!;
      default:
        return Colors.green;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'immediate':
        return Colors.red;
      case 'urgent':
        return Colors.orange;
      case 'soon':
        return Colors.yellow[700]!;
      default:
        return Colors.green;
    }
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

class _ScanLinePainter extends CustomPainter {
  _ScanLinePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final lineY = size.height * progress;
    final linePaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.9)
      ..strokeWidth = 2.0;

    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF4CAF50).withOpacity(0.0),
          const Color(0xFF4CAF50).withOpacity(0.35),
          const Color(0xFF4CAF50).withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, lineY - 18, size.width, 36));

    canvas.drawRect(
      Rect.fromLTWH(0, lineY - 18, size.width, 36),
      glowPaint,
    );
    canvas.drawLine(Offset(0, lineY), Offset(size.width, lineY), linePaint);
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
