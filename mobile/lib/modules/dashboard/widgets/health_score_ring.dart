// Health Score Ring — Circular indicator with score
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';

class HealthScoreRing extends StatelessWidget {
  final int score;
  const HealthScoreRing({super.key, required this.score});

  Color get _scoreColor {
    if (score >= 80) return WinPilotTheme.statusOnline;
    if (score >= 60) return WinPilotTheme.warningOrange;
    return WinPilotTheme.dangerRed;
  }

  String get _label {
    if (score >= 80) return 'Healthy';
    if (score >= 60) return 'Warning';
    return 'Critical';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: WinPilotTheme.bgCard,
        borderRadius: Radii.lgBR,
        border: Border.all(color: WinPilotTheme.borderSubtle),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: CustomPaint(
              painter: _RingPainter(
                progress: score / 100,
                color: _scoreColor,
                backgroundColor: WinPilotTheme.bgSurface,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _scoreColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(_label, style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, color: _scoreColor)),
          const Text('Health', style: TextStyle(fontSize: 9, color: WinPilotTheme.textMuted)),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  const _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 6;
    const strokeWidth = 7.0;

    // Background ring
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, 2 * pi, false,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress ring
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, 2 * pi * progress, false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
    old.progress != progress || old.color != color;
}
