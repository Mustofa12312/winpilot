import 'package:get/get.dart';
import 'package:winpilot_mobile/core/network/api_client.dart';
import 'package:winpilot_mobile/modules/tasks/models/process_model.dart';

class TasksController extends GetxController {
  final _processes = <ProcessItem>[].obs;
  final _isLoading = false.obs;
  final _searchQuery = ''.obs;

  List<ProcessItem> get allProcesses => _processes;
  List<ProcessItem> get filteredProcesses {
    if (_searchQuery.value.isEmpty) return _processes;
    final q = _searchQuery.value.toLowerCase();
    return _processes.where((p) => p.name.toLowerCase().contains(q) || p.pid.toString().contains(q)).toList();
  }
  
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadProcesses();
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
  }

  Future<void> loadProcesses() async {
    _isLoading.value = true;
    try {
      final response = await ApiClient.to.get('/api/v1/processes');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'] ?? [];
        _processes.value = data.map((e) => ProcessItem.fromJson(e)).toList();
        
        // Sort by Memory Usage descending
        _processes.sort((a, b) => b.memoryUsage.compareTo(a.memoryUsage));
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat daftar proses: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> killProcess(ProcessItem process) async {
    try {
      final res = await ApiClient.to.post('/api/v1/processes/${process.pid}/kill');
      if (res.statusCode == 200) {
        Get.snackbar('Berhasil', 'Proses ${process.name} telah dihentikan');
        loadProcesses();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghentikan proses: $e');
    }
  }
}
