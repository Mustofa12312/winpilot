class PluginManifest {
  final String id;
  final String name;
  final String version;
  final String author;
  final String description;
  final String entrypoint;

  PluginManifest({
    required this.id,
    required this.name,
    required this.version,
    required this.author,
    required this.description,
    required this.entrypoint,
  });

  factory PluginManifest.fromJson(Map<String, dynamic> json) {
    return PluginManifest(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      version: json['version'] ?? '',
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      entrypoint: json['entrypoint'] ?? '',
    );
  }
}

class PluginModel {
  final PluginManifest manifest;
  final bool isActive;
  final String status;

  PluginModel({
    required this.manifest,
    required this.isActive,
    required this.status,
  });

  factory PluginModel.fromJson(Map<String, dynamic> json) {
    return PluginModel(
      manifest: PluginManifest.fromJson(json['manifest'] ?? {}),
      isActive: json['is_active'] ?? false,
      status: json['status'] ?? 'unknown',
    );
  }
}
