import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vitacare_flutter/login_page.dart';
import 'package:vitacare_flutter/providers/auth_provider.dart';
import 'package:vitacare_flutter/providers/patient_provider.dart';
import 'package:vitacare_flutter/screens/about_screen.dart';
import 'package:vitacare_flutter/screens/dashboard_screen.dart';
import 'package:vitacare_flutter/screens/forgot_password_page.dart';
import 'package:vitacare_flutter/screens/health_record_screen.dart';
import 'package:vitacare_flutter/screens/patient_alerts_screen.dart';
import 'package:vitacare_flutter/screens/patient_list_screen.dart';
import 'package:vitacare_flutter/screens/patient_registration_screen.dart';
import 'package:vitacare_flutter/screens/records_history_screen.dart';
import 'package:vitacare_flutter/screens/register_page.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';

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

  static const Set<String> _publicRoutes = <String>{
    '/',
    '/register',
    '/forgot-password',
  };

  static const Set<String> _privateRoutes = <String>{
    '/dashboard',
    '/patients/register',
    '/patients/list',
    '/records/register',
    '/records/history',
    '/alerts',
    '/about',
  };

  Widget _buildPage(String routeName) {
    switch (routeName) {
      case '/':
        return const LoginPage();
      case '/register':
        return const RegisterPage();
      case '/forgot-password':
        return const ForgotPasswordPage();
      case '/dashboard':
        return const DashboardScreen();
      case '/patients/register':
        return const PatientRegistrationScreen();
      case '/patients/list':
        return const PatientListScreen();
      case '/records/register':
        return const HealthRecordScreen();
      case '/records/history':
        return const RecordsHistoryScreen();
      case '/alerts':
        return const PatientAlertsScreen();
      case '/about':
        return const AboutScreen();
      default:
        return const LoginPage();
    }
  }

  Route<dynamic> _onGenerateRoute(
    BuildContext context,
    RouteSettings settings,
  ) {
    final AuthProvider authProvider = context.read<AuthProvider>();
    final String requestedRoute = settings.name ?? '/';
    final bool routeExists =
        _publicRoutes.contains(requestedRoute) ||
        _privateRoutes.contains(requestedRoute);
    final bool isPublicRoute = _publicRoutes.contains(requestedRoute);

    String resolvedRoute = requestedRoute;
    if (!routeExists) {
      resolvedRoute = authProvider.isLoggedIn ? '/dashboard' : '/';
    } else if (!authProvider.isLoggedIn && !isPublicRoute) {
      resolvedRoute = '/';
    } else if (authProvider.isLoggedIn && isPublicRoute) {
      resolvedRoute = '/dashboard';
    }

    return MaterialPageRoute<void>(
      settings: RouteSettings(name: resolvedRoute, arguments: settings.arguments),
      builder: (_) => _buildPage(resolvedRoute),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<PatientProvider>(create: (_) => PatientProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Vitacare',
            theme: ThemeData(
              textTheme: GoogleFonts.montserratTextTheme(),
              colorScheme: ColorScheme.fromSeed(
                seedColor: VitacareColors.primary,
                primary: VitacareColors.primary,
                secondary: VitacareColors.accent,
                surface: Colors.white,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: VitacareColors.background,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                foregroundColor: VitacareColors.textStrong,
                centerTitle: true,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: VitacareColors.inputFill,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: VitacareColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: VitacareColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: VitacareColors.accent,
                    width: 1.4,
                  ),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: VitacareColors.accent,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              snackBarTheme: const SnackBarThemeData(
                behavior: SnackBarBehavior.floating,
              ),
            ),
            home: authProvider.isLoggedIn
                ? const DashboardScreen()
                : const LoginPage(),
            onGenerateRoute: (settings) => _onGenerateRoute(context, settings),
          );
        },
      ),
    );
  }
}
