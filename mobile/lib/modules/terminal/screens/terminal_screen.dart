import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/terminal/controllers/terminal_controller.dart';

class TerminalScreen extends StatelessWidget {
  const TerminalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(TerminalController());

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Terminal black
      appBar: AppBar(
        title: const Text('Remote Terminal', style: TextStyle(fontSize: 16, fontFamily: 'monospace')),
        backgroundColor: const Color(0xFF1E1E1E),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white24, height: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.white70),
            onPressed: ctrl.clearTerminal,
            tooltip: 'Clear Terminal',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView.builder(
                controller: ctrl.scrollCtrl,
                padding: const EdgeInsets.all(12),
                itemCount: ctrl.history.length,
                itemBuilder: (context, index) {
                  final entry = ctrl.history[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PS > ',
                              style: TextStyle(color: WinPilotTheme.successGreen, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: Text(
                                entry.command,
                                style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.output,
                          style: TextStyle(
                            color: entry.isError ? WinPilotTheme.dangerRed : Colors.white70,
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF2D2D2D),
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                const Text(
                  '> ',
                  style: TextStyle(color: WinPilotTheme.successGreen, fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: ctrl.textCtrl,
                    focusNode: ctrl.focusNode,
                    style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                    decoration: const InputDecoration(
                      hintText: 'Enter command...',
                      hintStyle: TextStyle(color: Colors.white38, fontFamily: 'monospace'),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onSubmitted: (_) => ctrl.executeCommand(),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                Obx(() {
                  return IconButton(
                    icon: ctrl.isRunning
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: WinPilotTheme.primaryBlue))
                        : const Icon(Icons.send_rounded, color: WinPilotTheme.primaryBlue),
                    onPressed: ctrl.isRunning ? null : ctrl.executeCommand,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
