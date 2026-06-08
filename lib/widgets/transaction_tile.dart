import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flux_bank/models/transaction_model.dart';
import 'package:flux_bank/theme/app_theme.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final bool showDate;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCredit = transaction.isCredit;
    final Color amountColor =
        isCredit ? AppColors.credit : AppColors.debit;
    final String amountSign = isCredit ? '+' : '-';
    final String formattedAmount =
        NumberFormat('#,##0', 'en_US').format(transaction.amount);
    final String formattedDate =
        DateFormat('MMM d, h:mm a').format(transaction.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          // Category icon in dark rounded square
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              transaction.category.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          // Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (transaction.counterparty.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    transaction.counterparty,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountSign$formattedAmount',
                style: TextStyle(
                  color: amountColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (showDate) ...[
                const SizedBox(height: 2),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
