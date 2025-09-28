import 'dart:math';
import 'package:flutter/material.dart';

class WaterTankCard extends StatefulWidget {
  final String title;
  final double currentLiters;
  final double maxLiters;
  final String unit;
  final IconData icon;
  final Color iconColor;
  final String status;

  const WaterTankCard({
    Key? key,
    required this.title,
    required this.currentLiters,
    required this.maxLiters,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.status,
  }) : super(key: key);

  @override
  State<WaterTankCard> createState() => _WaterTankCardState();
}

class _WaterTankCardState extends State<WaterTankCard>
    with TickerProviderStateMixin {
  late AnimationController _waterController;
  late AnimationController _waveController;
  late Animation<double> _waterLevelAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    // Water level animation
    _waterController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    // Wave animation for water effect
    _waveController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _waterLevelAnimation =
        Tween<double>(
          begin: 0.0,
          end: widget.currentLiters / widget.maxLiters,
        ).animate(
          CurvedAnimation(parent: _waterController, curve: Curves.easeInOut),
        );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.linear));

    _waterController.forward();
  }

  @override
  void didUpdateWidget(WaterTankCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLiters != widget.currentLiters) {
      _waterLevelAnimation =
          Tween<double>(
            begin: _waterLevelAnimation.value,
            end: widget.currentLiters / widget.maxLiters,
          ).animate(
            CurvedAnimation(parent: _waterController, curve: Curves.easeInOut),
          );
      _waterController.reset();
      _waterController.forward();
    }
  }

  @override
  void dispose() {
    _waterController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fillPercentage = widget.currentLiters / widget.maxLiters;
    final isLow = fillPercentage < 0.2;
    final isMedium = fillPercentage >= 0.2 && fillPercentage < 0.7;
    final isHigh = fillPercentage >= 0.7;

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Water Tank Background
            AnimatedBuilder(
              animation: _waterLevelAnimation,
              builder: (context, child) {
                return AnimatedBuilder(
                  animation: _waveAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: FullWaterTankPainter(
                        fillLevel: _waterLevelAnimation.value,
                        waveOffset: _waveAnimation.value,
                        isLow: isLow,
                        isMedium: isMedium,
                        isHigh: isHigh,
                      ),
                    );
                  },
                );
              },
            ),

            // Content Overlay
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                widget.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isLow
                                      ? Colors.red[300]
                                      : isMedium
                                      ? Colors.orange[300]
                                      : Colors.green[300],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  Spacer(),

                  // Water Level Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.currentLiters.toStringAsFixed(1)}${widget.unit}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'of ${widget.maxLiters}${widget.unit}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),

                      Text(
                        '${(fillPercentage * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullWaterTankPainter extends CustomPainter {
  final double fillLevel;
  final double waveOffset;
  final bool isLow;
  final bool isMedium;
  final bool isHigh;

  FullWaterTankPainter({
    required this.fillLevel,
    required this.waveOffset,
    required this.isLow,
    required this.isMedium,
    required this.isHigh,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final path = Path();

    // Tank background (empty space)
    paint.color = Colors.grey[100]!;
    paint.style = PaintingStyle.fill;

    // Tank shape (rounded rectangle)
    final tankRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(16),
    );
    canvas.drawRRect(tankRect, paint);

    // Tank border
    paint.color = Colors.grey[400]!;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawRRect(tankRect, paint);

    // Water fill
    if (fillLevel > 0) {
      final waterHeight = size.height * fillLevel;
      final waterY = size.height - waterHeight;

      // Water color based on level
      Color waterColor;
      if (isLow) {
        waterColor = Colors.red.withOpacity(0.8);
      } else if (isMedium) {
        waterColor = Colors.orange.withOpacity(0.8);
      } else {
        waterColor = Colors.blue.withOpacity(0.8);
      }

      paint.color = waterColor;
      paint.style = PaintingStyle.fill;

      // Create water shape with waves
      path.reset();
      path.moveTo(0, waterY);

      // Add wave effect
      final waveAmplitude = 4.0;
      final waveFrequency = 0.05;
      for (double x = 0; x <= size.width; x += 2) {
        final waveY =
            waterY +
            waveAmplitude * sin(waveOffset * 2 * 3.14159 + x * waveFrequency);
        path.lineTo(x, waveY);
      }

      path.lineTo(size.width, waterY);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      canvas.drawPath(path, paint);

      // Add water surface highlight
      paint.color = Colors.white.withOpacity(0.4);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      canvas.drawPath(path, paint);

      // Add water reflection
      paint.color = Colors.white.withOpacity(0.2);
      paint.style = PaintingStyle.fill;
      final reflectionRect = Rect.fromLTWH(
        0,
        waterY,
        size.width,
        waterHeight * 0.3,
      );
      canvas.drawRect(reflectionRect, paint);
    }

    // Add water droplets if tank is full
    if (fillLevel >= 0.95) {
      paint.color = Colors.blue.withOpacity(0.7);
      paint.style = PaintingStyle.fill;

      // Draw small droplets falling from the top
      for (int i = 0; i < 5; i++) {
        final dropletX = 20 + i * (size.width - 40) / 4;
        final dropletY = 20 + (waveOffset * 30) % 30;
        canvas.drawCircle(Offset(dropletX, dropletY), 3, paint);
      }
    }

    // Tank details removed - no divider lines
  }

  @override
  bool shouldRepaint(FullWaterTankPainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel ||
        oldDelegate.waveOffset != waveOffset ||
        oldDelegate.isLow != isLow ||
        oldDelegate.isMedium != isMedium ||
        oldDelegate.isHigh != isHigh;
  }
}

