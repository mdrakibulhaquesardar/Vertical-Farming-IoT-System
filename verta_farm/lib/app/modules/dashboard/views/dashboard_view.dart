import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../widgets/sensor_card.dart';
import '../../../widgets/system_status_card.dart';
import '../../../widgets/mini_graph.dart';
import '../../../widgets/plant_health_card.dart';
import '../../../widgets/thresholds_edit_modal.dart';
import '../../../widgets/water_tank_card.dart';
import '../../../widgets/water_flow_card.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Check device status and show appropriate screen
    return Obx(() {
      if (!controller.isDeviceOnline.value) {
        return _buildDeviceNotFoundScreen(context, theme);
      }

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.background,
              colorScheme.surface.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello Nirob 👋',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onBackground,
                                fontWeight: FontWeight.w600,
                                fontSize:
                                    MediaQuery.of(context).size.width > 600
                                    ? 28
                                    : 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Welcome back to your smart farm',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Device and Connection Status Icons
                            Obx(
                              () => Row(
                                children: [
                                  // WebSocket Connection Status Icon
                                  Tooltip(
                                    message: controller.connectionStatus,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: controller.isWebSocketConnected
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        border: Border.all(
                                          color: controller.isWebSocketConnected
                                              ? Colors.green
                                              : Colors.red,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        controller.isWebSocketConnected
                                            ? Icons.wifi
                                            : Icons.wifi_off,
                                        size: 12,
                                        color: controller.isWebSocketConnected
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Device Status Icon
                                  Tooltip(
                                    message: controller.deviceStatus.value,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: controller.isDeviceOnline.value
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.orange.withOpacity(0.1),
                                        border: Border.all(
                                          color: controller.isDeviceOnline.value
                                              ? Colors.green
                                              : Colors.orange,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        controller.isDeviceOnline.value
                                            ? Icons.device_hub
                                            : Icons.device_unknown,
                                        size: 12,
                                        color: controller.isDeviceOnline.value
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                  ),
                                  if (!controller.isWebSocketConnected) ...[
                                    const SizedBox(width: 8),
                                    Tooltip(
                                      message: 'Reconnect',
                                      child: GestureDetector(
                                        onTap: controller.reconnectWebSocket,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.blue.withOpacity(0.1),
                                            border: Border.all(
                                              color: Colors.blue,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.refresh,
                                            size: 16,
                                            color: Colors.blue,
                                          ),
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
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTfag4gUez3IKlZ--XRWoX7LzajKjsI0So6mqyxgDF8rm4A80Pu9hfmO2CPj_7d4bdhOXQ&usqp=CAU',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Plant Health Card
                  Obx(
                    () => PlantHealthCard(
                      healthStatus: controller.plantHealth.value,
                      healthIcon: controller.healthIcon.value,
                      healthColor: Color(controller.healthColor.value),
                      aiSummary: controller.aiSummary.value,
                      diseaseDetected: controller.diseaseDetected.value,
                      onScanNow: controller.scanNow,
                      onViewDetails: controller.diseaseDetected.value
                          ? () => Fluttertoast.showToast(
                              msg: 'Showing disease details...',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.blue,
                              textColor: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Real-time Sensor Readings Section
                  Row(
                    children: [
                      Text(
                        '🌡 Real-time Sensor',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onBackground,
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.width > 600
                              ? 20
                              : 18,
                        ),
                      ),
                      const Spacer(),
                      Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: controller.refreshThresholds,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (controller.isThresholdsLoading) ...[
                                      SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.blue,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                    ] else ...[
                                      Icon(
                                        Icons.refresh,
                                        size: 12,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      'Refresh Thresholds',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Sensor Cards Grid - Responsive
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Determine number of columns based on screen width
                      int crossAxisCount = 2;
                      if (constraints.maxWidth > 600) {
                        crossAxisCount = 3;
                      }
                      if (constraints.maxWidth > 900) {
                        crossAxisCount = 4;
                      }

                      return Obx(
                        () => GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: constraints.maxWidth > 600
                              ? 1.2
                              : 1.4,
                          children: [
                            SensorCard(
                              title: 'Temperature',
                              value: controller.temperature.value
                                  .toStringAsFixed(1),
                              unit: '°C',
                              icon: Icons.thermostat,
                              iconColor: Colors.red,
                              status: controller.isTemperatureOk
                                  ? 'OK'
                                  : controller.temperature.value >
                                        controller.temperatureMax
                                  ? 'Critical'
                                  : 'Warning',
                            ),
                            SensorCard(
                              title: 'Humidity',
                              value: controller.humidity.value.toStringAsFixed(
                                0,
                              ),
                              unit: '%',
                              icon: Icons.water_drop,
                              iconColor: Colors.blue,
                              status: controller.isHumidityOk
                                  ? 'OK'
                                  : 'Warning',
                            ),
                            SensorCard(
                              title: 'Light Level',
                              value: controller.getLightLevelText(),
                              unit: '',
                              icon: Icons.lightbulb,
                              iconColor: Colors.amber,
                              status: controller.isLightOk ? 'OK' : 'Warning',
                            ),
                            SensorCard(
                              title: 'Water Level',
                              value: controller.getWaterLevelText(),
                              unit: '',
                              icon: Icons.water,
                              iconColor: Colors.cyan,
                              status: controller.isWaterOk ? 'OK' : 'Critical',
                            ),
                            SensorCard(
                              title: 'Water Flow',
                              value: controller.avgLitersPerMin.value
                                  .toStringAsFixed(1),
                              unit: 'L/min',
                              icon: Icons.water_drop_outlined,
                              iconColor: Colors.teal,
                              status: controller.waterFlow.value > 0
                                  ? 'Active'
                                  : 'Inactive',
                            ),
                            WaterTankCard(
                              title: 'Total Water Used',
                              currentLiters: controller.totalLiters.value,
                              maxLiters: 1000.0,
                              unit: 'L',
                              icon: Icons.local_drink,
                              iconColor: Colors.indigo,
                              status: controller.totalLiters.value > 0
                                  ? 'OK'
                                  : 'Empty',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),

                  // Optional: pH and EC Levels
                  Text(
                    '🧪 Nutrient Levels',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.width > 600
                          ? 20
                          : 18,
                    ),
                  ),
                  const SizedBox(height: 12),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      // For larger screens, show in a row; for smaller screens, show in column
                      if (constraints.maxWidth > 600) {
                        return Obx(
                          () => Row(
                            children: [
                              Expanded(
                                child: SensorCard(
                                  title: 'pH Level',
                                  value: controller.phLevel.value
                                      .toStringAsFixed(1),
                                  unit: '',
                                  icon: Icons.science,
                                  iconColor: Colors.purple,
                                  status: controller.isPhOk ? 'OK' : 'Warning',
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: SensorCard(
                                  title: 'TDS Level',
                                  value: controller.tdsLevel.value
                                      .toStringAsFixed(0),
                                  unit: 'ppm',
                                  icon: Icons.water_drop,
                                  iconColor: Colors.orange,
                                  status: controller.isTdsOk ? 'OK' : 'Warning',
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Obx(
                          () => Column(
                            children: [
                              SensorCard(
                                title: 'pH Level',
                                value: controller.phLevel.value.toStringAsFixed(
                                  1,
                                ),
                                unit: '',
                                icon: Icons.science,
                                iconColor: Colors.purple,
                                status: controller.isPhOk ? 'OK' : 'Warning',
                              ),
                              SizedBox(height: 12),
                              SensorCard(
                                title: 'TDS Level',
                                value: controller.tdsLevel.value
                                    .toStringAsFixed(0),
                                unit: 'ppm',
                                icon: Icons.water_drop,
                                iconColor: Colors.orange,
                                status: controller.isTdsOk ? 'OK' : 'Warning',
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  // System Status Section
                  const SizedBox(height: 18),
                  Text(
                    '💧 System Status',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.width > 600
                          ? 20
                          : 18,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Obx(
                    () => Column(
                      children: [
                        SystemStatusCard(
                          title: 'Water Pump',
                          status: controller.pumpStatus.value ? 'ON' : 'OFF',
                          icon: Icons.water,
                          iconColor: Colors.blue,
                          isToggleable: !controller.isControllingPump,
                          isOn: controller.pumpStatus.value,
                          onToggle: controller.togglePump,
                          additionalInfo: controller.pumpStatus.value
                              ? 'Last watered: ${controller.getTimeAgo(controller.lastWateredTime.value)}'
                              : controller.isControllingPump
                              ? 'Controlling...'
                              : null,
                        ),
                        SizedBox(height: 8),
                        SystemStatusCard(
                          title: 'Grow Lights',
                          status: controller.growLightStatus.value
                              ? 'ON'
                              : 'OFF',
                          icon: Icons.lightbulb,
                          iconColor: Colors.amber,
                          isToggleable: !controller.isControllingLight,
                          isOn: controller.growLightStatus.value,
                          onToggle: controller.toggleGrowLight,
                          additionalInfo: controller.growLightStatus.value
                              ? 'Duration: ${controller.growLightDuration.value.inHours}h'
                              : controller.isControllingLight
                              ? 'Controlling...'
                              : null,
                        ),
                        SizedBox(height: 8),
                        SystemStatusCard(
                          title: 'Motor',
                          status: controller.motorStatus.value ? 'ON' : 'OFF',
                          icon: Icons.settings,
                          iconColor: Colors.orange,
                          isToggleable: !controller.isControllingMotor,
                          isOn: controller.motorStatus.value,
                          onToggle: controller.toggleMotor,
                          additionalInfo: controller.motorStatus.value
                              ? 'Motor running'
                              : controller.isControllingMotor
                              ? 'Controlling...'
                              : 'Motor stopped',
                        ),
                        SizedBox(height: 8),
                        SystemStatusCard(
                          title: 'Ventilation',
                          status: controller.ventilationStatus.value,
                          icon: Icons.air,
                          iconColor: Colors.green,
                          additionalInfo: 'Auto mode active',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Thresholds Information Section
                  Row(
                    children: [
                      Text(
                        '📊 Current Thresholds',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onBackground,
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.width > 600
                              ? 20
                              : 18,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) =>
                                ThresholdsEditModal(deviceId: 'esp32-001'),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
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
                              Icon(Icons.edit, size: 16, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Responsive grid for thresholds
                        int crossAxisCount = 2;
                        if (constraints.maxWidth > 600) {
                          crossAxisCount = 3;
                        }
                        if (constraints.maxWidth > 900) {
                          crossAxisCount = 6;
                        }

                        return Obx(
                          () => GridView.count(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: constraints.maxWidth > 600
                                ? 1.0
                                : 0.8,
                            children: [
                              _buildThresholdItem(
                                'Temperature',
                                '${controller.temperatureMin.toStringAsFixed(1)}°C - ${controller.temperatureMax.toStringAsFixed(1)}°C',
                                Icons.thermostat,
                                Colors.red,
                              ),
                              _buildThresholdItem(
                                'Humidity',
                                '${controller.humidityMin.toStringAsFixed(0)}% - ${controller.humidityMax.toStringAsFixed(0)}%',
                                Icons.water_drop,
                                Colors.blue,
                              ),
                              _buildThresholdItem(
                                'Light',
                                '${controller.lightMin.toStringAsFixed(0)} - ${controller.lightMax.toStringAsFixed(0)}',
                                Icons.lightbulb,
                                Colors.amber,
                              ),
                              _buildThresholdItem(
                                'Water',
                                '${controller.waterMin.toStringAsFixed(0)}% - ${controller.waterMax.toStringAsFixed(0)}%',
                                Icons.water,
                                Colors.cyan,
                              ),
                              _buildThresholdItem(
                                'pH',
                                '${controller.phMin.toStringAsFixed(1)} - ${controller.phMax.toStringAsFixed(1)}',
                                Icons.science,
                                Colors.purple,
                              ),
                              _buildThresholdItem(
                                'TDS',
                                '${controller.tdsMin.toStringAsFixed(0)} - ${controller.tdsMax.toStringAsFixed(0)} ppm',
                                Icons.water_drop,
                                Colors.orange,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Mini Graphs Section
                  Text(
                    '📈 Quick Trends (Last 5 hours)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                      fontSize: MediaQuery.of(context).size.width > 600
                          ? 20
                          : 18,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Obx(
                    () => Column(
                      children: [
                        MiniGraph(
                          data: controller.temperatureHistory,
                          lineColor: Colors.red,
                          fillColor: Colors.red.withOpacity(0.1),
                          title: 'Temperature',
                          value: controller.temperature.value.toStringAsFixed(
                            1,
                          ),
                          unit: '°C',
                        ),
                        SizedBox(height: 8),
                        MiniGraph(
                          data: controller.humidityHistory,
                          lineColor: Colors.blue,
                          fillColor: Colors.blue.withOpacity(0.1),
                          title: 'Humidity',
                          value: controller.humidity.value.toStringAsFixed(0),
                          unit: '%',
                        ),
                        SizedBox(height: 8),
                        MiniGraph(
                          data: controller.moistureHistory,
                          lineColor: Colors.cyan,
                          fillColor: Colors.cyan.withOpacity(0.1),
                          title: 'Moisture',
                          value: controller.waterLevel.value.toStringAsFixed(0),
                          unit: '%',
                        ),
                        SizedBox(height: 8),
                        MiniGraph(
                          data: controller.waterFlowHistory,
                          lineColor: Colors.teal,
                          fillColor: Colors.teal.withOpacity(0.1),
                          title: 'Water Flow',
                          value: controller.waterFlow.value.toStringAsFixed(1),
                          unit: 'L/min',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildThresholdItem(
    String title,
    String range,
    IconData icon,
    Color color,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;

        return Container(
          padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(isLargeScreen ? 10 : 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: isLargeScreen ? 24 : 20),
              ),
              SizedBox(height: isLargeScreen ? 10 : 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: isLargeScreen ? 15 : 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              SizedBox(height: isLargeScreen ? 6 : 4),
              Text(
                range,
                style: TextStyle(
                  fontSize: isLargeScreen ? 12 : 11,
                  color: color.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: isLargeScreen ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeviceNotFoundScreen(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.background,
            theme.colorScheme.surface.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Device offline image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/hydrp.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.device_unknown,
                        size: 60,
                        color: Colors.orange,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Device Not Found',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Your device is offline or not responding.\nPlease check the connection and try again.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Device status indicator
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: controller.isDeviceOnline.value
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: controller.isDeviceOnline.value
                          ? Colors.green.withOpacity(0.3)
                          : Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: controller.isDeviceOnline.value
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        controller.isDeviceOnline.value
                            ? 'Device Online'
                            : 'Device Offline',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: controller.isDeviceOnline.value
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Retry button
              ElevatedButton.icon(
                onPressed: () {
                  controller.reconnectWebSocket();
                  controller.requestCurrentStatus();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Help text
              Text(
                'Make sure your device is powered on and \n connected to WiFi',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
