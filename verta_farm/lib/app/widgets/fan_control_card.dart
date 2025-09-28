import 'package:flutter/material.dart';

class FanControlCard extends StatelessWidget {
  final bool fanStatus;
  final String fanMode;
  final String fanSpeed;
  final VoidCallback onToggleFan;
  final Function(String) onModeChanged;
  final Function(String) onSpeedChanged;

  const FanControlCard({
    super.key,
    required this.fanStatus,
    required this.fanMode,
    required this.fanSpeed,
    required this.onToggleFan,
    required this.onModeChanged,
    required this.onSpeedChanged,
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
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.air, color: Colors.green, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🌬 Fan / Exhaust Control',
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
                              color: fanStatus ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            fanStatus ? 'Running' : 'Stopped',
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
                  value: fanStatus,
                  onChanged: (_) => onToggleFan(),
                  activeColor: Colors.green,
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
                    fanMode == 'Auto',
                    () => onModeChanged('Auto'),
                    colorScheme,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildModeButton(
                    '🔓 Manual',
                    fanMode == 'Manual',
                    () => onModeChanged('Manual'),
                    colorScheme,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Speed Control (Manual Mode)
            if (fanMode == 'Manual') ...[
              Text(
                'Speed: $fanSpeed',
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
                    child: _buildSpeedButton(
                      'Low',
                      fanSpeed == 'Low',
                      () => onSpeedChanged('Low'),
                      colorScheme,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildSpeedButton(
                      'Medium',
                      fanSpeed == 'Medium',
                      () => onSpeedChanged('Medium'),
                      colorScheme,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _buildSpeedButton(
                      'High',
                      fanSpeed == 'High',
                      () => onSpeedChanged('High'),
                      colorScheme,
                    ),
                  ),
                ],
              ),
            ],

            // Auto Mode Info
            if (fanMode == 'Auto') ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Auto mode: Fan speed adjusts based on temperature and humidity',
                        style: TextStyle(fontSize: 12, color: Colors.green),
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
          color: isSelected ? Colors.green : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.withOpacity(0.3),
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

  Widget _buildSpeedButton(
    String text,
    bool isSelected,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
