import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { credit, debit }

enum TransactionCategory { transfer, mobileMoney, billPayment, salary, shopping, food, transport, other }

extension TransactionCategoryExtension on TransactionCategory {
  String get label {
    switch (this) {
      case TransactionCategory.transfer: return 'Transfer';
      case TransactionCategory.mobileMoney: return 'Mobile Money';
      case TransactionCategory.billPayment: return 'Bill Payment';
      case TransactionCategory.salary: return 'Salary';
      case TransactionCategory.shopping: return 'Shopping';
      case TransactionCategory.food: return 'Food & Dining';
      case TransactionCategory.transport: return 'Transport';
      case TransactionCategory.other: return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case TransactionCategory.transfer: return '💸';
      case TransactionCategory.mobileMoney: return '📱';
      case TransactionCategory.billPayment: return '🧾';
      case TransactionCategory.salary: return '💼';
      case TransactionCategory.shopping: return '🛍️';
      case TransactionCategory.food: return '🍽️';
      case TransactionCategory.transport: return '🚗';
      case TransactionCategory.other: return '💰';
    }
  }
}

class TransactionModel {
  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final TransactionCategory category;
  final DateTime timestamp;
  final String counterparty;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.category,
    required this.timestamp,
    required this.counterparty,
  });

  bool get isCredit => type == TransactionType.credit;

  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
      id: id,
      type: map['type'] == 'credit' ? TransactionType.credit : TransactionType.debit,
      amount: (map['amount'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TransactionCategory.other,
      ),
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      counterparty: map['counterparty'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'amount': amount,
      'description': description,
      'category': category.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'counterparty': counterparty,
    };
  }
}
