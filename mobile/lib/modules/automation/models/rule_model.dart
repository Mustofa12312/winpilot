class AutomationRule {
  final String id;
  final String name;
  final bool isActive;
  final String triggerType;
  final String triggerData;
  final String actionType;
  final String actionData;

  const AutomationRule({
    required this.id,
    required this.name,
    required this.isActive,
    required this.triggerType,
    required this.triggerData,
    required this.actionType,
    required this.actionData,
  });

  factory AutomationRule.fromJson(Map<String, dynamic> json) {
    return AutomationRule(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isActive: json['is_active'] ?? false,
      triggerType: json['trigger_type'] ?? '',
      triggerData: json['trigger_data'] ?? '{}',
      actionType: json['action_type'] ?? '',
      actionData: json['action_data'] ?? '{}',
    );
  }

  String get summary {
    if (triggerType == 'schedule') {
      return 'Berjalan berdasarkan jadwal';
    }
    if (triggerType == 'metric') {
      return 'Berjalan saat sistem mencapai batas';
    }
    return 'Unknown Trigger';
  }
}
