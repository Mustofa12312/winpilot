import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/network/api_client.dart';

class ClipboardController extends GetxController {
  final textCtrl = TextEditingController();
  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  @override
  void onClose() {
    textCtrl.dispose();
    super.onClose();
  }

  Future<void> getClipboard() async {
    _isLoading.value = true;
    try {
      final res = await ApiClient.to.get('/api/v1/clipboard');
      if (res.data != null && res.data['text'] != null) {
        textCtrl.text = res.data['text'].toString();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil clipboard dari PC');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> setClipboard() async {
    final text = textCtrl.text;
    if (text.isEmpty) return;

    _isLoading.value = true;
    try {
      await ApiClient.to.post('/api/v1/clipboard', data: {'text': text});
      Get.snackbar('Berhasil', 'Teks telah disalin ke PC Anda');
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengirim clipboard ke PC');
    } finally {
      _isLoading.value = false;
    }
  }
}
