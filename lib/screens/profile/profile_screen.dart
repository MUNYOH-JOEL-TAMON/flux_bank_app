import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flux_bank/navigation/app_router.dart';
import 'package:flux_bank/providers/auth_provider.dart';
import 'package:flux_bank/theme/app_theme.dart';
import 'package:flux_bank/widgets/flux_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Avatar & Info
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                user.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            
            const SizedBox(height: 16),
            
            Text(
              user.fullName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 100.ms),
            
            const SizedBox(height: 4),
            
            Text(
              user.email,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ).animate().fadeIn(delay: 200.ms),
            
            const SizedBox(height: 32),
            
            // Details Section
            _buildSection(
              title: 'Account Details',
              delay: 300,
              children: [
                _buildInfoRow('Account Number', user.accountNumber, Icons.numbers),
                const Divider(),
                _buildInfoRow('Phone Number', user.phone ?? 'Not set', Icons.phone_outlined),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Settings Section
            _buildSection(
              title: 'Settings',
              delay: 400,
              children: [
                _buildToggleRow('Push Notifications', true, Icons.notifications_outlined),
                const Divider(),
                _buildToggleRow('Biometric Login', false, Icons.fingerprint),
                const Divider(),
                _buildToggleRow('Dark Mode', true, Icons.dark_mode_outlined),
              ],
            ),
            
            const SizedBox(height: 32),
            
            FluxButton(
              'Sign Out',
              variant: FluxButtonVariant.danger,
              icon: Icons.logout,
              onPressed: () async {
                await auth.signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (r) => false);
                }
              },
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children, required int delay}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
          const Spacer(),
          Text(value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, bool initialValue, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
          const Spacer(),
          Switch(
            value: initialValue,
            onChanged: (v) {},
          ),
        ],
      ),
    );
  }
}
