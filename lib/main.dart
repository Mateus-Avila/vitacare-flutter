import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vitacare_flutter/core/vitacare_routes.dart';
import 'package:vitacare_flutter/providers/auth_provider.dart';
import 'package:vitacare_flutter/providers/patient_provider.dart';
import 'package:vitacare_flutter/screens/about_screen.dart';
import 'package:vitacare_flutter/screens/dashboard_screen.dart';
import 'package:vitacare_flutter/screens/forgot_password_page.dart';
import 'package:vitacare_flutter/screens/health_record_screen.dart';
import 'package:vitacare_flutter/screens/login_page.dart';
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

  Widget _buildPage(String routeName, {Object? arguments}) {
    switch (routeName) {
      case VitacareRoutes.login:
        return const LoginPage();
      case VitacareRoutes.register:
        return const RegisterPage();
      case VitacareRoutes.forgotPassword:
        return const ForgotPasswordPage();
      case VitacareRoutes.dashboard:
        return const DashboardScreen();
      case VitacareRoutes.patientRegistration:
        return const PatientRegistrationScreen();
      case VitacareRoutes.patientList:
        return const PatientListScreen();
      case VitacareRoutes.healthRecord:
        return const HealthRecordScreen();
      case VitacareRoutes.recordsHistory:
        return RecordsHistoryScreen(
          initialPatientId: arguments is String ? arguments : null,
        );
      case VitacareRoutes.alerts:
        return const PatientAlertsScreen();
      case VitacareRoutes.about:
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
    final String requestedRoute = settings.name ?? VitacareRoutes.login;
    final bool routeExists =
        VitacareRoutes.publicRoutes.contains(requestedRoute) ||
        VitacareRoutes.privateRoutes.contains(requestedRoute);
    final bool isPublicRoute = VitacareRoutes.publicRoutes.contains(
      requestedRoute,
    );

    String resolvedRoute = requestedRoute;
    if (!routeExists) {
      resolvedRoute = authProvider.isLoggedIn
          ? VitacareRoutes.dashboard
          : VitacareRoutes.login;
    } else if (!authProvider.isLoggedIn && !isPublicRoute) {
      resolvedRoute = VitacareRoutes.login;
    } else if (authProvider.isLoggedIn && isPublicRoute) {
      resolvedRoute = VitacareRoutes.dashboard;
    }

    return PageRouteBuilder<void>(
      settings: RouteSettings(
        name: resolvedRoute,
        arguments: settings.arguments,
      ),
      pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: _buildPage(resolvedRoute, arguments: settings.arguments),
      ),
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
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
              colorScheme: ColorScheme.fromSeed(
                seedColor: VitacareColors.primary,
                brightness: Brightness.light,
              ).copyWith(
                primary: VitacareColors.primary,
                onPrimary: Colors.white,
                secondary: VitacareColors.accent,
                surface: Colors.white,
                onSurface: VitacareColors.textStrong,
                outline: VitacareColors.border,
              ),
              textTheme: GoogleFonts.montserratTextTheme(),
              useMaterial3: true,
              scaffoldBackgroundColor: VitacareColors.background,
              appBarTheme: const AppBarTheme(
                backgroundColor: VitacareColors.background,
                foregroundColor: VitacareColors.textStrong,
                centerTitle: false,
                scrolledUnderElevation: 0,
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Colors.redAccent,
                    width: 1.4,
                  ),
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                color: Colors.white,
                surfaceTintColor: Colors.white,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                  side: const BorderSide(color: VitacareColors.border),
                ),
              ),
              navigationDrawerTheme: const NavigationDrawerThemeData(
                backgroundColor: Colors.white,
                elevation: 0,
                indicatorColor: VitacareColors.surfaceTint,
              ),
              filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  backgroundColor: VitacareColors.primary,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  foregroundColor: VitacareColors.primary,
                  side: const BorderSide(color: VitacareColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: VitacareColors.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              snackBarTheme: const SnackBarThemeData(
                behavior: SnackBarBehavior.floating,
                backgroundColor: VitacareColors.primary,
                contentTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              dialogTheme: DialogThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              dividerTheme: const DividerThemeData(
                color: VitacareColors.border,
                thickness: 1,
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
