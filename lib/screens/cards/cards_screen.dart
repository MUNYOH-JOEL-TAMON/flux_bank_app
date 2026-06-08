import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flux_bank/providers/auth_provider.dart';
import 'package:flux_bank/theme/app_theme.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  bool _isFlipped = false;
  bool _isFrozen = false;
  bool _onlinePayments = true;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.shell,
      appBar: AppBar(
        title: const Text('My Cards'),
        elevation: 0,
        backgroundColor: AppColors.shell,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Adding new cards is simulated.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flip card
            GestureDetector(
              onTap: () => setState(() => _isFlipped = !_isFlipped),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder:
                    (Widget child, Animation<double> animation) {
                  final rotateAnim =
                      Tween(begin: 3.14, end: 0.0).animate(animation);
                  return AnimatedBuilder(
                    animation: rotateAnim,
                    builder: (context, child) {
                      final isUnder =
                          (ValueKey(_isFlipped) != child!.key);
                      var tilt =
                          ((animation.value - 0.5).abs() - 0.5) * 0.003;
                      tilt *= isUnder ? -1.0 : 1.0;
                      final value = isUnder
                          ? _clamp(rotateAnim.value, 0, 3.14 / 2)
                          : rotateAnim.value;
                      return Transform(
                        transform: Matrix4.rotationY(value)
                          ..setEntry(3, 0, tilt),
                        alignment: Alignment.center,
                        child: child,
                      );
                    },
                    child: child,
                  );
                },
                child: _isFlipped
                    ? _buildCardBack(user.fullName)
                    : _buildCardFront(
                        user.fullName, user.accountNumber),
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),
            Center(
              child: Text(
                'Tap card to flip',
                style: const TextStyle(
                    color: AppColors.textTertiary, fontSize: 12),
              ),
            ),

            const SizedBox(height: 32),

            // Card Settings
            const Text(
              'CARD SETTINGS',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  _buildSettingSwitch(
                    'Freeze Card',
                    'Temporarily disable your card',
                    Icons.ac_unit_outlined,
                    _isFrozen,
                    (v) => setState(() => _isFrozen = v),
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  _buildSettingSwitch(
                    'Online Payments',
                    'Allow internet transactions',
                    Icons.language_outlined,
                    _onlinePayments,
                    (v) => setState(() => _onlinePayments = v),
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  _buildSettingTile(
                    'Change PIN',
                    'Update your 4-digit card PIN',
                    Icons.dialpad_outlined,
                    () {},
                  ),
                  const Divider(color: AppColors.divider, height: 1),
                  _buildSettingTile(
                    'Spending Limits',
                    'Set daily transaction limits',
                    Icons.tune_outlined,
                    () {},
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 32),

            // Monthly summary
            const Text(
              'MONTHLY SUMMARY',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Spent this month',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'XAF 145,000',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.45,
                      backgroundColor: AppColors.elevated,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.textPrimary),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '45% of XAF 320,000 limit',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  double _clamp(double val, double min, double max) {
    if (val < min) return min;
    if (val > max) return max;
    return val;
  }

  Widget _buildCardFront(String name, String account) {
    final act = account.length >= 4
        ? account.substring(account.length - 4)
        : '4242';
    return Container(
      key: const ValueKey(false),
      width: double.infinity,
      height: 210,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Align(
            alignment: Alignment.topRight,
            child: Text(
              'VISA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Icon(Icons.wifi,
                color: Colors.white.withValues(alpha: 0.4), size: 28),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '4532  ••••  ••••  $act',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 1.5,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CARDHOLDER',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 10,
                      letterSpacing: 1),
                ),
                Text(
                  name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'VALID THRU',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 10,
                      letterSpacing: 1),
                ),
                const Text(
                  '12/28',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(String name) {
    return Container(
      key: const ValueKey(true),
      width: double.infinity,
      height: 210,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Container(height: 44, color: Colors.black54),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: const Text(
                    '831',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Issued by FLUX BANK. Property of issuer; return upon request.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.textSecondary, size: 18),
      ),
      title: Text(title,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 12)),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.textSecondary, size: 18),
      ),
      title: Text(title,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right,
          color: AppColors.textTertiary, size: 20),
      onTap: onTap,
    );
  }
}
