import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/printers/controllers/printer_controller.dart';

class PrinterScreen extends StatelessWidget {
  const PrinterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(PrinterController());
    
    return Scaffold(
      backgroundColor: WinPilotTheme.bgBase,
      appBar: AppBar(
        title: const Text('Printer Hub', style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: ctrl.loadPrinters,
          )
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading) {
          return const Center(child: CircularProgressIndicator(color: WinPilotTheme.primaryBlue));
        }

        if (ctrl.printers.isEmpty) {
          return const Center(
            child: Text('Tidak ada printer ditemukan', 
              style: TextStyle(color: WinPilotTheme.textMuted)),
          );
        }

        return RefreshIndicator(
          onRefresh: ctrl.loadPrinters,
          color: WinPilotTheme.primaryBlue,
          backgroundColor: WinPilotTheme.bgCard,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: ctrl.printers.length,
            itemBuilder: (context, index) {
              final p = ctrl.printers[index];
              final isReady = p.status == 'Ready' || p.status == 'Idle';
              final isPrinting = p.status == 'Printing';
              
              Color statusColor = WinPilotTheme.textMuted;
              if (isReady) statusColor = WinPilotTheme.successGreen;
              if (isPrinting) statusColor = WinPilotTheme.primaryBlue;
              if (p.status.contains('Error') || p.status.contains('Attention')) {
                statusColor = WinPilotTheme.warningOrange;
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: WinPilotTheme.bgCard,
                  borderRadius: Radii.lgBR,
                  border: Border.all(
                    color: p.isDefault ? WinPilotTheme.primaryBlue.withValues(alpha: 0.5) : WinPilotTheme.borderSubtle
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: Radii.mdBR,
                      ),
                      child: Icon(Icons.print_rounded, color: statusColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  p.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: WinPilotTheme.textPrimary, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (p.isDefault)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: WinPilotTheme.primaryBlue.withValues(alpha: 0.2),
                                    borderRadius: Radii.smBR,
                                  ),
                                  child: const Text('Default', style: TextStyle(fontSize: 10, color: WinPilotTheme.primaryBlue, fontWeight: FontWeight.w700)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                p.status,
                                style: const TextStyle(color: WinPilotTheme.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
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
