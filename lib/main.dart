import 'package:flutter/material.dart';
import 'package:julias_yt_dlp_ui/app_config.dart';
import 'package:julias_yt_dlp_ui/themes.dart';
import 'package:window_manager/window_manager.dart';

import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(1200, 800),
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  await AppConfig.instance.initialize();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: AppConfig.instance.modoEscuro,
        builder: (_, bool modoEscuro, __) {
          return MaterialApp(
            title: "Júlia's yt-dlp UI",
            theme: defaultLightTheme,
            darkTheme: catppuccinDarkTheme,
            themeMode: modoEscuro ? ThemeMode.dark : ThemeMode.light,
            home: const HomePage(),
          );
        });
  }
}
