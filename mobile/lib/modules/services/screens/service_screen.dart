import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/services/controllers/service_controller.dart';

class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ServiceController());
    
    return Scaffold(
      backgroundColor: WinPilotTheme.bgBase,
      appBar: AppBar(
        title: const Text('Windows Services', style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: ctrl.loadServices,
          )
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading) {
          return const Center(child: CircularProgressIndicator(color: WinPilotTheme.primaryBlue));
        }

        if (ctrl.services.isEmpty) {
          return const Center(
            child: Text('Tidak ada service ditemukan (Atau sistem tidak didukung)', 
              style: TextStyle(color: WinPilotTheme.textMuted)),
          );
        }

        return RefreshIndicator(
          onRefresh: ctrl.loadServices,
          color: WinPilotTheme.primaryBlue,
          backgroundColor: WinPilotTheme.bgCard,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: ctrl.services.length,
            itemBuilder: (context, index) {
              final srv = ctrl.services[index];
              final isRunning = srv.status == 'Running';
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: WinPilotTheme.bgCard,
                  borderRadius: Radii.lgBR,
                  border: Border.all(color: WinPilotTheme.borderSubtle),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isRunning 
                          ? WinPilotTheme.successGreen.withValues(alpha: 0.1)
                          : WinPilotTheme.textMuted.withValues(alpha: 0.1),
                        borderRadius: Radii.mdBR,
                      ),
                      child: Icon(
                        Icons.settings_applications_rounded,
                        color: isRunning ? WinPilotTheme.successGreen : WinPilotTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            srv.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: WinPilotTheme.textPrimary, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Name: ${srv.name}',
                            style: const TextStyle(color: WinPilotTheme.textMuted, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isRunning,
                      onChanged: (val) => ctrl.toggleService(srv.name, isRunning),
                      activeThumbColor: WinPilotTheme.successGreen,
                      activeTrackColor: WinPilotTheme.successGreen.withValues(alpha: 0.2),
                      inactiveThumbColor: WinPilotTheme.textMuted,
                      inactiveTrackColor: WinPilotTheme.bgSurface,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
