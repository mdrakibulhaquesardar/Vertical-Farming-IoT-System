import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PumpControlCard extends StatelessWidget {
  final bool pumpStatus;
  final double flowRate;
  final String pumpMode;
  final bool isManualWatering;
  final int manualWateringTime;
  final VoidCallback onTogglePump;
  final Function(double) onFlowRateChanged;
  final Function(String) onModeChanged;
  final VoidCallback onManualWatering;
  final Function(int) onManualWateringTimeChanged;

  const PumpControlCard({
    super.key,
    required this.pumpStatus,
    required this.flowRate,
    required this.pumpMode,
    required this.isManualWatering,
    required this.manualWateringTime,
    required this.onTogglePump,
    required this.onFlowRateChanged,
    required this.onModeChanged,
    required this.onManualWatering,
    required this.onManualWateringTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.water, color: Colors.blue, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🚿 Water Pump Control',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: pumpStatus ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            pumpStatus ? 'Running' : 'Stopped',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: pumpStatus,
                  onChanged: (_) => onTogglePump(),
                  activeColor: Colors.blue,
                ),
              ],
            ),
            SizedBox(height: 20),

            // Flow Rate Control
            Text(
              'Flow Rate: ${flowRate.toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.blue,
                inactiveTrackColor: Colors.blue.withOpacity(0.2),
                thumbColor: Colors.blue,
                overlayColor: Colors.blue.withOpacity(0.1),
                trackHeight: 4,
              ),
              child: Slider(
                value: flowRate,
                min: 0,
                max: 100,
                divisions: 20,
                onChanged: onFlowRateChanged,
              ),
            ),
            SizedBox(height: 16),

            // Mode Selection
            Row(
              children: [
                Expanded(
                  child: _buildModeButton(
                    '🔒 Auto',
                    pumpMode == 'Auto',
                    () => onModeChanged('Auto'),
                    colorScheme,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildModeButton(
                    '🔓 Manual',
                    pumpMode == 'Manual',
                    () => onModeChanged('Manual'),
                    colorScheme,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Manual Watering Timer
            if (pumpMode == 'Manual') ...[
              Text(
                'Manual Watering Timer',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: manualWateringTime,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [30, 60, 120, 300].map((seconds) {
                        return DropdownMenuItem(
                          value: seconds,
                          child: Text('${seconds}s'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) onManualWateringTimeChanged(value);
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isManualWatering ? null : onManualWatering,
                      icon: Icon(Icons.play_arrow, size: 18),
                      label: Text(isManualWatering ? 'Running...' : 'Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(
    String text,
    bool isSelected,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
