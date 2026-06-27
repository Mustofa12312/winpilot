import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/tasks/controllers/tasks_controller.dart';
import 'package:winpilot_mobile/modules/tasks/models/process_model.dart';

class TaskManagerScreen extends StatelessWidget {
  const TaskManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(TasksController());

    return Scaffold(
      backgroundColor: WinPilotTheme.bgBase,
      appBar: AppBar(
        title: const Text('Task Manager', style: TextStyle(fontSize: 16)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: ctrl.setSearchQuery,
              style: const TextStyle(color: WinPilotTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Cari proses (contoh: chrome)...',
                hintStyle: const TextStyle(color: WinPilotTheme.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, color: WinPilotTheme.textMuted),
                filled: true,
                fillColor: WinPilotTheme.bgCard,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: Radii.lgBR,
                  borderSide: const BorderSide(color: WinPilotTheme.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: Radii.lgBR,
                  borderSide: const BorderSide(color: WinPilotTheme.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: Radii.lgBR,
                  borderSide: const BorderSide(color: WinPilotTheme.primaryBlue),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (ctrl.isLoading && ctrl.allProcesses.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: WinPilotTheme.primaryBlue));
        }

        final procs = ctrl.filteredProcesses;

        if (procs.isEmpty) {
          return const Center(
            child: Text('Proses tidak ditemukan', style: TextStyle(color: WinPilotTheme.textMuted)),
          );
        }

        return RefreshIndicator(
          onRefresh: ctrl.loadProcesses,
          color: WinPilotTheme.primaryBlue,
          backgroundColor: WinPilotTheme.bgCard,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: procs.length,
            itemBuilder: (context, index) {
              final p = procs[index];
              return _ProcessItemTile(
                process: p,
                onKill: () => _confirmKill(context, p, ctrl),
              );
            },
          ),
        );
      }),
    );
  }

  void _confirmKill(BuildContext context, ProcessItem process, TasksController ctrl) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: WinPilotTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: Radii.lgBR),
        title: const Text('End Task', style: TextStyle(
          color: WinPilotTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Text('Hentikan paksa ${process.name} (PID: ${process.pid})?\nIni bisa menyebabkan kehilangan data yang belum disimpan.',
          style: const TextStyle(color: WinPilotTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: WinPilotTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              ctrl.killProcess(process);
            },
            style: ElevatedButton.styleFrom(backgroundColor: WinPilotTheme.dangerRed),
            child: const Text('End Task'),
          ),
        ],
      ),
    );
  }
}

class _ProcessItemTile extends StatelessWidget {
  final ProcessItem process;
  final VoidCallback onKill;

  const _ProcessItemTile({required this.process, required this.onKill});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WinPilotTheme.bgCard,
        borderRadius: Radii.mdBR,
        border: Border.all(color: WinPilotTheme.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: WinPilotTheme.bgSurface,
              borderRadius: Radii.smBR,
            ),
            child: const Icon(Icons.memory_rounded, color: WinPilotTheme.textSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  process.name,
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: WinPilotTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('PID: ${process.pid}', style: const TextStyle(
                      fontSize: 11, color: WinPilotTheme.textMuted)),
                    const SizedBox(width: 12),
                    Text(process.memoryFormatted, style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: WinPilotTheme.primaryBlue)),
                    const SizedBox(width: 12),
                    Text('${process.cpuUsage.toStringAsFixed(1)}% CPU', style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: process.cpuUsage > 10.0 ? WinPilotTheme.warningOrange : WinPilotTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: WinPilotTheme.textMuted, size: 20),
            onPressed: onKill,
            tooltip: 'End Task',
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
