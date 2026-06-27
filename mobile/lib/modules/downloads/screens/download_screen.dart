import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/downloads/controllers/download_controller.dart';

class DownloadScreen extends StatelessWidget {
  const DownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(DownloadController());

    return Scaffold(
      backgroundColor: WinPilotTheme.bgBase,
      appBar: AppBar(
        title: const Text('Download Manager', style: TextStyle(fontSize: 16)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: WinPilotTheme.bgCard,
                borderRadius: Radii.lgBR,
                border: Border.all(color: WinPilotTheme.borderSubtle),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: ctrl.urlCtrl,
                    style: const TextStyle(color: WinPilotTheme.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'https://example.com/file.iso',
                      hintStyle: TextStyle(color: WinPilotTheme.textMuted),
                      labelText: 'URL Unduhan',
                      labelStyle: TextStyle(color: WinPilotTheme.primaryBlue),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ctrl.filenameCtrl,
                    style: const TextStyle(color: WinPilotTheme.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'file.iso (Kosongkan untuk auto)',
                      hintStyle: TextStyle(color: WinPilotTheme.textMuted),
                      labelText: 'Nama File',
                      labelStyle: TextStyle(color: WinPilotTheme.primaryBlue),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(() => ElevatedButton.icon(
                      onPressed: ctrl.isStarting ? null : ctrl.startDownload,
                      icon: ctrl.isStarting 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.download_rounded),
                      label: const Text('Mulai Unduh ke PC'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WinPilotTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Unduhan Aktif',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: WinPilotTheme.textPrimary),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (ctrl.downloads.isEmpty) {
                  return const Center(
                    child: Text('Belum ada unduhan', style: TextStyle(color: WinPilotTheme.textMuted)),
                  );
                }

                return ListView.builder(
                  itemCount: ctrl.downloads.length,
                  itemBuilder: (context, index) {
                    final dl = ctrl.downloads[index];
                    Color stateColor = WinPilotTheme.primaryBlue;
                    if (dl.state == 'completed') stateColor = WinPilotTheme.successGreen;
                    if (dl.state == 'error') stateColor = WinPilotTheme.dangerRed;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: WinPilotTheme.bgCard,
                        borderRadius: Radii.mdBR,
                        border: Border.all(color: WinPilotTheme.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dl.filename,
                            style: const TextStyle(color: WinPilotTheme.textPrimary, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dl.state.toUpperCase(), style: TextStyle(color: stateColor, fontSize: 10, fontWeight: FontWeight.bold)),
                              if (dl.state == 'downloading')
                                Text('${ctrl.formatSpeed(dl.speed)} - ${dl.progress.toStringAsFixed(1)}%', style: const TextStyle(color: WinPilotTheme.textSecondary, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: dl.state == 'completed' ? 1.0 : (dl.progress / 100),
                            backgroundColor: WinPilotTheme.bgBase,
                            valueColor: AlwaysStoppedAnimation<Color>(stateColor),
                          ),
                          if (dl.error.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(dl.error, style: const TextStyle(color: WinPilotTheme.dangerRed, fontSize: 11)),
                          ]
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
