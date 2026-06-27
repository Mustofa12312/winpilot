// Disk Bars — Visual storage usage per drive
import 'package:flutter/material.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/dashboard/models/metrics_model.dart';

class DiskBars extends StatelessWidget {
  final List<DiskMetrics> disks;
  const DiskBars({super.key, required this.disks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WinPilotTheme.bgCard,
        borderRadius: Radii.lgBR,
        border: Border.all(color: WinPilotTheme.borderSubtle),
      ),
      child: Column(
        children: disks.map((d) => _buildDiskItem(d)).toList(),
      ),
    );
  }

  Widget _buildDiskItem(DiskMetrics disk) {
    final pct = disk.usedPercent / 100;
    final color = pct > 0.9 ? WinPilotTheme.dangerRed
      : pct > 0.75 ? WinPilotTheme.warningOrange
      : WinPilotTheme.successGreen;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: WinPilotTheme.bgSurface,
                  borderRadius: Radii.smBR,
                  border: Border.all(color: WinPilotTheme.borderSubtle),
                ),
                child: Text(disk.drive, style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: WinPilotTheme.textPrimary)),
              ),
              const SizedBox(width: 8),
              Text(disk.label, style: const TextStyle(fontSize: 12, color: WinPilotTheme.textMuted)),
              const Spacer(),
              Text(
                '${disk.usedGB.toStringAsFixed(0)} / ${disk.totalGB.toStringAsFixed(0)} GB',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: WinPilotTheme.textSecondary),
              ),
              const SizedBox(width: 8),
              Text('${disk.usedPercent.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: Radii.smBR,
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              backgroundColor: WinPilotTheme.bgSurface,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
