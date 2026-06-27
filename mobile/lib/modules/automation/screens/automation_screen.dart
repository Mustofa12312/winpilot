import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/automation/controllers/automation_controller.dart';
import 'package:winpilot_mobile/modules/automation/models/rule_model.dart';
import 'package:winpilot_mobile/modules/automation/screens/create_rule_screen.dart';

class AutomationScreen extends StatelessWidget {
  const AutomationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AutomationController());

    return Scaffold(
      backgroundColor: WinPilotTheme.bgBase,
      appBar: AppBar(
        title: const Text('Automation Engine', style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => Get.to(() => const CreateRuleScreen()),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading && ctrl.rules.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: WinPilotTheme.primaryBlue));
        }

        if (ctrl.rules.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.smart_toy_rounded, size: 64, color: WinPilotTheme.textMuted),
                const SizedBox(height: 16),
                const Text('Belum ada otomatisasi', style: TextStyle(color: WinPilotTheme.textSecondary)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const CreateRuleScreen()),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Buat Rule Baru'),
                  style: ElevatedButton.styleFrom(backgroundColor: WinPilotTheme.primaryBlue),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: ctrl.loadRules,
          color: WinPilotTheme.primaryBlue,
          backgroundColor: WinPilotTheme.bgCard,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: ctrl.rules.length,
            itemBuilder: (context, index) {
              final rule = ctrl.rules[index];
              return _RuleItemTile(rule: rule, ctrl: ctrl);
            },
          ),
        );
      }),
    );
  }
}

class _RuleItemTile extends StatelessWidget {
  final AutomationRule rule;
  final AutomationController ctrl;

  const _RuleItemTile({required this.rule, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WinPilotTheme.bgCard,
        borderRadius: Radii.lgBR,
        border: Border.all(color: rule.isActive ? WinPilotTheme.primaryBlue.withValues(alpha: 0.3) : WinPilotTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: WinPilotTheme.bgSurface,
                  borderRadius: Radii.smBR,
                ),
                child: Icon(
                  rule.triggerType == 'schedule' ? Icons.schedule_rounded : Icons.memory_rounded,
                  color: WinPilotTheme.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.name,
                      style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: WinPilotTheme.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rule.summary,
                      style: const TextStyle(fontSize: 12, color: WinPilotTheme.textMuted),
                    ),
                  ],
                ),
              ),
              Switch(
                value: rule.isActive,
                onChanged: (val) => ctrl.toggleRule(rule.id, val),
                activeThumbColor: WinPilotTheme.primaryBlue,
                activeTrackColor: WinPilotTheme.primaryBlue.withValues(alpha: 0.2),
                inactiveThumbColor: WinPilotTheme.textMuted,
                inactiveTrackColor: WinPilotTheme.bgSurface,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: WinPilotTheme.borderSubtle),
          Row(
            children: [
              Icon(
                rule.actionType == 'notification' ? Icons.notifications_rounded : Icons.power_settings_new_rounded,
                size: 16,
                color: WinPilotTheme.textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                'Action: ${rule.actionType.toUpperCase()}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WinPilotTheme.textSecondary),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: WinPilotTheme.dangerRed, size: 20),
                onPressed: () {
                  Get.defaultDialog(
                    title: 'Hapus Rule',
                    titleStyle: const TextStyle(color: WinPilotTheme.textPrimary),
                    middleText: 'Yakin ingin menghapus otomatisasi ini?',
                    middleTextStyle: const TextStyle(color: WinPilotTheme.textSecondary),
                    backgroundColor: WinPilotTheme.bgCard,
                    textCancel: 'Batal',
                    textConfirm: 'Hapus',
                    confirmTextColor: Colors.white,
                    buttonColor: WinPilotTheme.dangerRed,
                    cancelTextColor: WinPilotTheme.textSecondary,
                    onConfirm: () {
                      ctrl.deleteRule(rule.id);
                      Get.back();
                    },
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
