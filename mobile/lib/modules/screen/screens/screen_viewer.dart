import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/screen/controllers/screen_controller.dart';

class ScreenViewerScreen extends StatelessWidget {
  const ScreenViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ScreenController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Live Screen', style: TextStyle(color: Colors.white)),
        actions: [
          Obx(() => Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${ctrl.fps.value} FPS',
                style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ))
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 5.0,
          child: Obx(() {
            if (ctrl.imageBytes.value == null) {
              return const CircularProgressIndicator(color: WinPilotTheme.primaryBlue);
            }
            return Image.memory(
              ctrl.imageBytes.value!,
              gaplessPlayback: true, // Prevents flickering between frames
              fit: BoxFit.contain,
            );
          }),
        ),
      ),
    );
  }
}
