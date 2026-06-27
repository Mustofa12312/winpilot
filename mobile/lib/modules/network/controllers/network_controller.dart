import 'package:get/get.dart';
import 'package:winpilot_mobile/core/network/api_client.dart';

class NetworkInfo {
  final String localIp;
  final String publicIp;
  final String ping;
  final String ssid;

  NetworkInfo({required this.localIp, required this.publicIp, required this.ping, required this.ssid});

  factory NetworkInfo.fromJson(Map<String, dynamic> json) {
    return NetworkInfo(
      localIp: json['local_ip'] ?? 'Unknown',
      publicIp: json['public_ip'] ?? 'Unknown',
      ping: json['ping'] ?? 'Unknown',
      ssid: json['ssid'] ?? 'Unknown',
    );
  }
}

class NetworkController extends GetxController {
  final _info = Rxn<NetworkInfo>();
  final _isLoading = true.obs;

  NetworkInfo? get info => _info.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadNetworkInfo();
  }

  Future<void> loadNetworkInfo() async {
    _isLoading.value = true;
    try {
      final res = await ApiClient.to.get('/api/v1/network/info');
      if (res.data != null) {
        _info.value = NetworkInfo.fromJson(res.data);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat status jaringan');
    } finally {
      _isLoading.value = false;
    }
  }
}
