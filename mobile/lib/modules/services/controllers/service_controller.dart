import 'package:get/get.dart';
import 'package:winpilot_mobile/core/network/api_client.dart';

class WinService {
  final String name;
  final String displayName;
  final String status;

  WinService({required this.name, required this.displayName, required this.status});

  factory WinService.fromJson(Map<String, dynamic> json) {
    return WinService(
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
      status: json['status'] ?? 'Stopped',
    );
  }
}

class ServiceController extends GetxController {
  final _services = <WinService>[].obs;
  final _isLoading = true.obs;

  List<WinService> get services => _services;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  Future<void> loadServices() async {
    _isLoading.value = true;
    try {
      final res = await ApiClient.to.get('/api/v1/services');
      if (res.data != null && res.data is List) {
        _services.value = (res.data as List).map((e) => WinService.fromJson(e)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat services');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> toggleService(String name, bool isRunning) async {
    final action = isRunning ? 'stop' : 'start';
    try {
      await ApiClient.to.post('/api/v1/services/$name/toggle', data: {'action': action});
      // Refresh list to verify status
      await loadServices();
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengubah status service. Pastikan Agent berjalan dengan hak Administrator.');
    }
  }
}
