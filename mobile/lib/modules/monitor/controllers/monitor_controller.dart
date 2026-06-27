import 'dart:async';
import 'package:get/get.dart';
import 'package:winpilot_mobile/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:winpilot_mobile/modules/dashboard/models/metrics_model.dart';
import 'package:fl_chart/fl_chart.dart';

class MonitorController extends GetxController {
  final DashboardController _dashboardCtrl = Get.find<DashboardController>();
  
  // Keep last 60 seconds of data
  static const int maxDataPoints = 60;
  
  final _cpuData = <FlSpot>[].obs;
  final _ramData = <FlSpot>[].obs;
  
  List<FlSpot> get cpuData => _cpuData;
  List<FlSpot> get ramData => _ramData;
  
  late StreamSubscription _metricsSub;
  double _timeCounter = 0;

  @override
  void onInit() {
    super.onInit();
    
    // Seed initial data if available
    final initial = _dashboardCtrl.metrics;
    if (initial != null) {
      _addDataPoint(initial);
    }

    // Listen to realtime updates
    _metricsSub = _dashboardCtrl.metricsStream.listen((m) {
      if (m != null) {
        _addDataPoint(m);
      }
    });
  }

  void _addDataPoint(MetricsSnapshot m) {
    _timeCounter += 1;
    
    _cpuData.add(FlSpot(_timeCounter, m.cpu.usagePercent));
    _ramData.add(FlSpot(_timeCounter, m.ram.usedPercent));
    
    if (_cpuData.length > maxDataPoints) {
      _cpuData.removeAt(0);
      _ramData.removeAt(0);
    }
  }

  @override
  void onClose() {
    _metricsSub.cancel();
    super.onClose();
  }
}
