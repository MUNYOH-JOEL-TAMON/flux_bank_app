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

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.shell,
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: AppColors.shell,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Avatar — white initials on dark circle
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.elevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                user.initials,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

            const SizedBox(height: 16),

            Text(
              user.fullName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
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

            // Account details
            _buildSection(
              title: 'ACCOUNT DETAILS',
              delay: 300,
              children: [
                _buildInfoRow(
                    'Account Number', user.accountNumber, Icons.numbers),
                const Divider(color: AppColors.divider, height: 1),
                _buildInfoRow(
                  'Phone Number',
                  user.phone ?? 'Not set',
                  Icons.phone_outlined,
                ),
                const Divider(color: AppColors.divider, height: 1),
                _buildInfoRow(
                  'Account Type',
                  'Savings',
                  Icons.account_balance_wallet_outlined,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Settings
            _buildSection(
              title: 'SETTINGS',
              delay: 400,
              children: [
                _buildToggleRow(
                    'Biometric Login', false, Icons.fingerprint_outlined),
              ],
            ),

            const SizedBox(height: 32),

            // Sign Out — danger red
            FluxButton(
              'Sign Out',
              variant: FluxButtonVariant.danger,
              icon: Icons.logout_outlined,
              onPressed: () async {
                await auth.signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRouter.login, (r) => false);
                }
              },
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    required int delay,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
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
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
      String label, bool initialValue, IconData icon) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 14),
          ),
          const Spacer(),
          Switch(value: initialValue, onChanged: (v) {}),
        ],
      ),
    );
  }
}
