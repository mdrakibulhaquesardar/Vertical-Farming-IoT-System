import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/pump_control_card.dart';
import '../../../widgets/light_control_card.dart';
import '../../../widgets/fan_control_card.dart';
import '../../../widgets/auto_config_card.dart';
import '../../../widgets/live_status_indicator.dart';
import '../controllers/control_controller.dart';

class ControlView extends GetView<ControlController> {
  const ControlView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scrollController = ScrollController();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Control Panel',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
              ),
              Text(
                'Manage your smart farm devices',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Live Status Indicator
              Obx(
                () => LiveStatusIndicator(
                  temperature: controller.temperature.value,
                  moisture: controller.moisture.value,
                  diseaseStatus: controller.diseaseStatus.value,
                  pumpStatus: controller.pumpStatus.value ? 'ON' : 'OFF',
                  lightStatus: controller.lightStatus.value ? 'ON' : 'OFF',
                  fanStatus: controller.fanStatus.value ? 'ON' : 'OFF',
                  pumpStatusColor: controller.pumpStatus.value
                      ? Colors.green
                      : Colors.grey,
                  lightStatusColor: controller.lightStatus.value
                      ? Colors.green
                      : Colors.grey,
                  fanStatusColor: controller.fanStatus.value
                      ? Colors.green
                      : Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Sensors & Controls',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              // Auto Mode Configuration
              Obx(
                () => AutoConfigCard(
                  autoMode: controller.autoMode.value,
                  autoWatering: controller.autoWatering.value,
                  autoLighting: controller.autoLighting.value,
                  smartMode: controller.smartMode.value,
                  onToggleAutoMode: controller.toggleAutoMode,
                  onToggleAutoWatering: controller.toggleAutoWatering,
                  onToggleAutoLighting: controller.toggleAutoLighting,
                  onToggleSmartMode: controller.toggleSmartMode,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Device Controls',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
              ),

              // Water Pump Control
              Obx(
                () => PumpControlCard(
                  pumpStatus: controller.pumpStatus.value,
                  flowRate: controller.flowRate.value,
                  pumpMode: controller.pumpMode.value,
                  isManualWatering: controller.isManualWatering.value,
                  manualWateringTime: controller.manualWateringTime.value,
                  onTogglePump: controller.togglePump,
                  onFlowRateChanged: controller.setFlowRate,
                  onModeChanged: controller.setPumpMode,
                  onManualWatering: controller.startManualWatering,
                  onManualWateringTimeChanged: controller.setManualWateringTime,
                ),
              ),
              const SizedBox(height: 16),

              // // Grow Light Control
              // Obx(
              //   () => LightControlCard(
              //     lightStatus: controller.lightStatus.value,
              //     lightMode: controller.lightMode.value,
              //     lightDuration: controller.lightDuration.value,
              //     lightSchedule: controller.lightSchedule,
              //     onToggleLight: controller.toggleLight,
              //     onModeChanged: controller.setLightMode,
              //     onDurationChanged: controller.setLightDuration,
              //     onScheduleChanged: controller.setLightSchedule,
              //   ),
              // ),
              // const SizedBox(height: 16),
              //
              // // Fan Control
              // Obx(
              //   () => FanControlCard(
              //     fanStatus: controller.fanStatus.value,
              //     fanMode: controller.fanMode.value,
              //     fanSpeed: controller.fanSpeed.value,
              //     onToggleFan: controller.toggleFan,
              //     onModeChanged: controller.setFanMode,
              //     onSpeedChanged: controller.setFanSpeed,
              //   ),
              // ),
              // const SizedBox(height: 16),

              // Schedule Settings (Optional Advanced)
              Text(
                'Schedule Settings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                'Set automated watering and lighting schedules',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 10),

              _buildScheduleCard(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
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
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.schedule, color: Colors.indigo, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📅 Schedule Setting',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Set automated watering and lighting schedules',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => Switch(
                    value: controller.scheduleEnabled.value,
                    onChanged: (_) => controller.toggleSchedule(),
                    activeColor: Colors.indigo,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Schedule Content
            Obx(() {
              if (!controller.scheduleEnabled.value) {
                return Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Schedule is disabled. Enable to set automated timings.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  // Watering Schedule
                  Text(
                    'Watering Schedule',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.wateringSchedule.map((time) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => controller.removeWateringTime(time),
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showTimePickerDialog(context),
                    icon: Icon(Icons.add, size: 16),
                    label: Text('Add Watering Time'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showTimePickerDialog(BuildContext context) {
    showTimePicker(context: context, initialTime: TimeOfDay.now()).then((time) {
      if (time != null) {
        final timeString =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        controller.addWateringTime(timeString);
      }
    });
  }
}
