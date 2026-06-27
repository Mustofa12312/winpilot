import 'package:get/get.dart';
import 'package:winpilot_mobile/core/network/api_client.dart';

class UpdateInfo {
  final String status;
  final int count;

  UpdateInfo({required this.status, required this.count});

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      status: json['status'] ?? 'Unknown',
      count: json['count'] ?? 0,
    );
  }
}

class UpdateController extends GetxController {
  final _info = Rxn<UpdateInfo>();
  final _isLoading = true.obs;

  UpdateInfo? get info => _info.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    checkUpdate();
  }

  Future<void> checkUpdate() async {
    _isLoading.value = true;
    try {
      final res = await ApiClient.to.get('/api/v1/os/update');
      if (res.data != null) {
        _info.value = UpdateInfo.fromJson(res.data);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat status Windows Update');
    } finally {
      _isLoading.value = false;
    }
  }
}
