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

class _MobileMoneyScreenState extends State<MobileMoneyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update colors
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Color get _activeColor => _tabController.index == 0 ? AppColors.mtnYellow : AppColors.orangeMoney;
  String get _providerName => _tabController.index == 0 ? 'MTN MoMo' : 'Orange Money';

  void _submit(bool isDeposit) async {
    if (_formKey.currentState!.validate()) {
      final banking = context.read<BankingProvider>();
      final amount = double.parse(_amountController.text.replaceAll(',', ''));
      
      final success = await banking.depositMobileMoney(
        phone: _phoneController.text,
        amount: amount,
        provider: _providerName,
        isDeposit: isDeposit,
      );

      if (success && mounted) {
        setState(() {
          _isSuccess = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final banking = context.watch<BankingProvider>();

    if (_isSuccess) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(color: _activeColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.check_circle, color: _activeColor, size: 60),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              const Text('Transaction Successful!', style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: FluxButton('Done', onPressed: () {
                  setState(() {
                    _isSuccess = false;
                    _phoneController.clear();
                    _amountController.clear();
                  });
                }),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Money', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: AppColors.background,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _activeColor,
          labelColor: _activeColor,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'MTN MoMo'),
            Tab(text: 'Orange Money'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildForm(banking, AppColors.mtnYellow),
          _buildForm(banking, AppColors.orangeMoney),
        ],
      ),
    );
  }

  Widget _buildForm(BankingProvider banking, Color brandColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: brandColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: brandColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: brandColor),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bank Balance', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text('XAF ${banking.balance.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 32),
            
            if (banking.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(banking.error!, style: const TextStyle(color: AppColors.debit)),
              ),

            FluxTextField(
              label: 'Mobile Number',
              hint: 'Enter phone number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icon(Icons.phone_android, color: brandColor),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
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
                    onPressed: banking.isTransferLoading ? null : () => _submit(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: banking.isTransferLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Deposit to Bank', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: banking.isTransferLoading ? null : () => _submit(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: brandColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: brandColor),
                      ),
                    ),
                    child: const Text('Withdraw to MoMo', style: TextStyle(fontWeight: FontWeight.bold)),
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
