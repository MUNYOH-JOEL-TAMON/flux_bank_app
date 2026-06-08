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
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final banking = context.watch<BankingProvider>();
    final user = auth.user;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => banking.loadTransactions(user.uid),
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              user.initials,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good Morning,',
                                style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.8), fontSize: 12),
                              ),
                              Text(
                                user.fullName.split(' ').first,
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_outlined, size: 22),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),
                
                const SizedBox(height: 24),
                
                BalanceCard(user: user),
                
                const SizedBox(height: 24),
                
                // Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionItem(context, Icons.swap_horiz, 'Transfer', AppColors.primary, () => Navigator.pushNamed(context, AppRouter.transfer)),
                      _buildActionItem(context, Icons.phone_android, 'MoMo', AppColors.mtnYellow, () {}), // MoMo handled by tab
                      _buildActionItem(context, Icons.receipt_long, 'Pay Bills', AppColors.blue, () {}),
                      _buildActionItem(context, Icons.sports_esports, 'Quiz', AppColors.quizPurple, () => Navigator.pushNamed(context, AppRouter.quiz)),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 32),
                
                // Chart Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: SectionHeader(title: 'Activity'),
                ).animate().fadeIn(delay: 300.ms),
                
                const SizedBox(height: 16),
                
                if (banking.isLoading && banking.transactions.isEmpty)
                  const Padding(padding: EdgeInsets.all(20), child: ShimmerList(itemCount: 1, itemHeight: 140))
                else
                  Container(
                    height: 140,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: banking.weeklyBalanceData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                
                const SizedBox(height: 24),
                
                // Recent Transactions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SectionHeader(
                    title: 'Recent Transactions',
                    actionLabel: 'See All',
                    onAction: () {}, // Handled by bottom nav tab
                  ),
                ).animate().fadeIn(delay: 500.ms),
                
                const SizedBox(height: 16),
                
                if (banking.isLoading && banking.transactions.isEmpty)
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 20.0), child: ShimmerList(itemCount: 3))
                else if (banking.recentTransactions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No recent transactions.', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: banking.recentTransactions.map((tx) {
                        return TransactionTile(transaction: tx).animate().fadeIn().slideY(begin: 0.1, end: 0);
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

  Widget _buildActionItem(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
