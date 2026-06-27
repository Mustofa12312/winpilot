import 'package:get/get.dart';
import 'package:winpilot_mobile/core/network/api_client.dart';

class WinDevice {
  final String name;
  final String description;
  final String manufacturer;
  final String status;
  final String deviceClass;

  WinDevice({
    required this.name, required this.description,
    required this.manufacturer, required this.status, required this.deviceClass,
  });

  factory WinDevice.fromJson(Map<String, dynamic> json) {
    return WinDevice(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      status: json['status'] ?? 'Unknown',
      deviceClass: json['class'] ?? 'Other',
    );
  }
}

class DeviceController extends GetxController {
  final _devices = <WinDevice>[].obs;
  final _isLoading = true.obs;

  List<WinDevice> get devices => _devices;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadDevices();
  }

  Future<void> loadDevices() async {
    _isLoading.value = true;
    try {
      final res = await ApiClient.to.get('/api/v1/devices');
      if (res.data != null && res.data is List) {
        _devices.value = (res.data as List).map((e) => WinDevice.fromJson(e)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat daftar perangkat keras');
    } finally {
      _isLoading.value = false;
    }
  }
}
