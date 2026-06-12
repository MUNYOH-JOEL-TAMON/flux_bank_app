import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flux_bank/navigation/app_router.dart';
import 'package:flux_bank/providers/auth_provider.dart';
import 'package:flux_bank/theme/app_theme.dart';
import 'package:flux_bank/widgets/flux_button.dart';
import 'package:flux_bank/widgets/flux_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final auth = context.read<AuthProvider>();
      final success = await auth.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );
      if (success && mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRouter.home, (route) => false);
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
          'Create Account',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                const Text(
                  'Join FLUX',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn().slideX(begin: -0.1, end: 0),

                const SizedBox(height: 8),

                const Text(
                  'Set up your free account in seconds',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),

                const SizedBox(height: 32),

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
                  label: 'Full Name',
                  labelStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  hint: 'Enter your full name',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline,
                      color: AppColors.textSecondary, size: 20),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Name is required';
                    }
                    if (val.trim().split(' ').length < 2) {
                      return 'Enter your first and last name';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 16),

                FluxTextField(
                  label: 'Phone Number',
                  labelStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  hint: 'Enter your phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined,
                      color: AppColors.textSecondary, size: 20),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 16),

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
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 16),

                FluxTextField(
                  label: 'Password',
                  labelStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  hint: 'Create a password',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppColors.textSecondary, size: 20),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Password is required';
                    }
                    if (val.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 16),

                FluxTextField(
                  label: 'Confirm Password',
                  labelStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  hint: 'Confirm your password',
                  controller: _confirmController,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline,
                      color: AppColors.textSecondary, size: 20),
                  validator: (val) {
                    if (val != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 32),

                // Filled white "Create Account" button
                FluxButton(
                  'Create Account',
                  onPressed: _register,
                  isLoading: auth.isLoading,
                ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 24),

                // "Sign In" link
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 800.ms),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
