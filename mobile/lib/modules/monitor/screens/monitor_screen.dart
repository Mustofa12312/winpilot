import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/monitor/controllers/monitor_controller.dart';

class MonitorScreen extends StatelessWidget {
  const MonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(MonitorController());

    return Scaffold(
      backgroundColor: WinPilotTheme.bgBase,
      appBar: AppBar(
        title: const Text('Monitoring Center', style: TextStyle(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildChartCard(
              title: 'CPU Usage (%)',
              icon: Icons.memory_rounded,
              color: WinPilotTheme.primaryBlue,
              dataSelector: () => ctrl.cpuData,
            ),
            const SizedBox(height: 20),
            _buildChartCard(
              title: 'RAM Usage (%)',
              icon: Icons.developer_board_rounded,
              color: WinPilotTheme.warningOrange,
              dataSelector: () => ctrl.ramData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<FlSpot> Function() dataSelector,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WinPilotTheme.bgCard,
        borderRadius: Radii.lgBR,
        border: Border.all(color: WinPilotTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: WinPilotTheme.textPrimary)),
              const Spacer(),
              const Text('Live', style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: WinPilotTheme.dangerRed)),
              const SizedBox(width: 4),
              Container(width: 6, height: 6, decoration: const BoxDecoration(
                color: WinPilotTheme.dangerRed, shape: BoxShape.circle)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Obx(() {
              final spots = dataSelector();
              if (spots.isEmpty) {
                return const Center(child: Text('Menunggu data...', style: TextStyle(color: WinPilotTheme.textMuted)));
              }
              
              final minX = spots.first.x;
              final maxX = spots.last.x < minX + 60 ? minX + 60 : spots.last.x;

              return LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  minX: minX,
                  maxX: maxX,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: WinPilotTheme.borderSubtle,
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: 25,
                        getTitlesWidget: (val, meta) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text('${val.toInt()}%', style: const TextStyle(
                            color: WinPilotTheme.textMuted, fontSize: 10)),
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.3),
                            color.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }),
          ),
        ],
      ),
    );
  }
}
