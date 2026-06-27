import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart' hide Response, MultipartFile, FormData;
import 'package:winpilot_mobile/core/network/api_client.dart';
import 'package:winpilot_mobile/modules/files/models/file_model.dart';

class FilesController extends GetxController {
  final _files = <FileItem>[].obs;
  final _isLoading = false.obs;
  final _currentPath = ''.obs;
  final _history = <String>[].obs;

  List<FileItem> get files => _files;
  bool get isLoading => _isLoading.value;
  String get currentPath => _currentPath.value;

  @override
  void onInit() {
    super.onInit();
    loadFiles(''); // empty means root / default dir
  }

  Future<void> loadFiles(String path) async {
    _isLoading.value = true;
    try {
      final response = await ApiClient.to.get('/api/v1/files', params: {'path': path});
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'] ?? [];
        _files.value = data.map((e) => FileItem.fromJson(e)).toList();
        
        // sort: dirs first, then alphabetical
        _files.sort((a, b) {
          if (a.isDir && !b.isDir) return -1;
          if (!a.isDir && b.isDir) return 1;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

        if (path.isNotEmpty && _currentPath.value != path) {
          if (_currentPath.value.isNotEmpty) {
            _history.add(_currentPath.value);
          }
        }
        _currentPath.value = path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat direktori: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void goBack() {
    if (_history.isNotEmpty) {
      final previous = _history.removeLast();
      loadFiles(previous);
      // Remove it again because loadFiles adds to history
      _history.removeLast();
    }
  }

  Future<void> deleteFile(FileItem item) async {
    try {
      final res = await ApiClient.to.post('/api/v1/files/action', data: {
        'action': 'delete',
        'path': item.path,
      });
      if (res.statusCode == 200) {
        loadFiles(_currentPath.value);
        Get.snackbar('Sukses', 'File berhasil dihapus');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus file');
    }
  }

  Future<void> downloadFile(FileItem item) async {
    try {
      Get.snackbar('Mendownload', 'Mengunduh ${item.name}...');
      final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/${item.name}';

      await ApiClient.to.dio.download(
        '/api/v1/files/download',
        savePath,
        queryParameters: {'path': item.path},
      );
      Get.snackbar('Sukses', 'File disimpan di $savePath');
    } catch (e) {
      Get.snackbar('Error', 'Gagal mendownload file');
    }
  }

  Future<void> uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles();
      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;
        final targetPath = '${_currentPath.value}\\$fileName';
        
        Get.snackbar('Mengupload', 'Mengunggah $fileName...');

        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(filePath, filename: fileName),
        });

        final res = await ApiClient.to.dio.post(
          '/api/v1/files/upload',
          queryParameters: {'path': targetPath},
          data: formData,
        );

        if (res.statusCode == 200) {
          loadFiles(_currentPath.value);
          Get.snackbar('Sukses', 'File berhasil diunggah');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengupload file');
    }
  }

  Future<void> createFolder(String name) async {
    if (name.isEmpty) return;
    try {
      final res = await ApiClient.to.post('/api/v1/files/action', data: {
        'action': 'mkdir',
        'path': '${_currentPath.value}\\$name',
      });
      if (res.statusCode == 200) {
        loadFiles(_currentPath.value);
        Get.snackbar('Sukses', 'Folder berhasil dibuat');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuat folder');
    }
  }

  Future<void> renameFile(FileItem item, String newName) async {
    if (newName.isEmpty || newName == item.name) return;
    try {
      // Find the parent directory path
      final parentPath = item.path.substring(0, item.path.lastIndexOf('\\'));
      final newPath = '$parentPath\\$newName';
      
      final res = await ApiClient.to.post('/api/v1/files/action', data: {
        'action': 'rename',
        'old_path': item.path,
        'new_path': newPath,
      });
      if (res.statusCode == 200) {
        loadFiles(_currentPath.value);
        Get.snackbar('Sukses', 'Berhasil mengubah nama');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal merename file');
    }
  }
}
