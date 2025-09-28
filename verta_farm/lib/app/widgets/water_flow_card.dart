import 'package:flutter/material.dart';

class WaterFlowCard extends StatefulWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;
  final String status;
  final bool isActive;

  const WaterFlowCard({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.status,
    required this.isActive,
  }) : super(key: key);

  @override
  State<WaterFlowCard> createState() => _WaterFlowCardState();
}

class _WaterFlowCardState extends State<WaterFlowCard>
    with TickerProviderStateMixin {
  late AnimationController _dropletController;
  late Animation<double> _dropletAnimation;

  @override
  void initState() {
    super.initState();

    // Droplet animation
    _dropletController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _dropletAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dropletController, curve: Curves.linear),
    );

    if (widget.isActive) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    _dropletController.repeat();
  }

  void _stopAnimations() {
    _dropletController.stop();
  }

  @override
  void didUpdateWidget(WaterFlowCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    _dropletController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Water droplets animation (only when active)
            if (widget.isActive)
              AnimatedBuilder(
                animation: _dropletAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: WaterDropletPainter(
                      animationValue: _dropletAnimation.value,
                      isActive: widget.isActive,
                    ),
                  );
                },
              ),

            // Content - Same as SensorCard
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.iconColor,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              widget.status,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Value
                  Center(
                    child: Text(
                      widget.value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),

                  if (widget.unit.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Center(
                      child: Text(
                        widget.unit,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WaterDropletPainter extends CustomPainter {
  final double animationValue;
  final bool isActive;

  WaterDropletPainter({required this.animationValue, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;

    final paint = Paint();
    paint.color = Colors.blue.withOpacity(0.6);
    paint.style = PaintingStyle.fill;

    // Create multiple droplets falling from different positions
    final dropletCount = 8;
    for (int i = 0; i < dropletCount; i++) {
      final dropletX = 20 + (i * (size.width - 40) / (dropletCount - 1));
      final dropletY =
          20 + (animationValue * size.height * 1.5) % (size.height + 50);

      // Make droplets smaller as they fall
      final dropletSize = 3.0 - (dropletY / size.height) * 1.5;

      if (dropletSize > 0) {
        canvas.drawCircle(Offset(dropletX, dropletY), dropletSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(WaterDropletPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isActive != isActive;
  }
}
