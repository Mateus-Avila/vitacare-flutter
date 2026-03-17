import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vitacare_flutter/login_page.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const VitacareApp(),
    ),
  );
}

class VitacareApp extends StatelessWidget {
  const VitacareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vitacare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF103E69),
          primary: const Color(0xFF103E69),
          secondary: const Color(0xFF1396AA),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3FAFC),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const LoginPage(),
    );
  }
}
