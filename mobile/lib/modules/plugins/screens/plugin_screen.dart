import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/plugins/controllers/plugin_controller.dart';
import 'package:winpilot_mobile/modules/plugins/models/plugin_model.dart';

class PluginScreen extends StatelessWidget {
  const PluginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(PluginController());

    return Scaffold(
      backgroundColor: WinPilotTheme.bgBase,
      appBar: AppBar(
        title: const Text('Plugin Center', style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: ctrl.loadPlugins,
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading && ctrl.plugins.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: WinPilotTheme.primaryBlue));
        }

        if (ctrl.plugins.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.extension_off_rounded, size: 64, color: WinPilotTheme.textMuted),
                SizedBox(height: 16),
                Text('Belum ada plugin terinstall', style: TextStyle(color: WinPilotTheme.textSecondary)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: ctrl.loadPlugins,
          color: WinPilotTheme.primaryBlue,
          backgroundColor: WinPilotTheme.bgCard,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: ctrl.plugins.length,
            itemBuilder: (context, index) {
              final plugin = ctrl.plugins[index];
              return _PluginTile(plugin: plugin, ctrl: ctrl);
            },
          ),
        );
      }),
    );
  }
}

class _PluginTile extends StatelessWidget {
  final PluginModel plugin;
  final PluginController ctrl;

  const _PluginTile({required this.plugin, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: WinPilotTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: Radii.mdBR,
                ),
                child: const Icon(Icons.extension_rounded, color: WinPilotTheme.primaryBlue, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plugin.manifest.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700, color: WinPilotTheme.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'v${plugin.manifest.version} • by ${plugin.manifest.author}',
                      style: const TextStyle(fontSize: 12, color: WinPilotTheme.textMuted),
                    ),
                  ],
                ),
              ),
              Switch(
                value: plugin.isActive,
                onChanged: (val) => ctrl.togglePlugin(plugin.manifest.id, val),
                activeThumbColor: WinPilotTheme.primaryBlue,
                activeTrackColor: WinPilotTheme.primaryBlue.withValues(alpha: 0.2),
                inactiveThumbColor: WinPilotTheme.textMuted,
                inactiveTrackColor: WinPilotTheme.bgSurface,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            plugin.manifest.description,
            style: const TextStyle(fontSize: 13, color: WinPilotTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          const Divider(color: WinPilotTheme.borderSubtle),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status: ${plugin.status.toUpperCase()}',
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: WinPilotTheme.successGreen),
              ),
              Obx(() {
                final isRunning = ctrl.isRunning(plugin.manifest.id);
                return ElevatedButton.icon(
                  onPressed: (!plugin.isActive || isRunning)
                      ? null
                      : () => ctrl.runPlugin(plugin.manifest.id),
                  icon: isRunning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(isRunning ? 'Running...' : 'Run'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WinPilotTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: WinPilotTheme.bgSurface,
                    disabledForegroundColor: WinPilotTheme.textMuted,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: const Size(0, 36),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
