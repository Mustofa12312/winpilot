// WinPilot Auth Controller — GetX
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winpilot_mobile/core/network/api_client.dart';
import 'package:winpilot_mobile/core/routes/routes.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final _isLoading = false.obs;
  final _error = ''.obs;
  final _isAuthenticated = false.obs;

  // Observables
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get isAuthenticated => _isAuthenticated.value;

  // Form controllers
  final ipController = TextEditingController();
  final portController = TextEditingController(text: '8080');
  final otpController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _checkSavedSession();
  }

  @override
  void onClose() {
    ipController.dispose();
    portController.dispose();
    otpController.dispose();
    super.onClose();
  }

  Future<void> _checkSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIP = prefs.getString('agent_ip');
    final savedToken = prefs.getString('access_token');
    final savedDeviceID = prefs.getString('device_id');

    if (savedIP != null && savedToken != null && savedDeviceID != null) {
      ApiClient.to.configure(baseUrl: 'http://$savedIP:${prefs.getInt('agent_port') ?? 8080}');
      _isAuthenticated.value = true;
      Get.offAllNamed(Routes.home);
    }
  }

  Future<void> connectToAgent() async {
    _error.value = '';
    final ip = ipController.text.trim();
    final port = int.tryParse(portController.text.trim()) ?? 8080;

    if (ip.isEmpty) {
      _error.value = 'Masukkan IP address Agent';
      return;
    }

    _isLoading.value = true;

    try {
      ApiClient.to.configure(baseUrl: 'http://$ip:$port');

      // Check if agent is reachable
      final health = await ApiClient.to.get('/health');
      if (health.statusCode == 200) {
        // Save connection info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('agent_ip', ip);
        await prefs.setInt('agent_port', port);

        // Go to pairing screen
        Get.toNamed(Routes.pairing);
      }
    } catch (e) {
      _error.value = 'Tidak dapat terhubung ke Agent. Pastikan WinPilot Agent berjalan di komputer dan IP address benar.';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> pairWithOTP(String otp) async {
    _error.value = '';
    _isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceName = 'My Device'; // TODO: get actual device name

      final response = await ApiClient.to.post('/api/v1/auth/pair', data: {
        'code': otp,
        'device_name': deviceName,
        'device_type': 'android',
        'os': 'Android',
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        await prefs.setString('access_token', data['access_token']);
        await prefs.setString('refresh_token', data['refresh_token']);
        await prefs.setString('device_id', data['device_id']);

        _isAuthenticated.value = true;
        Get.offAllNamed(Routes.home);
      } else {
        _error.value = response.data['message'] ?? 'Pairing gagal';
      }
    } catch (e) {
      _error.value = 'Kode OTP tidak valid atau sudah kedaluwarsa';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isAuthenticated.value = false;
    Get.offAllNamed(Routes.login);
  }
}
