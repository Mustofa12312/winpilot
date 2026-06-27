import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/dashboard/controllers/dashboard_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: WinPilotTheme.bgBase,
      appBar: AppBar(
        title: const Text('Notification History', style: TextStyle(fontSize: 16)),
      ),
      body: Obx(() {
        final notifs = ctrl.notifications.reversed.toList();
        
        if (notifs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_rounded, size: 64, color: WinPilotTheme.textMuted),
                SizedBox(height: 16),
                Text('Tidak ada riwayat notifikasi', style: TextStyle(color: WinPilotTheme.textSecondary)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: notifs.length,
          itemBuilder: (context, index) {
            final n = notifs[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: n.isRead ? WinPilotTheme.bgCard : WinPilotTheme.primaryBlue.withValues(alpha: 0.08),
                borderRadius: Radii.mdBR,
                border: Border.all(
                  color: n.isRead ? WinPilotTheme.borderSubtle : WinPilotTheme.primaryBlue.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    n.isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                    color: n.isRead ? WinPilotTheme.textMuted : WinPilotTheme.primaryBlue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                n.title,
                                style: TextStyle(
                                  fontWeight: n.isRead ? FontWeight.w500 : FontWeight.bold,
                                  color: WinPilotTheme.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              _formatTime(n.createdAt),
                              style: const TextStyle(fontSize: 11, color: WinPilotTheme.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          n.body,
                          style: const TextStyle(fontSize: 13, color: WinPilotTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
