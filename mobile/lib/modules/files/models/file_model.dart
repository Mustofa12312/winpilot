// File Explorer Model
class FileItem {
  final String name;
  final String path;
  final bool isDir;
  final int size;
  final String extension;
  final DateTime modifiedAt;
  final bool isHidden;

  const FileItem({
    required this.name,
    required this.path,
    required this.isDir,
    required this.size,
    required this.extension,
    required this.modifiedAt,
    required this.isHidden,
  });

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem(
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      isDir: json['is_dir'] ?? false,
      size: json['size'] ?? 0,
      extension: json['extension'] ?? '',
      modifiedAt: DateTime.tryParse(json['modified_at'] ?? '') ?? DateTime.now(),
      isHidden: json['is_hidden'] ?? false,
    );
  }

  String get sizeFormatted {
    if (isDir) return '--';
    if (size >= 1024 * 1024 * 1024) return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    if (size >= 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    if (size >= 1024) return '${(size / 1024).toStringAsFixed(0)} KB';
    return '$size B';
  }
}
