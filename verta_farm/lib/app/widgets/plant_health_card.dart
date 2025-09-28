import 'package:flutter/material.dart';

class PlantHealthCard extends StatelessWidget {
  final String healthStatus;
  final String healthIcon;
  final Color healthColor;
  final String aiSummary;
  final bool diseaseDetected;
  final VoidCallback onScanNow;
  final VoidCallback? onViewDetails;

  const PlantHealthCard({
    super.key,
    required this.healthStatus,
    required this.healthIcon,
    required this.healthColor,
    required this.aiSummary,
    required this.diseaseDetected,
    required this.onScanNow,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [healthColor.withOpacity(0.1), healthColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: healthColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: healthColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(healthIcon, style: TextStyle(fontSize: 24)),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plant Health',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: healthColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          healthStatus,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: healthColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              aiSummary,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.8),
                height: 1.4,
              ),
            ),
            //SizedBox(height: 16),
            // Row(
            //   children: [
            //     Expanded(
            //       child: ElevatedButton.icon(
            //         onPressed: onScanNow,
            //         icon: Icon(Icons.camera_alt, size: 18),
            //         label: Text('Scan Now'),
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: colorScheme.primary,
            //           foregroundColor: colorScheme.onPrimary,
            //           padding: EdgeInsets.symmetric(vertical: 12),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(8),
            //           ),
            //         ),
            //       ),
            //     ),
            //     if (diseaseDetected && onViewDetails != null) ...[
            //       SizedBox(width: 12),
            //       OutlinedButton(
            //         onPressed: onViewDetails,
            //         child: Text('View Details'),
            //         style: OutlinedButton.styleFrom(
            //           foregroundColor: healthColor,
            //           side: BorderSide(color: healthColor),
            //           padding: EdgeInsets.symmetric(
            //             vertical: 12,
            //             horizontal: 16,
            //           ),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(8),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
