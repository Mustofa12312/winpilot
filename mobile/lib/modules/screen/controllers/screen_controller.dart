import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:winpilot_mobile/core/network/api_client.dart';

class ScreenController extends GetxController {
  final imageBytes = Rx<Uint8List?>(null);
  final isStreaming = false.obs;
  final fps = 0.obs;

  Timer? _pollingTimer;
  DateTime _lastFrameTime = DateTime.now();
  int _frameCount = 0;
  Timer? _fpsTimer;

  @override
  void onInit() {
    super.onInit();
    startStreaming();
  }

  @override
  void onClose() {
    stopStreaming();
    super.onClose();
  }

  void startStreaming() {
    if (isStreaming.value) return;
    isStreaming.value = true;
    
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      fps.value = _frameCount;
      _frameCount = 0;
    });

    _pollFrame();
  }

  void stopStreaming() {
    isStreaming.value = false;
    _pollingTimer?.cancel();
    _fpsTimer?.cancel();
  }

  Future<void> _pollFrame() async {
    if (!isStreaming.value) return;

    try {
      final response = await ApiClient.to.dio.get<List<int>>(
        '/api/v1/screen/capture',
        options: Options(responseType: ResponseType.bytes),
      );
      
      if (response.data != null) {
        imageBytes.value = Uint8List.fromList(response.data!);
        _frameCount++;
      }
    } catch (e) {
      // Ignore errors during streaming to prevent crash, just retry
    }

    // Schedule next frame (e.g. 50ms = ~20 FPS)
    _pollingTimer = Timer(const Duration(milliseconds: 50), _pollFrame);
  }
}
