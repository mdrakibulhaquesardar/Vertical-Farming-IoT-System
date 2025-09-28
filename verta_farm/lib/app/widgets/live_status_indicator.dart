import 'package:flutter/material.dart';

class LiveStatusIndicator extends StatelessWidget {
  final double temperature;
  final String moisture;
  final String diseaseStatus;
  final String pumpStatus;
  final String lightStatus;
  final String fanStatus;
  final Color pumpStatusColor;
  final Color lightStatusColor;
  final Color fanStatusColor;

  const LiveStatusIndicator({
    super.key,
    required this.temperature,
    required this.moisture,
    required this.diseaseStatus,
    required this.pumpStatus,
    required this.lightStatus,
    required this.fanStatus,
    required this.pumpStatusColor,
    required this.lightStatusColor,
    required this.fanStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Vertical Farming Stand Image (Left Side)
            Expanded(flex: 2, child: _buildVerticalFarmingImage(colorScheme)),
            const SizedBox(width: 16),

            // Status Information (Right Side)
            Expanded(flex: 3, child: _buildStatusInformation(colorScheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalFarmingImage(ColorScheme colorScheme) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2), width: 1),
      ),
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green.withOpacity(0.05),
                  Colors.green.withOpacity(0.1),
                ],
              ),
            ),
          ),

          // Vertical farming stand illustration
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top section with plants
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPlantPot(Colors.green[600]!),
                    _buildPlantPot(Colors.green[500]!),
                    _buildPlantPot(Colors.green[700]!),
                  ],
                ),
                const SizedBox(height: 8),

                // Middle section with plants
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPlantPot(Colors.green[500]!),
                    _buildPlantPot(Colors.green[600]!),
                    _buildPlantPot(Colors.green[400]!),
                  ],
                ),
                const SizedBox(height: 8),

                // Bottom section with plants
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPlantPot(Colors.green[700]!),
                    _buildPlantPot(Colors.green[500]!),
                    _buildPlantPot(Colors.green[600]!),
                  ],
                ),
              ],
            ),
          ),

          // Vertical stand lines
          Positioned(
            left: 20,
            right: 20,
            top: 0,
            bottom: 0,
            child: CustomPaint(painter: VerticalStandPainter()),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantPot(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInformation(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'Live Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // Pump Status
        _buildStatusIndicator(
          '💧 Pump Status',
          pumpStatus,
          pumpStatusColor,
          colorScheme,
        ),
        const SizedBox(height: 12),

        // Environmental Status
        Row(
          children: [
            Expanded(
              child: _buildEnvIndicator(
                '💧 Moisture',
                moisture,
                _getMoistureColor(moisture),
                colorScheme,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildEnvIndicator(
                '⚠ Disease',
                diseaseStatus,
                _getDiseaseColor(diseaseStatus),
                colorScheme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(
    String label,
    String status,
    Color statusColor,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvIndicator(
    String label,
    String value,
    Color valueColor,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: valueColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: valueColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMoistureColor(String moisture) {
    switch (moisture.toLowerCase()) {
      case 'low':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getDiseaseColor(String disease) {
    switch (disease.toLowerCase()) {
      case 'none':
        return Colors.green;
      case 'detected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Custom painter for vertical stand lines
class VerticalStandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Vertical lines
    canvas.drawLine(
      Offset(size.width * 0.25, 0),
      Offset(size.width * 0.25, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.75, 0),
      Offset(size.width * 0.75, size.height),
      paint,
    );

    // Horizontal lines connecting the vertical ones
    for (int i = 1; i <= 3; i++) {
      double y = size.height * (i / 4);
      canvas.drawLine(
        Offset(size.width * 0.1, y),
        Offset(size.width * 0.9, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
