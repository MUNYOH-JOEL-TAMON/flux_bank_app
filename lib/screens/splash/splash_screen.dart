import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flux_bank/navigation/app_router.dart';
import 'package:flux_bank/providers/auth_provider.dart';
import 'package:flux_bank/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRouter.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shell,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // "F" logo — white rounded square, no gradient
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: const Text(
                'F',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                ),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.4, 0.4),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 20),

            const Text(
              'FLUX',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 10,
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 500.ms)
                .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),

            const SizedBox(height: 8),

            const Text(
              'Banking Reimagined',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 500.ms),

            const SizedBox(height: 60),

            SizedBox(
              width: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  backgroundColor:
                      AppColors.textPrimary.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.textPrimary),
                  minHeight: 3,
                ),
              ),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
