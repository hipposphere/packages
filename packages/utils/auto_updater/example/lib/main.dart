import 'package:auto_updater_example/pages/home.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:material_ui/material_ui.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final window = WindowManager.instance.getCurrent();
  if (window == null) throw StateError('The application window is unavailable.');
  runApp(MyApp(window: window));
  window.show();
  window.focus();
}

class MyApp extends StatefulWidget {
  const MyApp({required this.window, super.key});

  final Window window;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xff416ff4),
        canvasColor: Colors.white,
        scaffoldBackgroundColor: const Color(0xffF7F9FB),
        dividerColor: Colors.grey.withValues(alpha: 0.3),
      ),
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      home: HomePage(window: widget.window),
    );
  }
}
