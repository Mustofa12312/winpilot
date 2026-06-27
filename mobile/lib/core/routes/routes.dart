// WinPilot Routes — GetX Named Routes
import 'package:get/get.dart';
import 'package:winpilot_mobile/modules/auth/screens/login_screen.dart';
import 'package:winpilot_mobile/modules/auth/screens/pairing_screen.dart';
import 'package:winpilot_mobile/modules/dashboard/screens/dashboard_screen.dart';

class Routes {
  Routes._();
  static const String login = '/login';
  static const String pairing = '/pairing';
  static const String home = '/';
}

List<GetPage> get appPages => [
  GetPage(name: Routes.login, page: () => const LoginScreen(), transition: Transition.fadeIn),
  GetPage(name: Routes.pairing, page: () => const PairingScreen(), transition: Transition.rightToLeft),
  GetPage(name: Routes.home, page: () => const DashboardScreen(), transition: Transition.fadeIn),
];
