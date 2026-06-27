import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/network/controllers/network_controller.dart';

class NetworkScreen extends StatelessWidget {
  const NetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(NetworkController());

    return Scaffold(
      backgroundColor: WinPilotTheme.bgBase,
      appBar: AppBar(
        title: const Text('Network Center', style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: ctrl.loadNetworkInfo,
          )
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading) {
          return const Center(child: CircularProgressIndicator(color: WinPilotTheme.primaryBlue));
        }

        final info = ctrl.info;
        if (info == null) {
          return const Center(child: Text('Gagal mengambil data', style: TextStyle(color: WinPilotTheme.textMuted)));
        }

        return RefreshIndicator(
          onRefresh: ctrl.loadNetworkInfo,
          color: WinPilotTheme.primaryBlue,
          backgroundColor: WinPilotTheme.bgCard,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInfoCard(
                icon: Icons.wifi_rounded,
                title: 'Koneksi SSID (Wi-Fi/LAN)',
                value: info.ssid,
                color: WinPilotTheme.primaryBlue,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.router_rounded,
                title: 'IP Lokal',
                value: info.localIp,
                color: WinPilotTheme.successGreen,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.public_rounded,
                title: 'IP Publik',
                value: info.publicIp,
                color: const Color(0xFF673AB7),
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.speed_rounded,
                title: 'Ping ke Google DNS (8.8.8.8)',
                value: info.ping,
                color: const Color(0xFFE67E22),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WinPilotTheme.bgCard,
        borderRadius: Radii.lgBR,
        border: Border.all(color: WinPilotTheme.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: WinPilotTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: WinPilotTheme.textPrimary, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
