import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winpilot_mobile/main.dart';

void main() {
  testWidgets('WinPilot app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WinPilotApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
