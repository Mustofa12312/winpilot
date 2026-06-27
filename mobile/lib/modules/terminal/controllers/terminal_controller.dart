import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/network/api_client.dart';

class TerminalEntry {
  final String command;
  final String output;
  final bool isError;
  final DateTime timestamp;

  TerminalEntry({
    required this.command,
    required this.output,
    this.isError = false,
  }) : timestamp = DateTime.now();
}

class TerminalController extends GetxController {
  final _history = <TerminalEntry>[].obs;
  final _isRunning = false.obs;
  
  final textCtrl = TextEditingController();
  final scrollCtrl = ScrollController();
  final focusNode = FocusNode();

  List<TerminalEntry> get history => _history;
  bool get isRunning => _isRunning.value;

  @override
  void onClose() {
    textCtrl.dispose();
    scrollCtrl.dispose();
    focusNode.dispose();
    super.onClose();
  }

  void clearTerminal() {
    _history.clear();
  }

  Future<void> executeCommand() async {
    final cmd = textCtrl.text.trim();
    if (cmd.isEmpty) return;

    if (cmd.toLowerCase() == 'clear' || cmd.toLowerCase() == 'cls') {
      clearTerminal();
      textCtrl.clear();
      return;
    }

    _isRunning.value = true;
    textCtrl.clear();
    
    // Add optimistic command entry (loading state)
    _history.add(TerminalEntry(command: cmd, output: 'Executing...'));
    _scrollToBottom();

    try {
      final res = await ApiClient.to.post('/api/v1/terminal/execute', data: {'command': cmd});
      final output = res.data != null && res.data['output'] != null 
          ? res.data['output'].toString().trim()
          : '';
          
      // Replace the loading entry
      _history[_history.length - 1] = TerminalEntry(
        command: cmd,
        output: output.isEmpty ? '[No Output]' : output,
        isError: res.statusCode != 200,
      );
    } catch (e) {
      _history[_history.length - 1] = TerminalEntry(
        command: cmd,
        output: 'Error: Connection failed or command timed out.',
        isError: true,
      );
    } finally {
      _isRunning.value = false;
      _scrollToBottom();
      focusNode.requestFocus(); // Keep keyboard open
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollCtrl.hasClients) {
        scrollCtrl.animateTo(
          scrollCtrl.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
