// Metric Card Widget — CPU, RAM, etc.
import 'package:flutter/material.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final double percent; // 0.0 to 1.0
  final Gradient gradient;
  final IconData icon;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.percent,
    required this.gradient,
    required this.icon,
  });

  Color get _progressColor {
    if (percent > 0.9) return WinPilotTheme.dangerRed;
    if (percent > 0.7) return WinPilotTheme.warningOrange;
    return WinPilotTheme.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WinPilotTheme.bgCard,
        borderRadius: Radii.lgBR,
        border: Border.all(color: WinPilotTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: Radii.mdBR,
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: WinPilotTheme.textSecondary, letterSpacing: 0.5)),
                  Text(value, style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800,
                    color: WinPilotTheme.textPrimary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: Radii.smBR,
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              backgroundColor: WinPilotTheme.bgSurface,
              valueColor: AlwaysStoppedAnimation(_progressColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(
            fontSize: 11, color: WinPilotTheme.textMuted)),
        ],
      ),
    );
  }
}
