import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/files/controllers/files_controller.dart';
import 'package:winpilot_mobile/modules/files/widgets/file_list_item.dart';
import 'package:winpilot_mobile/modules/files/models/file_model.dart';

class FilesScreen extends StatelessWidget {
  const FilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(FilesController());

    return Scaffold(
      backgroundColor: WinPilotTheme.bgBase,
      appBar: AppBar(
        title: Obx(() => Text(
          ctrl.currentPath.isEmpty ? 'C:\\' : ctrl.currentPath,
          style: const TextStyle(fontSize: 16),
        )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (ctrl.currentPath.isEmpty) {
              Get.back(); // Back to dashboard
            } else {
              ctrl.goBack(); // Back to previous folder
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_rounded),
            onPressed: () {
              final txtCtrl = TextEditingController();
              Get.defaultDialog(
                title: 'Folder Baru',
                content: TextField(
                  controller: txtCtrl,
                  decoration: const InputDecoration(hintText: 'Nama folder'),
                  autofocus: true,
                ),
                textConfirm: 'Buat',
                textCancel: 'Batal',
                onConfirm: () {
                  Get.back();
                  ctrl.createFolder(txtCtrl.text);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.upload_file_rounded),
            onPressed: () => ctrl.uploadFile(),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading && ctrl.files.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: WinPilotTheme.primaryBlue),
          );
        }

        if (ctrl.files.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open_rounded, size: 64, color: WinPilotTheme.textMuted),
                SizedBox(height: 16),
                Text('Folder kosong', style: TextStyle(color: WinPilotTheme.textSecondary)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ctrl.loadFiles(ctrl.currentPath),
          color: WinPilotTheme.primaryBlue,
          backgroundColor: WinPilotTheme.bgCard,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: ctrl.files.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 64),
            itemBuilder: (context, index) {
              final file = ctrl.files[index];
              return FileListItem(
                file: file,
                onTap: () {
                  if (file.isDir) {
                    ctrl.loadFiles(file.path);
                  } else {
                    // Open options to download
                    Get.bottomSheet(_buildFileOptions(file, ctrl));
                  }
                },
                onLongPress: () {
                  Get.bottomSheet(_buildFileOptions(file, ctrl));
                },
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildFileOptions(FileItem file, FilesController ctrl) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: WinPilotTheme.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(file.name, style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: WinPilotTheme.textPrimary),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.download_rounded, color: WinPilotTheme.primaryBlue),
            title: const Text('Download ke HP', style: TextStyle(color: WinPilotTheme.textPrimary)),
            onTap: () {
              Get.back();
              ctrl.downloadFile(file);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_rounded, color: WinPilotTheme.textSecondary),
            title: const Text('Rename', style: TextStyle(color: WinPilotTheme.textPrimary)),
            onTap: () {
              Get.back();
              final txtCtrl = TextEditingController(text: file.name);
              Get.defaultDialog(
                title: 'Rename File',
                content: TextField(
                  controller: txtCtrl,
                  autofocus: true,
                ),
                textConfirm: 'Simpan',
                textCancel: 'Batal',
                onConfirm: () {
                  Get.back();
                  ctrl.renameFile(file, txtCtrl.text);
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_rounded, color: WinPilotTheme.dangerRed),
            title: const Text('Delete', style: TextStyle(color: WinPilotTheme.dangerRed)),
            onTap: () {
              Get.back();
              ctrl.deleteFile(file);
            },
          ),
        ],
      ),
    );
  }
}
