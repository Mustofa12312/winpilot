import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/network/api_client.dart';
import 'package:winpilot_mobile/modules/plugins/models/plugin_model.dart';

class PluginController extends GetxController {
  final _plugins = <PluginModel>[].obs;
  final _isLoading = false.obs;
  final _isRunning = <String, bool>{}.obs;

  List<PluginModel> get plugins => _plugins;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadPlugins();
  }

  Future<void> loadPlugins() async {
    _isLoading.value = true;
    try {
      final response = await ApiClient.to.get('/api/v1/plugins');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'] ?? [];
        _plugins.value = data.map((e) => PluginModel.fromJson(e)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat plugin: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> togglePlugin(String id, bool isActive) async {
    try {
      final res = await ApiClient.to.put('/api/v1/plugins/$id/toggle', data: {
        'is_active': isActive,
      });
      if (res.statusCode == 200) {
        final index = _plugins.indexWhere((p) => p.manifest.id == id);
        if (index != -1) {
          final old = _plugins[index];
          _plugins[index] = PluginModel(
            manifest: old.manifest,
            isActive: isActive,
            status: old.status,
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengubah status plugin');
      loadPlugins();
    }
  }

  bool isRunning(String id) => _isRunning[id] ?? false;

  Future<void> runPlugin(String id) async {
    _isRunning[id] = true;
    try {
      final res = await ApiClient.to.post('/api/v1/plugins/$id/run');
      
      String output = '';
      if (res.data != null && res.data['output'] != null) {
        output = res.data['output'].toString();
      }

      if (res.statusCode == 200) {
        _showOutputDialog('Plugin Output', output.isEmpty ? 'Eksekusi selesai tanpa output.' : output);
      } else {
        _showOutputDialog('Plugin Error', output.isEmpty ? 'Eksekusi gagal.' : output, isError: true);
      }
    } catch (e) {
      _showOutputDialog('Error', 'Terjadi kesalahan jaringan atau eksekusi timeout: $e', isError: true);
    } finally {
      _isRunning[id] = false;
    }
  }

  void _showOutputDialog(String title, String message, {bool isError = false}) {
    Get.defaultDialog(
      title: title,
      content: Expanded(
        child: SingleChildScrollView(
          child: Text(
            message,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: isError ? Colors.red : Colors.white70,
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFF1E1E1E),
      titleStyle: const TextStyle(color: Colors.white),
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3498DB)),
        child: const Text('Tutup', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
