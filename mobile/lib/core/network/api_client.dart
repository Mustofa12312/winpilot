// WinPilot API Client — Dio-based HTTP client
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient extends GetxService {
  static ApiClient get to => Get.find();

  late Dio _dio;
  String _baseUrl = 'http://192.168.1.100:8080';

  void configure({required String baseUrl}) {
    _baseUrl = baseUrl;
    _dio = _buildDio();
  }

  Dio _buildDio() {
    final dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Try to refresh token
          final refreshed = await _tryRefreshToken();
          if (refreshed && error.requestOptions != null) {
            final prefs = await SharedPreferences.getInstance();
            error.requestOptions.headers['Authorization'] =
                'Bearer ${prefs.getString('access_token')}';
            final response = await _dio.fetch(error.requestOptions);
            return handler.resolve(response);
          }
        }
        handler.next(error);
      },
    ));

    return dio;
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('device_id');
      final refreshToken = prefs.getString('refresh_token');

      if (deviceId == null || refreshToken == null) return false;

      final response = await Dio(BaseOptions(baseUrl: _baseUrl)).post(
        '/api/v1/auth/refresh',
        data: {'device_id': deviceId, 'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        await prefs.setString('access_token', data['access_token']);
        await prefs.setString('refresh_token', data['refresh_token']);
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) =>
      _dio.get(path, queryParameters: params);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);

  String get wsUrl {
    final wsBase = _baseUrl.replaceFirst('http://', 'ws://');
    return '$wsBase/ws';
  }

  @override
  void onInit() {
    super.onInit();
    _dio = _buildDio();
  }
}
