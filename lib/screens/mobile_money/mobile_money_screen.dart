import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flux_bank/providers/banking_provider.dart';
import 'package:flux_bank/theme/app_theme.dart';
import 'package:flux_bank/widgets/flux_button.dart';
import 'package:flux_bank/widgets/flux_text_field.dart';

class MobileMoneyScreen extends StatefulWidget {
  const MobileMoneyScreen({super.key});

  @override
  State<MobileMoneyScreen> createState() => _MobileMoneyScreenState();
}

class _MobileMoneyScreenState extends State<MobileMoneyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color get _activeColor =>
      _tabController.index == 0 ? AppColors.mtnYellow : AppColors.orangeMoney;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shell,
      appBar: AppBar(
        title: const Text('Mobile Money'),
        elevation: 0,
        backgroundColor: AppColors.shell,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _activeColor,
          labelColor: _activeColor,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'MTN MoMo'),
            Tab(text: 'Orange Money'),
          ],
        ),
      ),
      // Each tab is its own StatefulWidget — fully isolated state
      body: TabBarView(
        controller: _tabController,
        children: const [
          _MoMoTab(
            brandColor: AppColors.mtnYellow,
            providerName: 'MTN MoMo',
          ),
          _MoMoTab(
            brandColor: AppColors.orangeMoney,
            providerName: 'Orange Money',
          ),
        ],
      ),
    );
  }
}

// ─── Isolated tab widget — each instance has its own form & controllers ───────

class _MoMoTab extends StatefulWidget {
  final Color brandColor;
  final String providerName;

  const _MoMoTab({
    required this.brandColor,
    required this.providerName,
  });

  @override
  State<_MoMoTab> createState() => _MoMoTabState();
}

class _MoMoTabState extends State<_MoMoTab>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isSuccess = false;

  // Keep tab alive when switching so form state is preserved
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit(bool isDeposit) async {
    if (_formKey.currentState!.validate()) {
      final banking = context.read<BankingProvider>();
      final amount =
          double.parse(_amountController.text.replaceAll(',', ''));

      final success = await banking.depositMobileMoney(
        phone: _phoneController.text,
        amount: amount,
        provider: widget.providerName,
        isDeposit: isDeposit,
      );

      if (success && mounted) {
        setState(() => _isSuccess = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required for AutomaticKeepAliveClientMixin
    final banking = context.watch<BankingProvider>();
    final brandColor = widget.brandColor;

    if (_isSuccess) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: brandColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border:
                    Border.all(color: brandColor.withValues(alpha: 0.4)),
              ),
              child: Icon(Icons.check_circle, color: brandColor, size: 56),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

            const SizedBox(height: 24),

            const Text(
              'Transaction Successful!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: FluxButton(
                'Done',
                onPressed: () {
                  setState(() {
                    _isSuccess = false;
                    _phoneController.clear();
                    _amountController.clear();
                  });
                },
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance display with brand color accent
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: brandColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: brandColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: brandColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bank Balance',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                      Text(
                        'XAF ${banking.balance.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: 32),

            if (banking.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  banking.error!,
                  style: const TextStyle(color: AppColors.debit),
                ),
              ),

            FluxTextField(
              label: 'Mobile Number',
              hint: 'Enter phone number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icon(Icons.phone_android, color: brandColor),
              validator: (val) =>
                  val == null || val.isEmpty ? 'Required' : null,
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 20),

            FluxTextField(
              label: 'Amount (XAF)',
              hint: '0',
              controller: _amountController,
              keyboardType: TextInputType.number,
              prefixIcon: Icon(Icons.attach_money, color: brandColor),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Required';
                if (double.tryParse(val) == null) return 'Invalid amount';
                return null;
              },
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 40),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        banking.isTransferLoading ? null : () => _submit(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: banking.isTransferLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.black, strokeWidth: 2),
                          )
                        : const Text(
                            'Deposit to Bank',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: banking.isTransferLoading
                        ? null
                        : () => _submit(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: brandColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: brandColor),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Withdraw to MoMo',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}
