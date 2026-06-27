// WinPilot Login Screen — Premium glassmorphism design
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/auth/controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AuthController());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: WinPilotTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: Column(
                children: [
                  // ─── Logo Section ───────────────────────────────────────
                  _buildLogo(),
                  const SizedBox(height: 48),

                  // ─── Card ───────────────────────────────────────────────
                  _buildCard(ctrl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Icon with glow effect
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: WinPilotTheme.primaryGradient,
            borderRadius: Radii.xlBR,
            boxShadow: const [
              BoxShadow(color: Color(0x602D8CFF), blurRadius: 40, spreadRadius: 0),
              BoxShadow(color: Color(0x302D8CFF), blurRadius: 80, spreadRadius: 10),
            ],
          ),
          child: const Icon(Icons.window_rounded, color: Colors.white, size: 44),
        ),
        const SizedBox(height: 24),
        const Text(
          'WinPilot',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: WinPilotTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your Personal Windows Control Center',
          style: TextStyle(
            fontSize: 14,
            color: WinPilotTheme.textSecondary,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCard(AuthController ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: WinPilotTheme.bgCard,
        borderRadius: Radii.xlBR,
        border: Border.all(color: WinPilotTheme.borderSubtle),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hubungkan ke Agent',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: WinPilotTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Masukkan IP address komputer yang menjalankan WinPilot Agent',
            style: TextStyle(fontSize: 13, color: WinPilotTheme.textMuted),
          ),
          const SizedBox(height: 28),

          // IP Input
          _buildLabel('IP Address Komputer'),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl.ipController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: WinPilotTheme.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              hintText: '192.168.1.100',
              prefixIcon: const Icon(Icons.computer_rounded, color: WinPilotTheme.textMuted),
              suffixText: 'IPv4',
              suffixStyle: const TextStyle(color: WinPilotTheme.textMuted, fontSize: 12),
              filled: true,
              fillColor: WinPilotTheme.bgSurface,
              border: OutlineInputBorder(
                borderRadius: Radii.mdBR,
                borderSide: const BorderSide(color: WinPilotTheme.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: Radii.mdBR,
                borderSide: const BorderSide(color: WinPilotTheme.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: Radii.mdBR,
                borderSide: const BorderSide(color: WinPilotTheme.primaryBlue, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Port Input
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Port'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: ctrl.portController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: WinPilotTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: '8080',
                        filled: true,
                        fillColor: WinPilotTheme.bgSurface,
                        border: OutlineInputBorder(
                          borderRadius: Radii.mdBR,
                          borderSide: const BorderSide(color: WinPilotTheme.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: Radii.mdBR,
                          borderSide: const BorderSide(color: WinPilotTheme.borderSubtle),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: Radii.mdBR,
                          borderSide: const BorderSide(color: WinPilotTheme.primaryBlue, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Error message
          Obx(() {
            if (ctrl.error.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: WinPilotTheme.dangerRed.withValues(alpha: 0.1),
                borderRadius: Radii.mdBR,
                border: Border.all(color: WinPilotTheme.dangerRed.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: WinPilotTheme.dangerRed, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ctrl.error,
                      style: const TextStyle(
                        fontSize: 13,
                        color: WinPilotTheme.dangerRed,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Connect Button
          Obx(() => SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: ctrl.isLoading ? null : ctrl.connectToAgent,
              style: ElevatedButton.styleFrom(
                backgroundColor: WinPilotTheme.primaryBlue,
                disabledBackgroundColor: WinPilotTheme.primaryBlue.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: Radii.mdBR),
                elevation: 0,
              ),
              child: ctrl.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.link_rounded, size: 20, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Hubungkan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
            ),
          )),

          const SizedBox(height: 20),

          // Help text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: WinPilotTheme.primaryBlue.withValues(alpha: 0.08),
              borderRadius: Radii.mdBR,
              border: Border.all(color: WinPilotTheme.primaryBlue.withValues(alpha: 0.2)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: WinPilotTheme.primaryBlue, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pastikan WinPilot Agent sudah berjalan di komputer Windows Anda dan berada di jaringan yang sama.',
                    style: TextStyle(fontSize: 12, color: WinPilotTheme.textSecondary, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: WinPilotTheme.textSecondary,
      letterSpacing: 0.3,
    ),
  );
}
