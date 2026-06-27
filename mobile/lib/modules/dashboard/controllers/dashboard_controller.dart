// WinPilot Dashboard Controller — Realtime metrics via WebSocket
import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/core/network/api_client.dart';
import 'package:winpilot_mobile/modules/dashboard/models/metrics_model.dart';

class DashboardController extends GetxController {
  static DashboardController get to => Get.find();

  // Observables
  final _metrics = Rxn<MetricsSnapshot>();
  final _isOnline = false.obs;
  final _isLoading = true.obs;
  final _notifications = <WinNotification>[].obs;
  
  // AI Command
  final aiTextCtrl = TextEditingController();
  final isAILoading = false.obs;

  final _healthScore = 0.obs;
  final _wsConnected = false.obs;

  MetricsSnapshot? get metrics => _metrics.value;
  bool get isOnline => _isOnline.value;
  bool get isLoading => _isLoading.value;
  List<WinNotification> get notifications => _notifications;
  int get healthScore => _healthScore.value;
  bool get wsConnected => _wsConnected.value;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  Stream<MetricsSnapshot?> get metricsStream => _metrics.stream;

  WebSocketChannel? _channel;

  @override
  void onInit() {
    super.onInit();
    _initDashboard();
  }

  @override
  void onClose() {
    _channel?.sink.close();
    super.onClose();
  }

  Future<void> _initDashboard() async {
    _isLoading.value = true;
    await _fetchInitialMetrics();
    await _connectWebSocket();
    _isLoading.value = false;
  }

  Future<void> _fetchInitialMetrics() async {
    try {
      final response = await ApiClient.to.get('/api/v1/metrics');
      if (response.statusCode == 200 && response.data['success'] == true) {
        _metrics.value = MetricsSnapshot.fromJson(response.data['data']);
        _healthScore.value = response.data['data']['health_score'] ?? 100;
        _isOnline.value = true;
      }
    } catch (e) {
      _isOnline.value = false;
    }
  }

  Future<void> _connectWebSocket() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final wsUrl = '${ApiClient.to.wsUrl}?token=$token';

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _wsConnected.value = true;
      _isOnline.value = true;

      _channel!.stream.listen(
        (data) => _handleWsMessage(data),
        onError: (_) => _onWsDisconnected(),
        onDone: _onWsDisconnected,
      );
    } catch (e) {
      _wsConnected.value = false;
    }
  }

  void _handleWsMessage(dynamic data) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final type = json['type'] as String;

      if (type == 'metrics.update') {
        final d = json['data'] as Map<String, dynamic>;
        _metrics.value = MetricsSnapshot.fromJson(d);
        _healthScore.value = (d['health_score'] as num?)?.toInt() ?? _healthScore.value;
        _isOnline.value = true;
      } else if (type == 'notification') {
        final d = json['data'] as Map<String, dynamic>;
        _notifications.insert(0, WinNotification.fromJson(d));
      }
    } catch (_) {}
  }

  void _onWsDisconnected() {
    _wsConnected.value = false;
    _isOnline.value = false;
    // Auto-reconnect after 3 seconds
    Future.delayed(const Duration(seconds: 3), _connectWebSocket);
  }

  // ─── Power Actions ───────────────────────────────────────────────────────

  Future<void> shutdown({int delaySeconds = 0}) async {
    await ApiClient.to.post('/api/v1/power/shutdown', data: {'delay_seconds': delaySeconds});
  }

  Future<void> restart({int delaySeconds = 0}) async {
    await ApiClient.to.post('/api/v1/power/restart', data: {'delay_seconds': delaySeconds});
  }

  Future<void> sleep() async {
    await ApiClient.to.post('/api/v1/power/sleep');
  }

  Future<void> lock() async {
    await ApiClient.to.post('/api/v1/power/lock');
  }

  Future<void> toggleMute() async {
    await ApiClient.to.post('/api/v1/media/mute');
  }

  Future<void> togglePlayPause() async {
    await ApiClient.to.post('/api/v1/media/playpause');
  }

  Future<void> submitAICommand() async {
    final text = aiTextCtrl.text.trim();
    if (text.isEmpty) return;

    isAILoading.value = true;
    try {
      final res = await ApiClient.to.post('/api/v1/ai/command', data: {'command': text});
      
      final msg = res.data['message'] ?? 'Perintah dipahami.';
      final isSuccess = res.data['success'] ?? true;
      
      Get.snackbar(
        isSuccess ? 'Keajaiban AI ✨' : 'AI Command',
        msg,
        backgroundColor: isSuccess ? WinPilotTheme.primaryBlue : WinPilotTheme.bgCard,
        colorText: Colors.white,
      );
      
      if (isSuccess) {
        aiTextCtrl.clear();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memproses bahasa natural.');
    } finally {
      isAILoading.value = false;
    }
  }

  @override
  Future<void> refresh() async {
    await _fetchInitialMetrics();
  }

  void markNotificationRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
    }
  }
}
