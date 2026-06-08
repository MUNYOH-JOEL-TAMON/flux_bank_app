import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flux_bank/providers/banking_provider.dart';
import 'package:flux_bank/theme/app_theme.dart';
import 'package:flux_bank/widgets/flux_button.dart';
import 'package:flux_bank/widgets/flux_text_field.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  bool _isSuccess = false;

  @override
  void dispose() {
    _accountController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final banking = context.read<BankingProvider>();
      final amount =
          double.parse(_amountController.text.replaceAll(',', ''));

      final success = await banking.transfer(
        toAccount: _accountController.text,
        toName: 'Simulated Recipient',
        amount: amount,
        description: _descController.text,
      );

      if (success && mounted) {
        setState(() => _isSuccess = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final banking = context.watch<BankingProvider>();

    return Scaffold(
      backgroundColor: AppColors.shell,
      appBar: AppBar(
        title: const Text('Transfer Money'),
        backgroundColor: AppColors.shell,
        elevation: 0,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _isSuccess
              ? _buildSuccess(context)
              : _buildForm(context, banking),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, BankingProvider banking) {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available balance card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.elevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_wallet_outlined,
                        color: AppColors.textPrimary, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available Balance',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'XAF ${banking.balance.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: 32),

            // Error
            if (banking.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.debit.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.debit.withValues(alpha: 0.4)),
                ),
                child: Text(banking.error!,
                    style: const TextStyle(color: AppColors.debit)),
              ).animate().fadeIn(),
              const SizedBox(height: 16),
            ],

            FluxTextField(
              label: 'Recipient Account Number',
              hint: 'Enter 10-digit account number',
              controller: _accountController,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.person_outline,
                  color: AppColors.textSecondary),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Required';
                if (val.length < 5) return 'Invalid account number';
                return null;
              },
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 20),

            FluxTextField(
              label: 'Amount (XAF)',
              hint: '0',
              controller: _amountController,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.attach_money,
                  color: AppColors.textSecondary),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Required';
                final amount =
                    double.tryParse(val.replaceAll(',', ''));
                if (amount == null || amount <= 0) return 'Invalid amount';
                if (amount > banking.balance) {
                  return 'Insufficient balance';
                }
                return null;
              },
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 20),

            FluxTextField(
              label: 'Description (Optional)',
              hint: 'What is this for?',
              controller: _descController,
              prefixIcon: const Icon(Icons.edit_note,
                  color: AppColors.textSecondary),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 40),

            // White filled "Send Money"
            FluxButton(
              'Send Money',
              icon: Icons.send_rounded,
              isLoading: banking.isTransferLoading,
              onPressed: _submit,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Center(
      key: const ValueKey('success'),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.credit.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.credit.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.check_circle_outline,
                  color: AppColors.credit, size: 56),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

            const SizedBox(height: 32),

            const Text(
              'Transfer Successful!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn().slideY(begin: 0.2, end: 0),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  _buildReceiptRow(
                      'Amount', 'XAF ${_amountController.text}'),
                  const Divider(color: AppColors.divider, height: 24),
                  _buildReceiptRow('To', _accountController.text),
                  const Divider(color: AppColors.divider, height: 24),
                  _buildReceiptRow(
                      'Date',
                      DateTime.now()
                          .toString()
                          .substring(0, 16)),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 40),

            FluxButton(
              'Back to Home',
              variant: FluxButtonVariant.secondary,
              onPressed: () => Navigator.pop(context),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14)),
        Text(value,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
