import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/graphs_controller.dart';

class GraphsView extends GetView<GraphsController> {
  const GraphsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Sensor Graphs',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Visualize your farm data',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),

              // Period Filter
              Obx(
                () => Row(
                  children: [
                    for (final period in controller.periods)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(period),
                          selected: controller.selectedPeriod.value == period,
                          onSelected: (_) => controller.changePeriod(period),
                          selectedColor: const Color(0xFF4CAF50),
                          labelStyle: GoogleFonts.poppins(
                            color: controller.selectedPeriod.value == period
                                ? Colors.white
                                : Colors.grey[700],
                          ),
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Graphs
              Expanded(
                child: ListView(
                  children: [
                    _buildLineChart(
                      title: 'Temperature (°C)',
                      color: const Color(0xFFFF5722),
                      spots: controller.getTemperatureSpots(),
                    ),
                    _buildLineChart(
                      title: 'Humidity (%)',
                      color: const Color(0xFF2196F3),
                      spots: controller.getHumiditySpots(),
                    ),
                    _buildLineChart(
                      title: 'Light Level (lux)',
                      color: const Color(0xFFFFC107),
                      spots: controller.getLightSpots(),
                    ),
                    _buildLineChart(
                      title: 'Moisture (%)',
                      color: const Color(0xFF00BCD4),
                      spots: controller.getMoistureSpots(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart({
    required String title,
    required Color color,
    required List<FlSpot> spots,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: spots.isNotEmpty ? spots.length.toDouble() - 1 : 1,
                minY: spots.isNotEmpty
                    ? spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 2
                    : 0,
                maxY: spots.isNotEmpty
                    ? spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 2
                    : 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
