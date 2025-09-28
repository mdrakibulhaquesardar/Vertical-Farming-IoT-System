import 'package:flutter/material.dart';

class SystemStatusCard extends StatelessWidget {
  final String title;
  final String status;
  final IconData icon;
  final Color iconColor;
  final bool isToggleable;
  final bool? isOn;
  final VoidCallback? onToggle;
  final String? additionalInfo;

  const SystemStatusCard({
    Key? key,
    required this.title,
    required this.status,
    required this.icon,
    required this.iconColor,
    this.isToggleable = false,
    this.isOn,
    this.onToggle,
    this.additionalInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine if device is ON or OFF
    final bool isDeviceOn = status.toUpperCase() == 'ON';
    final bool isDisabled = isToggleable && !isDeviceOn;

    return Container(
      decoration: BoxDecoration(
        color: isDisabled
            ? colorScheme.surface.withOpacity(0.5)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDisabled
              ? colorScheme.outline.withOpacity(0.1)
              : colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDisabled
                    ? iconColor.withOpacity(0.05)
                    : iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDisabled ? iconColor.withOpacity(0.4) : iconColor,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDisabled
                          ? colorScheme.onSurface.withOpacity(0.5)
                          : colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDisabled
                          ? colorScheme.onSurface.withOpacity(0.4)
                          : colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  if (additionalInfo != null) ...[
                    SizedBox(height: 2),
                    Text(
                      additionalInfo!,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDisabled
                            ? colorScheme.onSurface.withOpacity(0.3)
                            : colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isToggleable && isOn != null && onToggle != null)
              Opacity(
                opacity: isDisabled ? 0.5 : 1.0,
                child: Switch(
                  value: isOn!,
                  onChanged: (_) => onToggle!(),
                  activeColor: colorScheme.primary,
                  inactiveThumbColor: isDisabled
                      ? colorScheme.onSurface.withOpacity(0.3)
                      : null,
                  inactiveTrackColor: isDisabled
                      ? colorScheme.onSurface.withOpacity(0.1)
                      : null,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
