import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flux_bank/navigation/app_router.dart';
import 'package:flux_bank/providers/auth_provider.dart';
import 'package:flux_bank/providers/localization_provider.dart';
import 'package:flux_bank/theme/app_theme.dart';
import 'package:flux_bank/widgets/flux_button.dart';
import 'package:flux_bank/widgets/flux_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      final auth = context.read<AuthProvider>();
      final success = await auth.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loc = context.watch<LocalizationProvider>();

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),

                // "F" logo mark — white square, centered
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'F',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 28),

                Center(
                  child: Text(
                    loc.t('welcome_back'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: 6),

                Center(
                  child: Text(
                    loc.t('sign_in_to_flux'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: 28),

                // Error banner
                if (auth.error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.debit.withValues(alpha: 0.12),
                      border: Border.all(
                          color: AppColors.debit.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.debit, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            auth.error!,
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: -0.1, end: 0),
                  const SizedBox(height: 16),
                ],

                FluxTextField(
                  label: loc.t('email'),
                  labelStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  hint: loc.t('email_hint'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.mail_outline,
                      color: AppColors.textSecondary, size: 20),
                  validator: (val) {
                    if (val == null || val.isEmpty) return loc.t('email_required');
                    if (!val.contains('@')) return loc.t('invalid_email');
                    return null;
                  },
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 14),

                FluxTextField(
                  label: loc.t('password'),
                  labelStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  hint: loc.t('password_hint'),
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppColors.textSecondary, size: 20),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return loc.t('password_required');
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 4),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRouter.forgotPassword),
                    child: Text(
                      loc.t('forgot_password_q'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 16),

                // Two buttons: outlined "Register" + filled "Sign In"
                Row(
                  children: [
                    Expanded(
                      child: FluxButton(
                        loc.t('sign_up'),
                        variant: FluxButtonVariant.secondary,
                        isDark: true,
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRouter.register),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FluxButton(
                        loc.t('sign_in'),
                        onPressed: _signIn,
                        isLoading: auth.isLoading,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 24),

                // "Or" divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        loc.t('or'),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.white24)),
                  ],
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: 16),

                // Google social button
                _buildSocialButton(
                  label: loc.t('continue_google'),
                  icon: Icons.g_mobiledata,
                  onTap: () {},
                ).animate().fadeIn(delay: 800.ms),

                const SizedBox(height: 12),

                // Apple social button
                _buildSocialButton(
                  label: loc.t('continue_apple'),
                  icon: Icons.apple,
                  onTap: () {},
                ).animate().fadeIn(delay: 900.ms),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
