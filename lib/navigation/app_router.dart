import 'package:flutter/material.dart';
import 'package:flux_bank/navigation/main_shell.dart';
import 'package:flux_bank/screens/splash/splash_screen.dart';
import 'package:flux_bank/screens/onboarding/onboarding_screen.dart';
import 'package:flux_bank/screens/auth/login_screen.dart';
import 'package:flux_bank/screens/auth/register_screen.dart';
import 'package:flux_bank/screens/auth/forgot_password_screen.dart';
import 'package:flux_bank/screens/transfer/transfer_screen.dart';
import 'package:flux_bank/screens/quiz/quiz_screen.dart';
import 'package:flux_bank/screens/analytics/analytics_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String transfer = '/transfer';
  static const String quiz = '/quiz';
  static const String analytics = '/analytics';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        onboarding: (context) => const OnboardingScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        forgotPassword: (context) => const ForgotPasswordScreen(),
        home: (context) => const MainShell(),
        transfer: (context) => const TransferScreen(),
        quiz: (context) => const QuizScreen(),
        analytics: (context) => const AnalyticsScreen(),
      };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(
        builder: builder,
        settings: settings,
      );
    }
    return null;
  }
}
