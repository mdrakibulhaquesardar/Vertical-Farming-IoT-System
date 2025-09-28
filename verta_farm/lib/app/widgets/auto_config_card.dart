import 'package:flutter/material.dart';

class AutoConfigCard extends StatelessWidget {
  final bool autoMode;
  final bool autoWatering;
  final bool autoLighting;
  final bool smartMode;
  final VoidCallback onToggleAutoMode;
  final VoidCallback onToggleAutoWatering;
  final VoidCallback onToggleAutoLighting;
  final VoidCallback onToggleSmartMode;

  const AutoConfigCard({
    super.key,
    required this.autoMode,
    required this.autoWatering,
    required this.autoLighting,
    required this.smartMode,
    required this.onToggleAutoMode,
    required this.onToggleAutoWatering,
    required this.onToggleAutoLighting,
    required this.onToggleSmartMode,
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
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),

                  ),
                  child: Icon(Icons.settings, color: Colors.purple, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto Mode Config',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Configure automatic system control',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: autoMode,
                  onChanged: (_) => onToggleAutoMode(),
                  activeColor: Colors.purple,

                ),
              ],
            ),
            SizedBox(height: 20),

            // Auto Control Options
            if (autoMode) ...[
              _buildAutoOption(
                '💧 Auto Watering',
                'Enable auto-watering based on soil moisture or pH',
                autoWatering,
                onToggleAutoWatering,
                colorScheme,
              ),
              SizedBox(height: 12),
              _buildAutoOption(
                '💡 Auto Lighting',
                'Enable auto-light ON/OFF based on LUX reading',
                autoLighting,
                onToggleAutoLighting,
                colorScheme,
              ),
              SizedBox(height: 12),
              _buildAutoOption(
                '🧠 Smart Mode',
                'Enable AI to optimize system parameters',
                smartMode,
                onToggleSmartMode,
                colorScheme,
              ),
            ],

            // Manual Mode Info
            if (!autoMode) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Manual mode: All controls are manually operated',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAutoOption(
    String title,
    String description,
    bool isEnabled,
    VoidCallback onToggle,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEnabled
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEnabled
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (_) => onToggle(),
            activeColor: Colors.green,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
