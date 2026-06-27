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
import 'package:winpilot_mobile/modules/terminal/screens/terminal_screen.dart';
import 'package:winpilot_mobile/modules/dashboard/screens/notification_screen.dart';
import 'package:winpilot_mobile/modules/services/screens/service_screen.dart';
import 'package:winpilot_mobile/modules/clipboard/screens/clipboard_screen.dart';
import 'package:winpilot_mobile/modules/apps/screens/app_screen.dart';
import 'package:winpilot_mobile/modules/printers/screens/printer_screen.dart';
import 'package:winpilot_mobile/modules/downloads/screens/download_screen.dart';
import 'package:winpilot_mobile/modules/devices/screens/device_screen.dart';
import 'package:winpilot_mobile/modules/network/screens/network_screen.dart';
import 'package:winpilot_mobile/modules/update/screens/update_screen.dart';
import 'package:winpilot_mobile/modules/screen/screens/screen_viewer.dart';

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
  static const String terminal = '/terminal';
  static const String notifications = '/notifications';
  static const String services = '/services';
  static const String clipboard = '/clipboard';
  static const String apps = '/apps';
  static const String printers = '/printers';
  static const String downloads = '/downloads';
  static const String devices = '/devices';
  static const String network = '/network';
  static const String update = '/update';
  static const String screen = '/screen';
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
  GetPage(name: Routes.terminal, page: () => const TerminalScreen(), transition: Transition.rightToLeft),
  GetPage(name: Routes.notifications, page: () => const NotificationScreen(), transition: Transition.rightToLeft),
  GetPage(name: Routes.services, page: () => const ServiceScreen(), transition: Transition.rightToLeft),
  GetPage(name: Routes.clipboard, page: () => const ClipboardScreen(), transition: Transition.rightToLeft),
  GetPage(name: Routes.apps, page: () => const AppLauncherScreen(), transition: Transition.rightToLeft),
  GetPage(name: Routes.printers, page: () => const PrinterScreen(), transition: Transition.rightToLeft),
  GetPage(name: Routes.downloads, page: () => const DownloadScreen(), transition: Transition.rightToLeft),
  GetPage(name: Routes.devices, page: () => const DeviceScreen(), transition: Transition.rightToLeft),
  GetPage(name: Routes.network, page: () => const NetworkScreen(), transition: Transition.rightToLeft),
  GetPage(name: Routes.update, page: () => const UpdateScreen(), transition: Transition.rightToLeft),
  GetPage(name: Routes.screen, page: () => const ScreenViewerScreen(), transition: Transition.rightToLeft),
];
