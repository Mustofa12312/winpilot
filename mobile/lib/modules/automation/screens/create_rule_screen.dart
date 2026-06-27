import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';
import 'package:winpilot_mobile/modules/automation/controllers/automation_controller.dart';

class CreateRuleScreen extends StatefulWidget {
  const CreateRuleScreen({super.key});

  @override
  State<CreateRuleScreen> createState() => _CreateRuleScreenState();
}

class _CreateRuleScreenState extends State<CreateRuleScreen> {
  final _nameCtrl = TextEditingController();
  final _ctrl = Get.find<AutomationController>();
  
  String _triggerType = 'metric';
  String _metricName = 'cpu';
  String _operator = '>';
  double _metricValue = 80.0;
  
  String _actionType = 'notification';
  String _notifTitle = 'Peringatan Sistem';
  String _notifBody = 'CPU telah mencapai batas maksimal.';

  bool _isSaving = false;

  void _saveRule() async {
    if (_nameCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Nama rule tidak boleh kosong');
      return;
    }

    setState(() => _isSaving = true);

    Map<String, dynamic> tData = {};
    if (_triggerType == 'metric') {
      tData = {
        'metric': _metricName,
        'operator': _operator,
        'value': _metricValue,
        'duration': 0,
      };
    } else {
      tData = {'interval_minutes': _metricValue.toInt()};
    }

    Map<String, dynamic> aData = {};
    if (_actionType == 'notification') {
      aData = {'title': _notifTitle, 'body': _notifBody};
    }

    final success = await _ctrl.createRule(
      name: _nameCtrl.text.trim(),
      triggerType: _triggerType,
      triggerData: tData,
      actionType: _actionType,
      actionData: aData,
    );

    setState(() => _isSaving = false);

    if (success) {
      Get.back();
      Get.snackbar('Sukses', 'Aturan otomatisasi berhasil dibuat');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WinPilotTheme.bgBase,
      appBar: AppBar(
        title: const Text('Buat Workflow', style: TextStyle(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('NAMA WORKFLOW', style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: WinPilotTheme.textMuted)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: WinPilotTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Contoh: Alert CPU Tinggi',
                hintStyle: const TextStyle(color: WinPilotTheme.textMuted),
                filled: true,
                fillColor: WinPilotTheme.bgCard,
                border: OutlineInputBorder(borderRadius: Radii.lgBR, borderSide: BorderSide.none),
              ),
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader('IF THIS (TRIGGER)', Icons.input_rounded, WinPilotTheme.primaryBlue),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: WinPilotTheme.bgCard,
                borderRadius: Radii.lgBR,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _triggerType,
                    dropdownColor: WinPilotTheme.bgSurface,
                    style: const TextStyle(color: WinPilotTheme.textPrimary),
                    items: const [
                      DropdownMenuItem(value: 'metric', child: Text('System Metric Threshold')),
                      DropdownMenuItem(value: 'schedule', child: Text('Schedule (Time Interval)')),
                    ],
                    onChanged: (val) => setState(() => _triggerType = val!),
                    decoration: const InputDecoration(
                      labelText: 'Trigger Type',
                      labelStyle: TextStyle(color: WinPilotTheme.textMuted),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_triggerType == 'metric') ...[
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _metricName,
                            dropdownColor: WinPilotTheme.bgSurface,
                            style: const TextStyle(color: WinPilotTheme.textPrimary),
                            items: const [
                              DropdownMenuItem(value: 'cpu', child: Text('CPU %')),
                              DropdownMenuItem(value: 'ram', child: Text('RAM %')),
                            ],
                            onChanged: (val) => setState(() => _metricName = val!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _operator,
                            dropdownColor: WinPilotTheme.bgSurface,
                            style: const TextStyle(color: WinPilotTheme.textPrimary),
                            items: const [
                              DropdownMenuItem(value: '>', child: Text('Lebih dari (>)')),
                              DropdownMenuItem(value: '<', child: Text('Kurang dari (<)')),
                            ],
                            onChanged: (val) => setState(() => _operator = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Batas Nilai: ${_metricValue.toInt()}', style: const TextStyle(color: WinPilotTheme.textSecondary)),
                    Slider(
                      value: _metricValue,
                      min: 0,
                      max: 100,
                      activeColor: WinPilotTheme.primaryBlue,
                      onChanged: (val) => setState(() => _metricValue = val),
                    ),
                  ] else ...[
                    Text('Jalankan setiap: ${_metricValue.toInt()} Menit', style: const TextStyle(color: WinPilotTheme.textSecondary)),
                    Slider(
                      value: _metricValue,
                      min: 1,
                      max: 60,
                      activeColor: WinPilotTheme.primaryBlue,
                      onChanged: (val) => setState(() => _metricValue = val),
                    ),
                  ]
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader('THEN THAT (ACTION)', Icons.bolt_rounded, WinPilotTheme.warningOrange),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: WinPilotTheme.bgCard,
                borderRadius: Radii.lgBR,
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _actionType,
                    dropdownColor: WinPilotTheme.bgSurface,
                    style: const TextStyle(color: WinPilotTheme.textPrimary),
                    items: const [
                      DropdownMenuItem(value: 'notification', child: Text('Kirim Notifikasi Mobile')),
                      DropdownMenuItem(value: 'shutdown', child: Text('Shutdown Komputer')),
                      DropdownMenuItem(value: 'sleep', child: Text('Sleep Komputer')),
                    ],
                    onChanged: (val) => setState(() => _actionType = val!),
                  ),
                  const SizedBox(height: 16),
                  if (_actionType == 'notification') ...[
                    TextField(
                      onChanged: (val) => _notifTitle = val,
                      style: const TextStyle(color: WinPilotTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Judul Notifikasi',
                        labelStyle: const TextStyle(color: WinPilotTheme.textMuted),
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: WinPilotTheme.borderSubtle)),
                      ),
                      controller: TextEditingController(text: _notifTitle),
                    ),
                    TextField(
                      onChanged: (val) => _notifBody = val,
                      style: const TextStyle(color: WinPilotTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Pesan',
                        labelStyle: const TextStyle(color: WinPilotTheme.textMuted),
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: WinPilotTheme.borderSubtle)),
                      ),
                      controller: TextEditingController(text: _notifBody),
                    ),
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Perintah ini akan dikirim langsung ke PC Anda.', style: TextStyle(color: WinPilotTheme.textMuted, fontSize: 12)),
                    ),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveRule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WinPilotTheme.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: Radii.mdBR),
                ),
                child: _isSaving 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan Workflow', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: Radii.smBR),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: WinPilotTheme.textSecondary)),
      ],
    );
  }
}
