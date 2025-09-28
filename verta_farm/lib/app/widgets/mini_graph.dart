import 'package:flutter/material.dart';
import 'dart:math' as math;

class MiniGraph extends StatelessWidget {
  final List<double> data;
  final Color lineColor;
  final Color fillColor;
  final double height;
  final String title;
  final String value;
  final String unit;

  const MiniGraph({
    Key? key,
    required this.data,
    required this.lineColor,
    required this.fillColor,
    this.height = 60,
    required this.title,
    required this.value,
    required this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (data.isEmpty) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        ),
        child: Center(
          child: Text(
            'No data',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(width: 2),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            SizedBox(
              height: height - 40,
              child: CustomPaint(
                size: Size(double.infinity, height - 40),
                painter: SparklinePainter(
                  data: data,
                  lineColor: lineColor,
                  fillColor: fillColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color fillColor;

  SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final minValue = data.reduce(math.min);
    final maxValue = data.reduce(math.max);
    final range = maxValue - minValue;
    final rangeAdjusted = range == 0 ? 1 : range;

    final xStep = size.width / (data.length - 1);
    final yStep = size.height / rangeAdjusted;

    // Start the paths
    path.moveTo(0, size.height - (data[0] - minValue) * yStep);
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height - (data[0] - minValue) * yStep);

    // Draw the line and fill path
    for (int i = 1; i < data.length; i++) {
      final x = i * xStep;
      final y = size.height - (data[i] - minValue) * yStep;

      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    // Complete the fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw fill first, then line
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
