// Process (Task) Model
class ProcessItem {
  final int pid;
  final String name;
  final int memoryUsage; // in bytes
  final double cpuUsage; // percentage
  final String username;

  const ProcessItem({
    required this.pid,
    required this.name,
    required this.memoryUsage,
    required this.cpuUsage,
    required this.username,
  });

  factory ProcessItem.fromJson(Map<String, dynamic> json) {
    return ProcessItem(
      pid: json['pid'] ?? 0,
      name: json['name'] ?? 'Unknown',
      memoryUsage: json['memory_usage'] ?? 0,
      cpuUsage: (json['cpu_usage'] ?? 0.0).toDouble(),
      username: json['username'] ?? '',
    );
  }

  String get memoryFormatted {
    if (memoryUsage >= 1024 * 1024 * 1024) return '${(memoryUsage / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    if (memoryUsage >= 1024 * 1024) return '${(memoryUsage / (1024 * 1024)).toStringAsFixed(1)} MB';
    if (memoryUsage >= 1024) return '${(memoryUsage / 1024).toStringAsFixed(0)} KB';
    return '$memoryUsage B';
  }
}
