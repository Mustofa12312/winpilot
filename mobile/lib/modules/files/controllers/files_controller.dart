import 'package:get/get.dart';
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
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus file');
    }
  }
}
