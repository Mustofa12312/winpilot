import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';

class DiscoveredDevice {
  final String ip;
  final String hostname;
  final DateTime lastSeen;

  DiscoveredDevice({required this.ip, required this.hostname, required this.lastSeen});
}

class DiscoveryController extends GetxController {
  final isScanning = false.obs;
  final discoveredDevices = <DiscoveredDevice>[].obs;
  RawDatagramSocket? _socket;
  Timer? _broadcastTimer;

  @override
  void onInit() {
    super.onInit();
    startScanning();
  }

  @override
  void onClose() {
    stopScanning();
    super.onClose();
  }

  Future<void> startScanning() async {
    if (isScanning.value) return;
    isScanning.value = true;
    discoveredDevices.clear();

    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _socket!.broadcastEnabled = true;

      _socket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          Datagram? datagram = _socket!.receive();
          if (datagram != null) {
            String message = utf8.decode(datagram.data);
            if (message.startsWith('WINPILOT_HERE')) {
              final parts = message.split('|');
              final hostname = parts.length > 1 ? parts[1] : 'Unknown PC';
              
              _addOrUpdateDevice(datagram.address.address, hostname);
            }
          }
        }
      });

      // Send broadcast every 2 seconds
      _broadcastTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        _sendBroadcast();
      });
      _sendBroadcast();

    } catch (e) {
      isScanning.value = false;
    }
  }

  void _sendBroadcast() {
    if (_socket == null) return;
    final data = utf8.encode('WINPILOT_DISCOVER');
    // 255.255.255.255 is the standard limited broadcast address
    _socket!.send(data, InternetAddress('255.255.255.255'), 8888);
  }

  void stopScanning() {
    _broadcastTimer?.cancel();
    _socket?.close();
    isScanning.value = false;
  }

  void _addOrUpdateDevice(String ip, String hostname) {
    final index = discoveredDevices.indexWhere((d) => d.ip == ip);
    if (index >= 0) {
      discoveredDevices[index] = DiscoveredDevice(ip: ip, hostname: hostname, lastSeen: DateTime.now());
      discoveredDevices.refresh();
    } else {
      discoveredDevices.add(DiscoveredDevice(ip: ip, hostname: hostname, lastSeen: DateTime.now()));
    }
  }
}
