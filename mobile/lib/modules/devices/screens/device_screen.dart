import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/devices/controllers/device_controller.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(DeviceController());

    return Scaffold(
      backgroundColor: WinPilotTheme.bgBase,
      appBar: AppBar(
        title: const Text('Device Hub', style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: ctrl.loadDevices,
          )
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading) {
          return const Center(child: CircularProgressIndicator(color: WinPilotTheme.primaryBlue));
        }

        if (ctrl.devices.isEmpty) {
          return const Center(
            child: Text('Tidak ada perangkat terdeteksi', style: TextStyle(color: WinPilotTheme.textMuted)),
          );
        }

        // Group devices by class
        final Map<String, List<WinDevice>> grouped = {};
        for (var d in ctrl.devices) {
          grouped.putIfAbsent(d.deviceClass, () => []).add(d);
        }

        return RefreshIndicator(
          onRefresh: ctrl.loadDevices,
          color: WinPilotTheme.primaryBlue,
          backgroundColor: WinPilotTheme.bgCard,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: grouped.keys.length,
            itemBuilder: (context, index) {
              final className = grouped.keys.elementAt(index);
              final devs = grouped[className]!;

              IconData icon = Icons.device_unknown_rounded;
              if (className == 'USB') icon = Icons.usb_rounded;
              if (className == 'Bluetooth') icon = Icons.bluetooth_rounded;
              if (className == 'Display') icon = Icons.monitor_rounded;
              if (className == 'Audio') icon = Icons.speaker_rounded;
              if (className == 'Disk') icon = Icons.storage_rounded;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      '$className Devices (${devs.length})',
                      style: const TextStyle(color: WinPilotTheme.primaryBlue, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                  ...devs.map((d) {
                    final isError = d.status.toLowerCase().contains('error');
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: WinPilotTheme.bgCard,
                        borderRadius: Radii.mdBR,
                        border: Border.all(color: isError ? WinPilotTheme.dangerRed : WinPilotTheme.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (isError ? WinPilotTheme.dangerRed : WinPilotTheme.primaryBlue).withValues(alpha: 0.1),
                              borderRadius: Radii.smBR,
                            ),
                            child: Icon(icon, size: 20, color: isError ? WinPilotTheme.dangerRed : WinPilotTheme.primaryBlue),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: WinPilotTheme.textPrimary, fontSize: 13),
                                ),
                                if (d.manufacturer.isNotEmpty)
                                  Text(
                                    d.manufacturer,
                                    style: const TextStyle(color: WinPilotTheme.textMuted, fontSize: 11),
                                  ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 6, height: 6,
                                      decoration: BoxDecoration(
                                        color: isError ? WinPilotTheme.dangerRed : WinPilotTheme.successGreen,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(d.status, style: const TextStyle(color: WinPilotTheme.textSecondary, fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        );
      }),
    );
  }
}