class WaterTankPainter extends CustomPainter {
  final double fillLevel;
  final double waveOffset;
  final bool isLow;
  final bool isMedium;
  final bool isHigh;

  WaterTankPainter({
    required this.fillLevel,
    required this.waveOffset,
    required this.isLow,
    required this.isMedium,
    required this.isHigh,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final path = Path();

    // Tank outline
    paint.color = Colors.grey[300]!;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;

    // Tank shape (rounded rectangle)
    final tankRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
      Radius.circular(8),
    );
    canvas.drawRRect(tankRect, paint);

    // Water fill
    if (fillLevel > 0) {
      final waterHeight = (size.height - 20) * fillLevel;
      final waterY = size.height - 10 - waterHeight;

      // Water color based on level
      Color waterColor;
      if (isLow) {
        waterColor = Colors.red.withOpacity(0.7);
      } else if (isMedium) {
        waterColor = Colors.orange.withOpacity(0.7);
      } else {
        waterColor = Colors.blue.withOpacity(0.7);
      }

      paint.color = waterColor;
      paint.style = PaintingStyle.fill;

      // Create water shape with waves
      path.reset();
      path.moveTo(10, waterY);

      // Add wave effect
      final waveAmplitude = 3.0;
      final waveFrequency = 0.1;
      for (double x = 10; x <= size.width - 10; x += 1) {
        final waveY =
            waterY +
            waveAmplitude * sin(waveOffset * 2 * 3.14159 + x * waveFrequency);
        path.lineTo(x, waveY);
      }

      path.lineTo(size.width - 10, waterY);
      path.lineTo(size.width - 10, size.height - 10);
      path.lineTo(10, size.height - 10);
      path.close();

      canvas.drawPath(path, paint);

      // Add water surface highlight
      paint.color = Colors.white.withOpacity(0.3);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1;
      canvas.drawPath(path, paint);
    }

    // Add water droplets if tank is full
    if (fillLevel >= 0.95) {
      paint.color = Colors.blue.withOpacity(0.6);
      paint.style = PaintingStyle.fill;

      // Draw small droplets falling from the top
      for (int i = 0; i < 3; i++) {
        final dropletX = 20 + i * 30.0;
        final dropletY = 15 + (waveOffset * 20) % 20;
        canvas.drawCircle(Offset(dropletX, dropletY), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(WaterTankPainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel ||
        oldDelegate.waveOffset != waveOffset ||
        oldDelegate.isLow != isLow ||
        oldDelegate.isMedium != isMedium ||
        oldDelegate.isHigh != isHigh;
  }
}
