// Quick Action Grid — Shutdown, Restart, Lock, Screenshot, etc.
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/dashboard/controllers/dashboard_controller.dart';

class QuickActionGrid extends StatelessWidget {
  final DashboardController ctrl;
  const QuickActionGrid({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final actions = _buildActions(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: actions.length,
      itemBuilder: (_, i) => actions[i],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      _ActionTile(
        icon: Icons.power_settings_new_rounded,
        label: 'Shutdown',
        color: WinPilotTheme.dangerRed,
        onTap: () => _confirmAction(context, 'Shutdown', 'Yakin ingin mematikan komputer?', ctrl.shutdown),
      ),
      _ActionTile(
        icon: Icons.restart_alt_rounded,
        label: 'Restart',
        color: WinPilotTheme.warningOrange,
        onTap: () => _confirmAction(context, 'Restart', 'Yakin ingin restart komputer?', ctrl.restart),
      ),
      _ActionTile(
        icon: Icons.lock_rounded,
        label: 'Lock',
        color: WinPilotTheme.primaryBlue,
        onTap: ctrl.lock,
      ),
      _ActionTile(
        icon: Icons.bedtime_rounded,
        label: 'Sleep',
        color: const Color(0xFF9B59B6),
        onTap: ctrl.sleep,
      ),
      _ActionTile(
        icon: Icons.screenshot_rounded,
        label: 'Screenshot',
        color: WinPilotTheme.accentCyan,
        onTap: () {},
      ),
      _ActionTile(
        icon: Icons.content_paste_rounded,
        label: 'Clipboard',
        color: WinPilotTheme.successGreen,
        onTap: () {},
      ),
    ];
  }

  void _confirmAction(
    BuildContext context, String title, String message, Future<void> Function() action) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: WinPilotTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: Radii.lgBR),
        title: Text(title, style: const TextStyle(
          color: WinPilotTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text(message, style: const TextStyle(color: WinPilotTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: WinPilotTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              action();
            },
            style: ElevatedButton.styleFrom(backgroundColor: WinPilotTheme.dangerRed),
            child: Text(title),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: WinPilotTheme.bgCard,
          borderRadius: Radii.lgBR,
          border: Border.all(color: WinPilotTheme.borderSubtle),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: Radii.lgBR,
            splashColor: color.withOpacity(0.15),
            highlightColor: color.withOpacity(0.08),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(label, style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: WinPilotTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
