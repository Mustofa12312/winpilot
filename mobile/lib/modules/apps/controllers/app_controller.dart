import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/network/api_client.dart';

class AppLauncherController extends GetxController {
  final textCtrl = TextEditingController();
  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  final defaultApps = [
    {'name': 'notepad.exe', 'label': 'Notepad', 'icon': Icons.edit_document},
    {'name': 'calc.exe', 'label': 'Calculator', 'icon': Icons.calculate_rounded},
    {'name': 'chrome.exe', 'label': 'Chrome', 'icon': Icons.public_rounded},
    {'name': 'msedge.exe', 'label': 'Edge', 'icon': Icons.explore_rounded},
    {'name': 'explorer.exe', 'label': 'File Explorer', 'icon': Icons.folder_rounded},
    {'name': 'cmd.exe', 'label': 'Command Prompt', 'icon': Icons.terminal_rounded},
    {'name': 'taskmgr.exe', 'label': 'Task Manager', 'icon': Icons.insights_rounded},
    {'name': 'mspaint.exe', 'label': 'Paint', 'icon': Icons.palette_rounded},
  ];

  @override
  void onClose() {
    textCtrl.dispose();
    super.onClose();
  }

  Future<void> launchApp(String exeName) async {
    if (exeName.isEmpty) return;

    _isLoading.value = true;
    try {
      await ApiClient.to.post('/api/v1/apps/launch', data: {'name': exeName});
      Get.snackbar('Sukses', 'Perintah dikirim untuk membuka $exeName');
      textCtrl.clear();
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuka aplikasi. Pastikan aplikasi terinstal di PC.');
    } finally {
      _isLoading.value = false;
    }
  }
}
