import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/network/api_client.dart';

class DownloadTask {
  final String id;
  final String url;
  final String filename;
  final int totalBytes;
  final int downloaded;
  final double progress;
  final int speed;
  final String state;
  final String error;

  DownloadTask({
    required this.id, required this.url, required this.filename,
    required this.totalBytes, required this.downloaded,
    required this.progress, required this.speed,
    required this.state, required this.error,
  });

  factory DownloadTask.fromJson(Map<String, dynamic> json) {
    return DownloadTask(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      filename: json['filename'] ?? '',
      totalBytes: json['total_bytes'] ?? 0,
      downloaded: json['downloaded'] ?? 0,
      progress: (json['progress'] ?? 0).toDouble(),
      speed: json['speed'] ?? 0,
      state: json['state'] ?? '',
      error: json['error'] ?? '',
    );
  }
}

class DownloadController extends GetxController {
  final urlCtrl = TextEditingController();
  final filenameCtrl = TextEditingController();
  
  final _downloads = <DownloadTask>[].obs;
  final _isStarting = false.obs;
  Timer? _timer;

  List<DownloadTask> get downloads => _downloads;
  bool get isStarting => _isStarting.value;

  @override
  void onInit() {
    super.onInit();
    fetchDownloads();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => fetchDownloads());
  }

  @override
  void onClose() {
    urlCtrl.dispose();
    filenameCtrl.dispose();
    _timer?.cancel();
    super.onClose();
  }

  Future<void> fetchDownloads() async {
    try {
      final res = await ApiClient.to.get('/api/v1/downloads');
      if (res.data != null && res.data is List) {
        _downloads.value = (res.data as List).map((e) => DownloadTask.fromJson(e)).toList();
      }
    } catch (e) {
      // suppress background errors
    }
  }

  Future<void> startDownload() async {
    final url = urlCtrl.text.trim();
    if (url.isEmpty) return;

    _isStarting.value = true;
    try {
      await ApiClient.to.post('/api/v1/downloads/start', data: {
        'url': url,
        'filename': filenameCtrl.text.trim(),
      });
      urlCtrl.clear();
      filenameCtrl.clear();
      Get.snackbar('Berhasil', 'Unduhan telah dimulai');
      await fetchDownloads();
    } catch (e) {
      Get.snackbar('Gagal', 'Tidak dapat memulai unduhan');
    } finally {
      _isStarting.value = false;
    }
  }

  String formatSpeed(int bytesPerSec) {
    if (bytesPerSec < 1024) return '$bytesPerSec B/s';
    if (bytesPerSec < 1024 * 1024) return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(2)} MB/s';
  }
}
