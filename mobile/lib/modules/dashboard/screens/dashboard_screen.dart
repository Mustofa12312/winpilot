// WinPilot Dashboard Screen — Mission Control
// Realtime metrics, quick actions, notifications — all on one screen
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:winpilot_mobile/modules/dashboard/models/metrics_model.dart';
import 'package:winpilot_mobile/modules/dashboard/widgets/metric_card.dart';
import 'package:winpilot_mobile/modules/dashboard/widgets/quick_action_grid.dart';
import 'package:winpilot_mobile/modules/dashboard/widgets/health_score_ring.dart';
import 'package:winpilot_mobile/modules/dashboard/widgets/disk_bars.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: WinPilotTheme.bgBase,
      body: Container(
        decoration: const BoxDecoration(gradient: WinPilotTheme.backgroundGradient),
        child: SafeArea(
          child: Obx(() {
            if (ctrl.isLoading) return const _LoadingView();
            return RefreshIndicator(
              color: WinPilotTheme.primaryBlue,
              backgroundColor: WinPilotTheme.bgCard,
              onRefresh: ctrl.refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildAppBar(ctrl),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 8),
                        _buildStatusBar(ctrl),
                        const SizedBox(height: 20),
                        _buildHealthAndMetrics(ctrl),
                        const SizedBox(height: 20),
                        _buildQuickActions(ctrl),
                        const SizedBox(height: 20),
                        _buildDiskSection(ctrl),
                        const SizedBox(height: 20),
                        _buildNetworkCard(ctrl),
                        const SizedBox(height: 20),
                        _buildNotifications(ctrl),
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(DashboardController ctrl) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      floating: true,
      pinned: false,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: WinPilotTheme.primaryGradient,
              borderRadius: Radii.mdBR,
            ),
            child: const Icon(Icons.window_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('WinPilot', style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: WinPilotTheme.textPrimary)),
              Obx(() => Text(
                ctrl.isOnline ? 'Connected' : 'Disconnected',
                style: TextStyle(
                  fontSize: 11,
                  color: ctrl.isOnline ? WinPilotTheme.statusOnline : WinPilotTheme.statusOffline,
                  fontWeight: FontWeight.w600,
                ),
              )),
            ],
          ),
        ],
      ),
      actions: [
        // Notification badge
        Obx(() => IconButton(
          icon: Badge(
            isLabelVisible: ctrl.unreadCount > 0,
            label: Text('${ctrl.unreadCount}'),
            backgroundColor: WinPilotTheme.dangerRed,
            child: const Icon(Icons.notifications_outlined, color: WinPilotTheme.textPrimary),
          ),
          onPressed: () {},
        )),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: WinPilotTheme.textPrimary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildStatusBar(DashboardController ctrl) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ctrl.isOnline
          ? WinPilotTheme.statusOnline.withValues(alpha: 0.1)
          : WinPilotTheme.statusOffline.withValues(alpha: 0.1),
        borderRadius: Radii.lgBR,
        border: Border.all(
          color: ctrl.isOnline
            ? WinPilotTheme.statusOnline.withValues(alpha: 0.3)
            : WinPilotTheme.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: ctrl.isOnline ? WinPilotTheme.statusOnline : WinPilotTheme.statusOffline,
              shape: BoxShape.circle,
              boxShadow: ctrl.isOnline ? [
                BoxShadow(color: WinPilotTheme.statusOnline.withValues(alpha: 0.5), blurRadius: 8),
              ] : null,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            ctrl.isOnline ? '🟢 Windows 11 — Online' : '⚪ Disconnected — Reconnecting...',
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: ctrl.isOnline ? WinPilotTheme.statusOnline : WinPilotTheme.textMuted,
            ),
          ),
          const Spacer(),
          if (ctrl.wsConnected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: WinPilotTheme.primaryBlue.withValues(alpha: 0.15),
                borderRadius: Radii.smBR,
              ),
              child: const Text('LIVE', style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w800,
                color: WinPilotTheme.primaryBlue, letterSpacing: 1,
              )),
            ),
        ],
      ),
    ));
  }

  Widget _buildHealthAndMetrics(DashboardController ctrl) {
    return Obx(() {
      final m = ctrl.metrics ?? MetricsSnapshot.demo;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Health Score Ring
          HealthScoreRing(score: ctrl.healthScore),
          const SizedBox(width: 16),
          // Top 2 metrics
          Expanded(
            child: Column(
              children: [
                MetricCard(
                  label: 'CPU',
                  value: '${m.cpu.usagePercent.toStringAsFixed(1)}%',
                  subtitle: m.cpu.modelName.isNotEmpty
                    ? m.cpu.modelName.split(' ').take(3).join(' ')
                    : '${m.cpu.cores} cores',
                  percent: m.cpu.usagePercent / 100,
                  gradient: WinPilotTheme.cpuGradient,
                  icon: Icons.memory_rounded,
                ),
                const SizedBox(height: 12),
                MetricCard(
                  label: 'RAM',
                  value: '${m.ram.usedPercent.toStringAsFixed(1)}%',
                  subtitle: '${m.ram.usedGB.toStringAsFixed(1)} / ${m.ram.totalGB.toStringAsFixed(0)} GB',
                  percent: m.ram.usedPercent / 100,
                  gradient: WinPilotTheme.ramGradient,
                  icon: Icons.developer_board_rounded,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildQuickActions(DashboardController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Quick Actions'),
        const SizedBox(height: 12),
        QuickActionGrid(ctrl: ctrl),
      ],
    );
  }

  Widget _buildDiskSection(DashboardController ctrl) {
    return Obx(() {
      final disks = ctrl.metrics?.disk ?? MetricsSnapshot.demo.disk;
      if (disks.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Storage'),
          const SizedBox(height: 12),
          DiskBars(disks: disks),
        ],
      );
    });
  }

  Widget _buildNetworkCard(DashboardController ctrl) {
    return Obx(() {
      final net = ctrl.metrics?.network ?? MetricsSnapshot.demo.network;
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
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    gradient: WinPilotTheme.netGradient,
                    borderRadius: Radii.mdBR,
                  ),
                  child: const Icon(Icons.wifi_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Network', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                      color: WinPilotTheme.textPrimary)),
                    Text(net.ssid.isNotEmpty ? net.ssid : 'Not connected',
                      style: const TextStyle(fontSize: 12, color: WinPilotTheme.textMuted)),
                  ],
                ),
                const Spacer(),
                _buildSpeedChip(Icons.arrow_downward_rounded, net.downloadFormatted,
                  WinPilotTheme.successGreen),
                const SizedBox(width: 8),
                _buildSpeedChip(Icons.arrow_upward_rounded, net.uploadFormatted,
                  WinPilotTheme.primaryBlue),
              ],
            ),
            if (net.latencyMs > 0) ...[
              const SizedBox(height: 10),
              const Divider(color: WinPilotTheme.borderSubtle, height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.speed_rounded, size: 14, color: WinPilotTheme.textMuted),
                  const SizedBox(width: 6),
                  Text('Latency: ${net.latencyMs.toStringAsFixed(1)}ms',
                    style: const TextStyle(fontSize: 12, color: WinPilotTheme.textMuted)),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSpeedChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: Radii.smBR,
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildNotifications(DashboardController ctrl) {
    return Obx(() {
      final notifs = ctrl.notifications;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SectionTitle('Recent Activity'),
              const Spacer(),
              if (ctrl.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: WinPilotTheme.dangerRed,
                    borderRadius: Radii.smBR,
                  ),
                  child: Text('${ctrl.unreadCount} new',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (notifs.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: WinPilotTheme.bgCard,
                borderRadius: Radii.lgBR,
                border: Border.all(color: WinPilotTheme.borderSubtle),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: WinPilotTheme.statusOnline, size: 18),
                  SizedBox(width: 8),
                  Text('Semua berjalan normal', style: TextStyle(
                    fontSize: 13, color: WinPilotTheme.textSecondary)),
                ],
              ),
            )
          else
            ...notifs.take(5).map((n) => _buildNotifTile(n, ctrl)),
        ],
      );
    });
  }

  Widget _buildNotifTile(WinNotification n, DashboardController ctrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: n.isRead ? WinPilotTheme.bgCard : WinPilotTheme.primaryBlue.withValues(alpha: 0.08),
        borderRadius: Radii.lgBR,
        border: Border.all(
          color: n.isRead ? WinPilotTheme.borderSubtle : WinPilotTheme.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(n.icon, color: WinPilotTheme.primaryBlue, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: WinPilotTheme.textPrimary)),
                Text(n.body, style: const TextStyle(fontSize: 12, color: WinPilotTheme.textMuted)),
              ],
            ),
          ),
          if (!n.isRead)
            Container(width: 8, height: 8, decoration: const BoxDecoration(
              color: WinPilotTheme.primaryBlue, shape: BoxShape.circle)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w700, color: WinPilotTheme.textPrimary));
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: WinPilotTheme.primaryBlue),
          SizedBox(height: 16),
          Text('Menghubungkan ke Agent...', style: TextStyle(
            color: WinPilotTheme.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
