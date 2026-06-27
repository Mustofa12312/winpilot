import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/apps/controllers/app_controller.dart';

class AppLauncherScreen extends StatelessWidget {
  const AppLauncherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AppLauncherController());

    return Scaffold(
      backgroundColor: WinPilotTheme.bgBase,
      appBar: AppBar(
        title: const Text('App Launcher', style: TextStyle(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Custom App Launch',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: WinPilotTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Masukkan nama aplikasi atau executable (.exe)',
              style: TextStyle(color: WinPilotTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: WinPilotTheme.bgCard,
                      borderRadius: Radii.lgBR,
                      border: Border.all(color: WinPilotTheme.borderSubtle),
                    ),
                    child: TextField(
                      controller: ctrl.textCtrl,
                      style: const TextStyle(color: WinPilotTheme.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'e.g. spotify.exe',
                        hintStyle: TextStyle(color: WinPilotTheme.textMuted),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onSubmitted: (val) => ctrl.launchApp(val),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Obx(() => ElevatedButton(
                  onPressed: ctrl.isLoading ? null : () => ctrl.launchApp(ctrl.textCtrl.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WinPilotTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: Radii.lgBR),
                  ),
                  child: ctrl.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.rocket_launch_rounded),
                )),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Quick Launch',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: WinPilotTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: ctrl.defaultApps.length,
              itemBuilder: (context, index) {
                final app = ctrl.defaultApps[index];
                return InkWell(
                  onTap: () => ctrl.launchApp(app['name'] as String),
                  borderRadius: Radii.lgBR,
                  child: Container(
                    decoration: BoxDecoration(
                      color: WinPilotTheme.bgCard,
                      borderRadius: Radii.lgBR,
                      border: Border.all(color: WinPilotTheme.borderSubtle),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(app['icon'] as IconData, size: 32, color: WinPilotTheme.primaryBlue),
                        const SizedBox(height: 8),
                        Text(
                          app['label'] as String,
                          style: const TextStyle(fontSize: 12, color: WinPilotTheme.textPrimary, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
