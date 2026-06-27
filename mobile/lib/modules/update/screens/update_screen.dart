import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/update/controllers/update_controller.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(UpdateController());

    return Scaffold(
      backgroundColor: WinPilotTheme.bgBase,
      appBar: AppBar(
        title: const Text('Windows Update', style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: ctrl.checkUpdate,
          )
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: WinPilotTheme.primaryBlue),
                const SizedBox(height: 16),
                Text('Mengecek status sistem...', style: TextStyle(color: WinPilotTheme.textSecondary)),
              ],
            ),
          );
        }

        final info = ctrl.info;
        if (info == null) {
          return const Center(child: Text('Gagal mengecek Windows Update', style: TextStyle(color: WinPilotTheme.textMuted)));
        }

        final isWarning = info.count > 0 || info.status.contains('Gagal');
        final iconColor = isWarning ? WinPilotTheme.warningOrange : WinPilotTheme.successGreen;
        final iconData = isWarning ? Icons.system_update_rounded : Icons.check_circle_rounded;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconColor, size: 64),
                ),
                const SizedBox(height: 24),
                Text(
                  info.status,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: WinPilotTheme.textPrimary, fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isWarning 
                      ? 'Ada ${info.count} pembaruan yang siap diunduh di PC Anda. Buka menu Settings > Windows Update di PC Anda untuk memprosesnya.'
                      : 'PC Anda berada dalam kondisi prima dan mutakhir. Tidak ada aksi yang diperlukan.',
                  style: const TextStyle(color: WinPilotTheme.textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: ctrl.checkUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WinPilotTheme.bgCard,
                      foregroundColor: WinPilotTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: Radii.lgBR,
                        side: BorderSide(color: WinPilotTheme.borderSubtle),
                      ),
                    ),
                    child: const Text('Cek Ulang'),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
