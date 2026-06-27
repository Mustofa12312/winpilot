import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/clipboard/controllers/clipboard_controller.dart';

class ClipboardScreen extends StatelessWidget {
  const ClipboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ClipboardController());

    return Scaffold(
      backgroundColor: WinPilotTheme.bgBase,
      appBar: AppBar(
        title: const Text('Clipboard Sync', style: TextStyle(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Remote PC Clipboard',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: WinPilotTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kirim atau tarik teks ke komputer Windows secara langsung.',
              style: TextStyle(color: WinPilotTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: WinPilotTheme.bgCard,
                borderRadius: Radii.lgBR,
                border: Border.all(color: WinPilotTheme.borderSubtle),
              ),
              child: TextField(
                controller: ctrl.textCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(color: WinPilotTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Ketik atau paste teks di sini...',
                  hintStyle: TextStyle(color: WinPilotTheme.textMuted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: ctrl.textCtrl.text));
                      Get.snackbar('Sukses', 'Disalin ke clipboard HP Anda');
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copy to HP'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: WinPilotTheme.primaryBlue,
                      side: const BorderSide(color: WinPilotTheme.borderSubtle),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: Radii.mdBR),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');
                      if (data != null && data.text != null) {
                        ctrl.textCtrl.text = data.text!;
                      }
                    },
                    icon: const Icon(Icons.paste_rounded, size: 18),
                    label: const Text('Paste from HP'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WinPilotTheme.bgSurface,
                      foregroundColor: WinPilotTheme.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: Radii.mdBR),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: WinPilotTheme.borderSubtle),
            const SizedBox(height: 24),
            Obx(() => Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: ctrl.isLoading ? null : ctrl.getClipboard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WinPilotTheme.bgSurface,
                      foregroundColor: WinPilotTheme.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: Radii.mdBR),
                    ),
                    child: ctrl.isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Tarik Teks dari PC'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: ctrl.isLoading ? null : ctrl.setClipboard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WinPilotTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: Radii.mdBR),
                    ),
                    child: ctrl.isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Kirim ke PC'),
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
