// WinPilot Metrics & Notification Models
import 'package:flutter/material.dart';

class MetricsSnapshot {
  final CpuMetrics cpu;
  final RamMetrics ram;
  final List<DiskMetrics> disk;
  final NetMetrics network;
  final BatteryMetrics battery;
  final TempMetrics temp;
  final DateTime timestamp;

  const MetricsSnapshot({
    required this.cpu,
    required this.ram,
    required this.disk,
    required this.network,
    required this.battery,
    required this.temp,
    required this.timestamp,
  });

  factory MetricsSnapshot.fromJson(Map<String, dynamic> json) {
    return MetricsSnapshot(
      cpu: CpuMetrics.fromJson((json['cpu'] as Map<String, dynamic>?) ?? {}),
      ram: RamMetrics.fromJson((json['ram'] as Map<String, dynamic>?) ?? {}),
      disk: ((json['disk'] as List?)?.cast<Map<String, dynamic>>() ?? [])
          .map(DiskMetrics.fromJson)
          .toList(),
      network: NetMetrics.fromJson((json['network'] as Map<String, dynamic>?) ?? {}),
      battery: BatteryMetrics.fromJson((json['battery'] as Map<String, dynamic>?) ?? {}),
      temp: TempMetrics.fromJson((json['temp'] as Map<String, dynamic>?) ?? {}),
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  // Demo/fallback snapshot
  static MetricsSnapshot get demo => MetricsSnapshot(
    cpu: const CpuMetrics(usagePercent: 18.4, cores: 8, modelName: 'Intel Core i7-12700H'),
    ram: const RamMetrics(totalMB: 16384, usedMB: 6820, usedPercent: 41.6),
    disk: const [
      DiskMetrics(drive: 'C:', label: 'Windows', usedPercent: 61.0, totalGB: 500, freeGB: 195),
      DiskMetrics(drive: 'D:', label: 'Data', usedPercent: 42.2, totalGB: 1000, freeGB: 578),
    ],
    network: const NetMetrics(
      downloadBps: 15360000,
      uploadBps: 512000,
      connected: true,
      ssid: 'HomeNetwork',
      latencyMs: 8.5,
    ),
    battery: const BatteryMetrics(present: false, percent: 100),
    temp: const TempMetrics(cpuCelsius: 62.0, available: true),
    timestamp: DateTime.now(),
  );
}

class CpuMetrics {
  final double usagePercent;
  final int cores;
  final String modelName;
  final double frequencyMHz;

  const CpuMetrics({
    required this.usagePercent,
    required this.cores,
    required this.modelName,
    this.frequencyMHz = 0,
  });

  factory CpuMetrics.fromJson(Map<String, dynamic> json) => CpuMetrics(
    usagePercent: (json['usage_percent'] as num?)?.toDouble() ?? 0,
    cores: (json['cores'] as num?)?.toInt() ?? 0,
    modelName: json['model_name']?.toString() ?? '',
    frequencyMHz: (json['frequency_mhz'] as num?)?.toDouble() ?? 0,
  );
}

class RamMetrics {
  final double totalMB;
  final double usedMB;
  final double usedPercent;

  const RamMetrics({
    required this.totalMB,
    required this.usedMB,
    required this.usedPercent,
  });

  double get freeMB => totalMB - usedMB;
  double get totalGB => totalMB / 1024;
  double get usedGB => usedMB / 1024;

  factory RamMetrics.fromJson(Map<String, dynamic> json) => RamMetrics(
    totalMB: (json['total_mb'] as num?)?.toDouble() ?? 0,
    usedMB: (json['used_mb'] as num?)?.toDouble() ?? 0,
    usedPercent: (json['used_percent'] as num?)?.toDouble() ?? 0,
  );
}

class DiskMetrics {
  final String drive;
  final String label;
  final double usedPercent;
  final double totalGB;
  final double freeGB;

  const DiskMetrics({
    required this.drive,
    required this.label,
    required this.usedPercent,
    required this.totalGB,
    required this.freeGB,
  });

  double get usedGB => totalGB - freeGB;

  factory DiskMetrics.fromJson(Map<String, dynamic> json) => DiskMetrics(
    drive: json['drive']?.toString() ?? '',
    label: json['label']?.toString() ?? '',
    usedPercent: (json['used_percent'] as num?)?.toDouble() ?? 0,
    totalGB: (json['total_gb'] as num?)?.toDouble() ?? 0,
    freeGB: (json['free_gb'] as num?)?.toDouble() ?? 0,
  );
}

class NetMetrics {
  final int downloadBps;
  final int uploadBps;
  final bool connected;
  final String ssid;
  final double latencyMs;

  const NetMetrics({
    required this.downloadBps,
    required this.uploadBps,
    required this.connected,
    required this.ssid,
    required this.latencyMs,
  });

  String get downloadFormatted => _formatSpeed(downloadBps);
  String get uploadFormatted => _formatSpeed(uploadBps);

  static String _formatSpeed(int bps) {
    if (bps >= 1000000) return '${(bps / 1000000).toStringAsFixed(1)} MB/s';
    if (bps >= 1000) return '${(bps / 1000).toStringAsFixed(0)} KB/s';
    return '$bps B/s';
  }

  factory NetMetrics.fromJson(Map<String, dynamic> json) => NetMetrics(
    downloadBps: (json['download_bps'] as num?)?.toInt() ?? 0,
    uploadBps: (json['upload_bps'] as num?)?.toInt() ?? 0,
    connected: json['connected'] as bool? ?? false,
    ssid: json['ssid']?.toString() ?? '',
    latencyMs: (json['latency_ms'] as num?)?.toDouble() ?? 0,
  );
}

class BatteryMetrics {
  final bool present;
  final double percent;
  final bool isCharging;

  const BatteryMetrics({
    required this.present,
    required this.percent,
    this.isCharging = false,
  });

  factory BatteryMetrics.fromJson(Map<String, dynamic> json) => BatteryMetrics(
    present: json['present'] as bool? ?? false,
    percent: (json['percent'] as num?)?.toDouble() ?? 100,
    isCharging: json['is_charging'] as bool? ?? false,
  );
}

class TempMetrics {
  final double cpuCelsius;
  final bool available;

  const TempMetrics({required this.cpuCelsius, required this.available});

  factory TempMetrics.fromJson(Map<String, dynamic> json) => TempMetrics(
    cpuCelsius: (json['cpu_celsius'] as num?)?.toDouble() ?? 0,
    available: json['available'] as bool? ?? false,
  );
}

// ─── Notification Model ───────────────────────────────────────────────────────

class WinNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  const WinNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  WinNotification copyWith({bool? isRead}) => WinNotification(
    id: id,
    type: type,
    title: title,
    body: body,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );

  IconData get icon {
    switch (type) {
      case 'printer': return Icons.print_rounded;
      case 'download': return Icons.download_rounded;
      case 'cpu': return Icons.memory_rounded;
      case 'disk': return Icons.storage_rounded;
      case 'usb': return Icons.usb_rounded;
      case 'login': return Icons.login_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  factory WinNotification.fromJson(Map<String, dynamic> json) => WinNotification(
    id: json['id']?.toString() ?? '',
    type: json['type']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    body: json['body']?.toString() ?? '',
    isRead: json['read'] as bool? ?? false,
    createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
  );
}
