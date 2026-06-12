import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flux_bank/providers/auth_provider.dart';
import 'package:flux_bank/theme/app_theme.dart';
import 'package:flux_bank/widgets/flux_button.dart';
import 'package:flux_bank/widgets/flux_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendReset() async {
    if (_formKey.currentState!.validate()) {
      final auth = context.read<AuthProvider>();
      final success =
          await auth.resetPassword(_emailController.text.trim());
      if (success && mounted) {
        setState(() => _emailSent = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _emailSent ? _buildSuccess() : _buildForm(auth),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      key: const ValueKey('success'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.credit.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.credit.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.mark_email_read_outlined,
                  color: AppColors.credit, size: 40),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

            const SizedBox(height: 24),

            const Text(
              'Check your inbox',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ).animate().fadeIn().slideY(begin: 0.2, end: 0),

            const SizedBox(height: 12),

            Text(
              'We sent a password reset link to\n${_emailController.text}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 40),

            FluxButton(
              'Back to Sign In',
              onPressed: () => Navigator.pop(context),
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(AuthProvider auth) {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Lock icon in dark circle
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(Icons.lock_reset_outlined,
                  color: AppColors.textPrimary, size: 30),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

            const SizedBox(height: 24),

            const Text(
              'Forgot your password?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            const Text(
              'Enter the email address associated with your account and we will send you a link to reset your password.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 40),

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
              const SizedBox(height: 24),
            ],

            FluxTextField(
              label: 'Email',
              labelStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              hint: 'Enter your email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.mail_outline,
                  color: AppColors.textSecondary, size: 20),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Email is required';
                if (!val.contains('@')) return 'Enter a valid email';
                return null;
              },
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 32),

            FluxButton(
              'Send Reset Link',
              icon: Icons.send_outlined,
              onPressed: _sendReset,
              isLoading: auth.isLoading,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
