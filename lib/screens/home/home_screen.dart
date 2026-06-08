import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flux_bank/navigation/app_router.dart';
import 'package:flux_bank/providers/auth_provider.dart';
import 'package:flux_bank/providers/banking_provider.dart';
import 'package:flux_bank/theme/app_theme.dart';
import 'package:flux_bank/widgets/balance_card.dart';
import 'package:flux_bank/widgets/transaction_tile.dart';
import 'package:flux_bank/widgets/shimmer_list.dart';
import 'package:flux_bank/widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onTopUp;

  const HomeScreen({super.key, this.onTopUp});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final banking = context.watch<BankingProvider>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.shell,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => banking.loadTransactions(user.uid),
          color: AppColors.textPrimary,
          backgroundColor: AppColors.elevated,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Circular avatar with initials
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.elevated,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.divider),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              user.initials,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // "Hello," gray + name white
                          Row(
                            children: [
                              const Text(
                                'Hello, ',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                user.fullName.split(' ').first,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Bell icon
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.elevated,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.notifications_outlined,
                              size: 20, color: AppColors.textPrimary),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),

                const SizedBox(height: 24),

                // ── Balance card ─────────────────────────────────────────
                BalanceCard(user: user),

                const SizedBox(height: 24),

                // ── Quick actions row ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAction(
                        context,
                        icon: Icons.arrow_upward_rounded,
                        label: 'Top Up',
                        onTap: () => onTopUp?.call(),
                      ),
                      _buildAction(
                        context,
                        icon: Icons.send_outlined,
                        label: 'Send',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRouter.transfer),
                      ),
                      _buildAction(
                        context,
                        icon: Icons.swap_horiz_rounded,
                        label: 'Transfer',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRouter.transfer),
                      ),
                      _buildAction(
                        context,
                        icon: Icons.bar_chart_rounded,
                        label: 'Analytics',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRouter.analytics),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 32),

                // ── Horizontal card scroll (VISA / Mastercard style) ─────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const SectionHeader(title: 'My Cards'),
                ).animate().fadeIn(delay: 250.ms),

                const SizedBox(height: 16),

                SizedBox(
                  height: 160,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 20, right: 8),
                    children: [
                      _buildMiniCard(
                        label: 'VISA',
                        last4: user.accountNumber.length >= 4
                            ? user.accountNumber
                                .substring(user.accountNumber.length - 4)
                            : '4242',
                        holderName: user.fullName,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 32),

                // ── Mini line chart ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const SectionHeader(title: 'Activity'),
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 16),

                if (banking.isLoading && banking.transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: ShimmerList(itemCount: 1, itemHeight: 130),
                  )
                else
                  Container(
                    height: 130,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: () {
                              final raw = banking.weeklyBalanceData;
                              final minVal = raw.reduce((a, b) => a < b ? a : b);
                              final maxVal = raw.reduce((a, b) => a > b ? a : b);
                              final range = maxVal - minVal;
                              // Normalise to 0–100 so chart always shows variation
                              return raw.asMap().entries.map((e) {
                                final y = range > 0
                                    ? ((e.value - minVal) / range) * 100
                                    : 50.0;
                                return FlSpot(e.key.toDouble(), y);
                              }).toList();
                            }(),
                            isCurved: true,
                            color: AppColors.textPrimary,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.textPrimary.withValues(alpha: 0.05),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 32),

                // ── Recent Transactions ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SectionHeader(
                    title: 'Transactions',
                    actionLabel: 'See all',
                    onAction: () {},
                  ),
                ).animate().fadeIn(delay: 450.ms),

                const SizedBox(height: 16),

                if (banking.isLoading && banking.transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: ShimmerList(itemCount: 3),
                  )
                else if (banking.recentTransactions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No recent transactions.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: banking.recentTransactions.map((tx) {
                        return TransactionTile(transaction: tx)
                            .animate()
                            .fadeIn()
                            .slideY(begin: 0.1, end: 0);
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Quick action item — dark rounded container, white icon + label
  Widget _buildAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.textPrimary, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Mini VISA/Mastercard dark card
  Widget _buildMiniCard({
    required String label,
    required String last4,
    required String holderName,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Stack(
        children: [
          // Card type label
          Align(
            alignment: Alignment.topRight,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          // NFC icon
          Align(
            alignment: Alignment.topLeft,
            child: Icon(Icons.wifi,
                color: Colors.white.withValues(alpha: 0.4), size: 22),
          ),
          // Card number
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                '•••• •••• •••• $last4',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  letterSpacing: 1.5,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          // Holder name bottom-left
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
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  holderName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Expiry bottom-right
          const Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'VALID',
                  style: TextStyle(
                    color: Color(0x66FFFFFF),
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '12/28',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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
}
