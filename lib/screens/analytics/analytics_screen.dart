import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flux_bank/models/transaction_model.dart';
import 'package:flux_bank/providers/banking_provider.dart';
import 'package:flux_bank/theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // 0=Week, 1=Month, 2=3 Months, 3=Year
  int _selectedPeriod = 1;

  static const _periods = ['W', 'M', '3M', 'Y'];
  static const _periodDays = [7, 30, 90, 365];

  int get _days => _periodDays[_selectedPeriod];

  /// Filter transactions to the selected period
  List<TransactionModel> _filtered(List<TransactionModel> all) {
    final cutoff = DateTime.now().subtract(Duration(days: _days));
    return all.where((t) => t.timestamp.isAfter(cutoff)).toList();
  }

  double _totalCredits(List<TransactionModel> txs) =>
      txs.where((t) => t.isCredit).fold(0, (s, t) => s + t.amount);

  double _totalDebits(List<TransactionModel> txs) =>
      txs.where((t) => !t.isCredit).fold(0, (s, t) => s + t.amount);

  /// Build daily income/spending spots for the line chart.
  /// Returns two lists: [creditSpots, debitSpots]
  List<List<FlSpot>> _buildSpots(List<TransactionModel> txs) {
    final now = DateTime.now();
    final creditSpots = <FlSpot>[];
    final debitSpots = <FlSpot>[];

    // Determine bucket count & label step
    int buckets = _days <= 7 ? _days : (_days <= 30 ? 10 : (_days <= 90 ? 9 : 12));

    for (int i = 0; i < buckets; i++) {
      final bucketSize = _days / buckets;
      final end = now.subtract(Duration(hours: (i * bucketSize * 24).round()));
      final start =
          now.subtract(Duration(hours: ((i + 1) * bucketSize * 24).round()));

      final bucket = txs.where(
          (t) => t.timestamp.isAfter(start) && t.timestamp.isBefore(end));

      final xVal = (buckets - 1 - i).toDouble();
      creditSpots.add(FlSpot(
          xVal, bucket.where((t) => t.isCredit).fold(0.0, (s, t) => s + t.amount)));
      debitSpots.add(FlSpot(
          xVal, bucket.where((t) => !t.isCredit).fold(0.0, (s, t) => s + t.amount)));
    }

    return [creditSpots, debitSpots];
  }

  /// Category breakdown — top spending categories
  Map<TransactionCategory, double> _categoryBreakdown(
      List<TransactionModel> txs) {
    final map = <TransactionCategory, double>{};
    for (final t in txs.where((t) => !t.isCredit)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    final sorted = Map.fromEntries(
        map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
    // Return top 5
    return Map.fromEntries(sorted.entries.take(5));
  }

  String _fmt(double v) => NumberFormat('#,##0', 'en_US').format(v.round());

  @override
  Widget build(BuildContext context) {
    final banking = context.watch<BankingProvider>();
    final filtered = _filtered(banking.transactions);
    final income = _totalCredits(filtered);
    final spending = _totalDebits(filtered);
    final spots = _buildSpots(filtered);
    final creditSpots = spots[0];
    final debitSpots = spots[1];
    final categories = _categoryBreakdown(filtered);
    final maxY = [...creditSpots, ...debitSpots]
        .map((s) => s.y)
        .fold(0.0, (a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: AppColors.shell,
      appBar: AppBar(
        backgroundColor: AppColors.shell,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Analytics',
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: banking.isLoading && banking.transactions.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.textPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Period filter pills ──────────────────────────────
                  _buildPeriodFilter().animate().fadeIn(),

                  const SizedBox(height: 24),

                  // ── Income / Spending summary cards ──────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          label: 'Income',
                          amount: income,
                          color: AppColors.credit,
                          icon: Icons.arrow_downward_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          label: 'Spending',
                          amount: spending,
                          color: AppColors.debit,
                          icon: Icons.arrow_upward_rounded,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 24),

                  // ── Line chart ───────────────────────────────────────
                  _buildChartCard(
                    creditSpots: creditSpots,
                    debitSpots: debitSpots,
                    maxY: maxY,
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 8),

                  // Chart legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegend('Income', AppColors.credit),
                      const SizedBox(width: 24),
                      _buildLegend('Spending', AppColors.debit),
                    ],
                  ).animate().fadeIn(delay: 250.ms),

                  const SizedBox(height: 32),

                  // ── Net balance ──────────────────────────────────────
                  _buildNetCard(income: income, spending: spending)
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 32),

                  // ── Category breakdown ───────────────────────────────
                  if (categories.isNotEmpty) ...[
                    const Text(
                      'Top Spending Categories',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ).animate().fadeIn(delay: 350.ms),

                    const SizedBox(height: 16),

                    ...categories.entries.toList().asMap().entries.map((e) {
                      final idx = e.key;
                      final cat = e.value.key;
                      final amt = e.value.value;
                      final pct = spending > 0 ? amt / spending : 0.0;
                      return _buildCategoryRow(
                              cat: cat, amount: amt, pct: pct)
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: 400 + idx * 60))
                          .slideX(begin: 0.1, end: 0);
                    }),
                  ],

                  const SizedBox(height: 32),

                  // ── Transaction count ────────────────────────────────
                  _buildStatsRow(filtered)
                      .animate()
                      .fadeIn(delay: 700.ms)
                      .slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  // ── Period filter ──────────────────────────────────────────────────────────
  Widget _buildPeriodFilter() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: List.generate(_periods.length, (i) {
          final selected = _selectedPeriod == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.textPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Text(
                  _periods[i],
                  style: TextStyle(
                    color: selected ? Colors.black : AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Summary card ───────────────────────────────────────────────────────────
  Widget _buildSummaryCard({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'XAF ${_fmt(amount)}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Line chart card ────────────────────────────────────────────────────────
  Widget _buildChartCard({
    required List<FlSpot> creditSpots,
    required List<FlSpot> debitSpots,
    required double maxY,
  }) {
    // Ensure chart always has visible range even when all values are 0
    final chartMaxY = maxY < 1 ? 100.0 : maxY * 1.25;

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: chartMaxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: chartMaxY / 4,
            getDrawingHorizontalLine: (v) => FlLine(
              color: AppColors.divider,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.elevated,
              getTooltipItems: (spots) => spots.map((s) {
                final isCredit = s.barIndex == 0;
                return LineTooltipItem(
                  'XAF ${_fmt(s.y)}',
                  TextStyle(
                    color: isCredit ? AppColors.credit : AppColors.debit,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            // Income line — green
            LineChartBarData(
              spots: creditSpots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.credit,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.credit.withValues(alpha: 0.06),
              ),
            ),
            // Spending line — red
            LineChartBarData(
              spots: debitSpots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.debit,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.debit.withValues(alpha: 0.06),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Legend dot ─────────────────────────────────────────────────────────────
  Widget _buildLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  // ── Net balance card ───────────────────────────────────────────────────────
  Widget _buildNetCard({required double income, required double spending}) {
    final net = income - spending;
    final isPositive = net >= 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Net Balance',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              Text(
                '${isPositive ? '+' : '-'} XAF ${_fmt(net.abs())}',
                style: TextStyle(
                  color: isPositive ? AppColors.credit : AppColors.debit,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isPositive
                  ? AppColors.credit.withValues(alpha: 0.12)
                  : AppColors.debit.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isPositive ? 'Surplus' : 'Deficit',
              style: TextStyle(
                color: isPositive ? AppColors.credit : AppColors.debit,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category row ───────────────────────────────────────────────────────────
  Widget _buildCategoryRow({
    required TransactionCategory cat,
    required double amount,
    required double pct,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(cat.icon, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cat.label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                'XAF ${_fmt(amount)}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct.clamp(0.0, 1.0),
                    backgroundColor: AppColors.elevated,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.textPrimary),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(pct * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────────
  Widget _buildStatsRow(List<TransactionModel> filtered) {
    final credits = filtered.where((t) => t.isCredit).length;
    final debits = filtered.where((t) => !t.isCredit).length;
    return Row(
      children: [
        Expanded(
            child: _buildStatBox('Transactions', '${filtered.length}',
                Icons.receipt_long_outlined)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatBox(
                'Money In', '$credits', Icons.arrow_downward_rounded,
                color: AppColors.credit)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatBox(
                'Money Out', '$debits', Icons.arrow_upward_rounded,
                color: AppColors.debit)),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon,
      {Color color = AppColors.textSecondary}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
