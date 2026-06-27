// WinPilot — App Entry Point
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:winpilot_mobile/core/network/api_client.dart';
import 'package:winpilot_mobile/core/routes/routes.dart';
import 'package:winpilot_mobile/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode on phones
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set system overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: WinPilotTheme.bgBase,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Register core services
  Get.put(ApiClient());

  runApp(const WinPilotApp());
}

class WinPilotApp extends StatelessWidget {
  const WinPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WinPilot — Windows Control Center',
      debugShowCheckedModeBanner: false,
      theme: WinPilotTheme.dark,
      darkTheme: WinPilotTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: Routes.login,
      getPages: appPages,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
