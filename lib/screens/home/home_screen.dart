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
                BalanceCard(user: banking.user ?? user),

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
                  child: const SectionHeader(title: 'My Card'),
                ).animate().fadeIn(delay: 250.ms),

                const SizedBox(height: 16),

                // ── My Card (full width VISA) ────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _buildMiniCard(
                    label: 'VISA',
                    last4: user.accountNumber.length >= 4
                        ? user.accountNumber
                            .substring(user.accountNumber.length - 4)
                        : '4242',
                    holderName: user.fullName,
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
                    height: 150,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Builder(builder: (context) {
                      // Build last 7 days of credit/debit totals
                      final now = DateTime.now();
                      final days = List.generate(7, (i) {
                        final day = now.subtract(Duration(days: 6 - i));
                        final dayTxs = banking.transactions.where((t) {
                          return t.timestamp.year == day.year &&
                              t.timestamp.month == day.month &&
                              t.timestamp.day == day.day;
                        });
                        final income = dayTxs
                            .where((t) => t.isCredit)
                            .fold(0.0, (s, t) => s + t.amount);
                        final spend = dayTxs
                            .where((t) => !t.isCredit)
                            .fold(0.0, (s, t) => s + t.amount);
                        return [income, spend];
                      });

                      final allVals = days.expand((d) => d).toList();
                      final maxVal = allVals.fold(0.0, (a, b) => a > b ? a : b);
                      // Always show a visible chart even with no data
                      final chartMax = maxVal < 1 ? 100.0 : maxVal * 1.3;

                      final dayLabels = List.generate(7, (i) {
                        final d = now.subtract(Duration(days: 6 - i));
                        const names = ['Mo','Tu','We','Th','Fr','Sa','Su'];
                        return names[d.weekday - 1];
                      });

                      return BarChart(
                        BarChartData(
                          maxY: chartMax,
                          minY: 0,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => AppColors.elevated,
                              getTooltipItem: (group, gIdx, rod, rIdx) {
                                final label = rIdx == 0 ? 'In' : 'Out';
                                return BarTooltipItem(
                                  '$label\nXAF ${rod.toY.round()}',
                                  TextStyle(
                                    color: rIdx == 0
                                        ? AppColors.credit
                                        : AppColors.debit,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  final idx = val.toInt();
                                  if (idx < 0 || idx >= 7) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      dayLabels[idx],
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                                reservedSize: 22,
                              ),
                            ),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(7, (i) {
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: days[i][0] == 0 && days[i][1] == 0
                                      ? 2.0  // tiny placeholder so bars are visible
                                      : days[i][0],
                                  color: AppColors.credit,
                                  width: 6,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                BarChartRodData(
                                  toY: days[i][0] == 0 && days[i][1] == 0
                                      ? 2.0
                                      : days[i][1],
                                  color: AppColors.debit,
                                  width: 6,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ],
                              barsSpace: 3,
                            );
                          }),
                        ),
                      );
                    }),
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
      height: 160,
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
