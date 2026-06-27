import 'package:get/get.dart';
import 'package:winpilot_mobile/core/network/api_client.dart';

class WinPrinter {
  final String name;
  final String status;
  final bool isDefault;

  WinPrinter({required this.name, required this.status, required this.isDefault});

  factory WinPrinter.fromJson(Map<String, dynamic> json) {
    return WinPrinter(
      name: json['name'] ?? '',
      status: json['status'] ?? 'Unknown',
      isDefault: json['is_default'] ?? false,
    );
  }
}

class PrinterController extends GetxController {
  final _printers = <WinPrinter>[].obs;
  final _isLoading = true.obs;

  List<WinPrinter> get printers => _printers;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadPrinters();
  }

  Future<void> loadPrinters() async {
    _isLoading.value = true;
    try {
      final res = await ApiClient.to.get('/api/v1/printers');
      if (res.data != null && res.data is List) {
        _printers.value = (res.data as List).map((e) => WinPrinter.fromJson(e)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat daftar printer');
    } finally {
      _isLoading.value = false;
    }
  }
}
