import 'dart:convert';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/network/api_client.dart';
import 'package:winpilot_mobile/modules/automation/models/rule_model.dart';

class AutomationController extends GetxController {
  final _rules = <AutomationRule>[].obs;
  final _isLoading = false.obs;

  List<AutomationRule> get rules => _rules;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadRules();
  }

  Future<void> loadRules() async {
    _isLoading.value = true;
    try {
      final response = await ApiClient.to.get('/api/v1/automation/rules');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'] ?? [];
        _rules.value = data.map((e) => AutomationRule.fromJson(e)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat aturan otomatisasi: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> toggleRule(String id, bool isActive) async {
    try {
      final res = await ApiClient.to.put('/api/v1/automation/rules/$id/toggle', data: {
        'is_active': isActive,
      });
      if (res.statusCode == 200) {
        // Optimistic UI update
        final index = _rules.indexWhere((r) => r.id == id);
        if (index != -1) {
          final old = _rules[index];
          _rules[index] = AutomationRule(
            id: old.id,
            name: old.name,
            isActive: isActive,
            triggerType: old.triggerType,
            triggerData: old.triggerData,
            actionType: old.actionType,
            actionData: old.actionData,
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengubah status rule');
      loadRules(); // Revert
    }
  }

  Future<void> deleteRule(String id) async {
    try {
      final res = await ApiClient.to.delete('/api/v1/automation/rules/$id');
      if (res.statusCode == 200) {
        _rules.removeWhere((r) => r.id == id);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus rule');
    }
  }

  Future<bool> createRule({
    required String name,
    required String triggerType,
    required Map<String, dynamic> triggerData,
    required String actionType,
    required Map<String, dynamic> actionData,
  }) async {
    try {
      final res = await ApiClient.to.post('/api/v1/automation/rules', data: {
        'name': name,
        'trigger_type': triggerType,
        'trigger_data': jsonEncode(triggerData),
        'action_type': actionType,
        'action_data': jsonEncode(actionData),
      });

      if (res.statusCode == 200) {
        loadRules();
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuat rule baru');
      return false;
    }
  }
}
