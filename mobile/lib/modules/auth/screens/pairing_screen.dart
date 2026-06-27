// WinPilot Pairing Screen — OTP entry
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/auth/controllers/auth_controller.dart';

class PairingScreen extends StatelessWidget {
  const PairingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = AuthController.to;

    return Scaffold(
      backgroundColor: WinPilotTheme.bgBase,
      appBar: AppBar(
        backgroundColor: WinPilotTheme.bgBase,
        title: const Text('Pairing Perangkat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: WinPilotTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Shield icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: WinPilotTheme.primaryGradient,
                    borderRadius: Radii.xlBR,
                    boxShadow: AppShadows.glow,
                  ),
                  child: const Icon(Icons.shield_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Masukkan Kode OTP',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: WinPilotTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Buka WinPilot Agent di komputer Anda, lalu buka menu Pairing dan tampilkan kode OTP 6 digit.',
                  style: TextStyle(
                    fontSize: 14,
                    color: WinPilotTheme.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // OTP Input
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: WinPilotTheme.bgCard,
                    borderRadius: Radii.xlBR,
                    border: Border.all(color: WinPilotTheme.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: ctrl.otpController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        style: const TextStyle(
                          color: WinPilotTheme.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 12,
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '000000',
                          hintStyle: TextStyle(
                            color: WinPilotTheme.textMuted,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 12,
                          ),
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

                      Obx(() {
                        if (ctrl.error.isEmpty) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: WinPilotTheme.dangerRed.withOpacity(0.1),
                            borderRadius: Radii.mdBR,
                            border: Border.all(color: WinPilotTheme.dangerRed.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: WinPilotTheme.dangerRed, size: 16),
                              const SizedBox(width: 8),
                              Expanded(child: Text(ctrl.error,
                                style: const TextStyle(fontSize: 12, color: WinPilotTheme.dangerRed))),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 8),

                      Obx(() => SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: ctrl.isLoading
                            ? null
                            : () => ctrl.pairWithOTP(ctrl.otpController.text),
                          child: ctrl.isLoading
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Verifikasi & Pair',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      )),
                    ],
                  ),
                ),

                const Spacer(),

                // Steps guide
                _buildStepsGuide(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepsGuide() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WinPilotTheme.bgCard,
        borderRadius: Radii.lgBR,
        border: Border.all(color: WinPilotTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cara mendapatkan kode:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WinPilotTheme.textSecondary)),
          const SizedBox(height: 10),
          ...[
            '1. Buka WinPilot Agent di tray bar Windows',
            '2. Klik kanan → "Generate Pairing Code"',
            '3. Salin kode 6 digit yang muncul',
            '4. Kode berlaku 5 menit dan hanya bisa digunakan sekali',
          ].map((step) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(step,
              style: const TextStyle(fontSize: 12, color: WinPilotTheme.textMuted, height: 1.4)),
          )),
        ],
      ),
    );
  }
}
