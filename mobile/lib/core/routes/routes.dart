// WinPilot Routes — GetX Named Routes
import 'package:get/get.dart';
import 'package:winpilot_mobile/modules/auth/screens/login_screen.dart';
import 'package:winpilot_mobile/modules/auth/screens/pairing_screen.dart';
import 'package:winpilot_mobile/modules/dashboard/screens/dashboard_screen.dart';
import 'package:winpilot_mobile/modules/files/screens/files_screen.dart';
import 'package:winpilot_mobile/modules/monitor/screens/monitor_screen.dart';
import 'package:winpilot_mobile/modules/tasks/screens/task_manager_screen.dart';
import 'package:winpilot_mobile/modules/automation/screens/automation_screen.dart';
import 'package:winpilot_mobile/modules/plugins/screens/plugin_screen.dart';

class Routes {
  Routes._();
  static const String login = '/login';
  static const String pairing = '/pairing';
  static const String home = '/';
  static const String files = '/files';
  static const String monitor = '/monitor';
  static const String tasks = '/tasks';
  static const String automation = '/automation';
  static const String plugins = '/plugins';
}

List<GetPage> get appPages => [
  GetPage(name: Routes.login, page: () => const LoginScreen(), transition: Transition.fadeIn),
  GetPage(name: Routes.pairing, page: () => const PairingScreen(), transition: Transition.rightToLeft),
  GetPage(name: Routes.home, page: () => const DashboardScreen(), transition: Transition.fadeIn),
  GetPage(name: Routes.files, page: () => const FilesScreen(), transition: Transition.rightToLeft),
  GetPage(name: Routes.monitor, page: () => const MonitorScreen(), transition: Transition.rightToLeft),
  GetPage(name: Routes.tasks, page: () => const TaskManagerScreen(), transition: Transition.rightToLeft),
  GetPage(name: Routes.automation, page: () => const AutomationScreen(), transition: Transition.rightToLeft),
  GetPage(name: Routes.plugins, page: () => const PluginScreen(), transition: Transition.rightToLeft),
];
