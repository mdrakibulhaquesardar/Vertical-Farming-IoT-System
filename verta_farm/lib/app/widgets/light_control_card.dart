import 'package:flutter/material.dart';

class LightControlCard extends StatelessWidget {
  final bool lightStatus;
  final String lightMode;
  final int lightDuration;
  final Map<String, String> lightSchedule;
  final VoidCallback onToggleLight;
  final Function(String) onModeChanged;
  final Function(int) onDurationChanged;
  final Function(String, String) onScheduleChanged;

  const LightControlCard({
    super.key,
    required this.lightStatus,
    required this.lightMode,
    required this.lightDuration,
    required this.lightSchedule,
    required this.onToggleLight,
    required this.onModeChanged,
    required this.onDurationChanged,
    required this.onScheduleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.lightbulb, color: Colors.amber, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 Grow Light Control',
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
                              color: lightStatus ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            lightStatus ? 'ON' : 'OFF',
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
                  value: lightStatus,
                  onChanged: (_) => onToggleLight(),
                  activeColor: Colors.amber,
                ),
              ],
            ),
            SizedBox(height: 20),

            // Mode Selection
            Text(
              'Mode',
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
                  child: _buildModeButton(
                    '🔒 Auto',
                    lightMode == 'Auto',
                    () => onModeChanged('Auto'),
                    colorScheme,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildModeButton(
                    '🔓 Manual',
                    lightMode == 'Manual',
                    () => onModeChanged('Manual'),
                    colorScheme,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Duration Control
            Text(
              'Duration: ${lightDuration}h/day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.amber,
                inactiveTrackColor: Colors.amber.withOpacity(0.2),
                thumbColor: Colors.amber,
                overlayColor: Colors.amber.withOpacity(0.1),
                trackHeight: 4,
              ),
              child: Slider(
                value: lightDuration.toDouble(),
                min: 6,
                max: 18,
                divisions: 12,
                onChanged: (value) => onDurationChanged(value.toInt()),
              ),
            ),
            SizedBox(height: 16),

            // Schedule (Auto Mode)
            if (lightMode == 'Auto') ...[
              Text(
                'Schedule',
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
                    child: _buildTimeButton(
                      'Start: ${lightSchedule['start']}',
                      () => _showTimePicker(context, true),
                      colorScheme,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeButton(
                      'End: ${lightSchedule['end']}',
                      () => _showTimePicker(context, false),
                      colorScheme,
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
          color: isSelected ? Colors.amber : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.grey.withOpacity(0.3),
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

  Widget _buildTimeButton(
    String text,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  void _showTimePicker(BuildContext context, bool isStart) {
    final currentTime = isStart
        ? _parseTimeString(lightSchedule['start']!)
        : _parseTimeString(lightSchedule['end']!);

    showTimePicker(context: context, initialTime: currentTime).then((time) {
      if (time != null) {
        final timeString =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        if (isStart) {
          onScheduleChanged(timeString, lightSchedule['end']!);
        } else {
          onScheduleChanged(lightSchedule['start']!, timeString);
        }
      }
    });
  }

  TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
