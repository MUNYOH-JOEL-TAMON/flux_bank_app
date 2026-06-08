import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flux_bank/models/transaction_model.dart';
import 'package:flux_bank/providers/banking_provider.dart';
import 'package:flux_bank/theme/app_theme.dart';
import 'package:flux_bank/widgets/transaction_tile.dart';
import 'package:flux_bank/widgets/shimmer_list.dart';
import 'package:flux_bank/widgets/flux_text_field.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _selectedFilter = 0; // 0=All, 1=Credits, 2=Debits
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionModel> _getFilteredTransactions(
      List<TransactionModel> all) {
    return all.where((t) {
      if (_selectedFilter == 1 && !t.isCredit) return false;
      if (_selectedFilter == 2 && t.isCredit) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return t.description.toLowerCase().contains(query) ||
            t.counterparty.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  Map<String, List<TransactionModel>> _groupTransactionsByDate(
      List<TransactionModel> txs) {
    final Map<String, List<TransactionModel>> grouped = {};
    final now = DateTime.now();

    for (var tx in txs) {
      final daysAgo = now.difference(tx.timestamp).inDays;
      String group;
      if (daysAgo == 0) {
        group = 'Today';
      } else if (daysAgo == 1) {
        group = 'Yesterday';
      } else if (daysAgo < 7) {
        group = 'This Week';
      } else {
        group = DateFormat('MMMM yyyy').format(tx.timestamp);
      }

      if (!grouped.containsKey(group)) {
        grouped[group] = [];
      }
      grouped[group]!.add(tx);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final banking = context.watch<BankingProvider>();
    final filtered = _getFilteredTransactions(banking.transactions);
    final grouped = _groupTransactionsByDate(filtered);

    return Scaffold(
      backgroundColor: AppColors.shell,
      appBar: AppBar(
        title: const Text('Transactions'),
        elevation: 0,
        backgroundColor: AppColors.shell,
      ),
      body: Column(
        children: [
          // Search & Filters
          Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              children: [
                FluxTextField(
                  hint: 'Search transactions...',
                  controller: _searchController,
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.textSecondary),
                  onChanged: (val) =>
                      setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildFilterChip('All', 0),
                    const SizedBox(width: 8),
                    _buildFilterChip('Money In', 1,
                        selectedColor: AppColors.credit),
                    const SizedBox(width: 8),
                    _buildFilterChip('Money Out', 2,
                        selectedColor: AppColors.debit),
                  ],
                ),
              ],
            ),
          ),

          // Transaction list
          Expanded(
            child: banking.isLoading && banking.transactions.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: ShimmerList(itemCount: 10),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      if (banking.user != null) {
                        await banking
                            .loadTransactions(banking.user!.uid);
                      }
                    },
                    color: AppColors.textPrimary,
                    backgroundColor: AppColors.elevated,
                    child: filtered.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 100),
                              Center(
                                child: Text(
                                  'No transactions found',
                                  style: TextStyle(
                                      color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: grouped.length,
                            itemBuilder: (context, index) {
                              final groupName =
                                  grouped.keys.elementAt(index);
                              final txs = grouped[groupName]!;
                              return Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        bottom: 12.0,
                                        top: index == 0 ? 0 : 16.0),
                                    child: Text(
                                      groupName,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  ...txs.map((t) => TransactionTile(
                                        transaction: t,
                                        showDate: groupName ==
                                                    'This Week' ||
                                                groupName == 'Today' ||
                                                groupName == 'Yesterday'
                                            ? false
                                            : true,
                                      )),
                                ],
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index,
      {Color selectedColor = AppColors.textPrimary}) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? selectedColor : AppColors.divider,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? selectedColor : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
