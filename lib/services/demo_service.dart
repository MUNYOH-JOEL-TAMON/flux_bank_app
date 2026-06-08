import 'package:uuid/uuid.dart';
import 'package:flux_bank/models/user_model.dart';
import 'package:flux_bank/models/transaction_model.dart';

class DemoService {
  DemoService._internal();
  static final DemoService instance = DemoService._internal();

  UserModel? _currentUser;
  final List<TransactionModel> _transactions = [];
  final _uuid = const Uuid();

  UserModel? get currentUser => _currentUser;
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  void initDemoUser({required String fullName, required String email, String? phone}) {
    _currentUser = UserModel(
      uid: 'demo_uid_${_uuid.v4()}',
      fullName: fullName,
      email: email,
      phone: phone,
      balance: 2450000.0,
      accountNumber: DateTime.now().millisecondsSinceEpoch.toString().substring(3),
      createdAt: DateTime.now(),
    );
    _seedTransactions();
  }

  void clearUser() {
    _currentUser = null;
    _transactions.clear();
  }

  void _seedTransactions() {
    _transactions.clear();
    final now = DateTime.now();

    void addTx({
      required TransactionType type,
      required double amount,
      required String description,
      required String counterparty,
      required TransactionCategory category,
      required Duration ago,
    }) {
      _transactions.add(TransactionModel(
        id: _uuid.v4(),
        type: type,
        amount: amount,
        description: description,
        category: category,
        timestamp: now.subtract(ago),
        counterparty: counterparty,
      ));
    }

    addTx(type: TransactionType.debit, amount: 15000, description: 'MTN Data Bundle', counterparty: 'MTN Mobile Money', category: TransactionCategory.mobileMoney, ago: const Duration(hours: 2));
    addTx(type: TransactionType.debit, amount: 35000, description: 'Supermarket Run', counterparty: 'Carrefour', category: TransactionCategory.shopping, ago: const Duration(hours: 22));
    addTx(type: TransactionType.credit, amount: 50000, description: 'MoMo Deposit', counterparty: 'MTN MoMo Agent', category: TransactionCategory.mobileMoney, ago: const Duration(days: 1));
    addTx(type: TransactionType.debit, amount: 8500, description: 'Lunch at KFC', counterparty: 'KFC', category: TransactionCategory.food, ago: const Duration(days: 2));
    addTx(type: TransactionType.credit, amount: 150000, description: 'Freelance Design', counterparty: 'TechCorp Inc', category: TransactionCategory.salary, ago: const Duration(days: 3));
    addTx(type: TransactionType.debit, amount: 45000, description: 'Electricity Bill', counterparty: 'ENEO', category: TransactionCategory.billPayment, ago: const Duration(days: 5));
    addTx(type: TransactionType.debit, amount: 12500, description: 'Weekend Groceries', counterparty: 'Santa Lucia', category: TransactionCategory.food, ago: const Duration(days: 6));
    addTx(type: TransactionType.debit, amount: 85000, description: 'Transfer to Alice', counterparty: 'Alice M.', category: TransactionCategory.transfer, ago: const Duration(days: 8));
    addTx(type: TransactionType.credit, amount: 200000, description: 'Online Store Sales', counterparty: 'Flutterwave', category: TransactionCategory.other, ago: const Duration(days: 10));
    addTx(type: TransactionType.debit, amount: 30000, description: 'Yango Rides', counterparty: 'Yango', category: TransactionCategory.transport, ago: const Duration(days: 12));
    addTx(type: TransactionType.debit, amount: 55000, description: 'Rent Advance', counterparty: 'Landlord', category: TransactionCategory.transfer, ago: const Duration(days: 15));
    addTx(type: TransactionType.credit, amount: 75000, description: 'Orange Money Transfer', counterparty: 'Orange Money Agent', category: TransactionCategory.mobileMoney, ago: const Duration(days: 16));
    addTx(type: TransactionType.debit, amount: 22000, description: 'Clothes', counterparty: 'Zara', category: TransactionCategory.shopping, ago: const Duration(days: 18));
    addTx(type: TransactionType.debit, amount: 120000, description: 'School Fees', counterparty: 'University', category: TransactionCategory.billPayment, ago: const Duration(days: 20));
    addTx(type: TransactionType.debit, amount: 18000, description: 'Fuel', counterparty: 'TotalEnergies', category: TransactionCategory.transport, ago: const Duration(days: 22));
    addTx(type: TransactionType.credit, amount: 25000, description: 'MoMo Transfer', counterparty: 'Bob K.', category: TransactionCategory.mobileMoney, ago: const Duration(days: 25));
    addTx(type: TransactionType.debit, amount: 42000, description: 'Pharmacy', counterparty: 'Pharmacie de Garde', category: TransactionCategory.other, ago: const Duration(days: 27));
    addTx(type: TransactionType.debit, amount: 95000, description: 'Monthly Rent', counterparty: 'Landlord', category: TransactionCategory.transfer, ago: const Duration(days: 29));
    addTx(type: TransactionType.credit, amount: 500000, description: 'Salary', counterparty: 'Employer Inc.', category: TransactionCategory.salary, ago: const Duration(days: 31));

    _transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<bool> transfer({required String toAccount, required String toName, required double amount, required String description}) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (_currentUser == null || _currentUser!.balance < amount) return false;

    _currentUser = _currentUser!.copyWith(balance: _currentUser!.balance - amount);
    _transactions.insert(0, TransactionModel(
      id: _uuid.v4(),
      type: TransactionType.debit,
      amount: amount,
      description: description.isEmpty ? 'Transfer' : description,
      category: TransactionCategory.transfer,
      timestamp: DateTime.now(),
      counterparty: toName,
    ));
    return true;
  }

  Future<bool> depositMobileMoney({required String phone, required double amount, required String provider, required bool isDeposit}) async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (_currentUser == null) return false;
    if (!isDeposit && _currentUser!.balance < amount) return false;

    _currentUser = _currentUser!.copyWith(
      balance: isDeposit ? _currentUser!.balance + amount : _currentUser!.balance - amount,
    );
    _transactions.insert(0, TransactionModel(
      id: _uuid.v4(),
      type: isDeposit ? TransactionType.credit : TransactionType.debit,
      amount: amount,
      description: isDeposit ? 'Deposit from $provider' : 'Withdrawal to $provider',
      category: TransactionCategory.mobileMoney,
      timestamp: DateTime.now(),
      counterparty: phone,
    ));
    return true;
  }
}
