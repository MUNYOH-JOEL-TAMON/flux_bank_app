import 'package:flutter/foundation.dart';
import 'package:flux_bank/main.dart';
import 'package:flux_bank/models/user_model.dart';
import 'package:flux_bank/models/transaction_model.dart';
import 'package:flux_bank/services/demo_service.dart';
import 'package:flux_bank/services/firestore_service.dart';

class BankingProvider extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();
  
  UserModel? _user;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  bool _isTransferLoading = false;
  String? _error;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isTransferLoading => _isTransferLoading;
  String? get error => _error;
  double get balance => _user?.balance ?? 0.0;
  UserModel? get user => _user;

  double get totalCredits {
    return _transactions.where((t) => t.isCredit).fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalDebits {
    return _transactions.where((t) => !t.isCredit).fold(0.0, (sum, t) => sum + t.amount);
  }

  List<TransactionModel> get recentTransactions {
    return _transactions.take(5).toList();
  }

  List<double> get weeklyBalanceData {
    if (_transactions.isEmpty) {
      return [2000000, 2100000, 2050000, 2200000, 2150000, 2300000, balance];
    }
    
    // Simulate historical balances by working backwards from current balance
    List<double> data = List.filled(7, 0.0);
    double currentBal = balance;
    data[6] = currentBal;
    
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      // Find transactions for the day between i and i+1
      final dayTransactions = _transactions.where((t) {
        final daysAgo = now.difference(t.timestamp).inDays;
        return daysAgo == (6 - i);
      });
      
      // Reverse apply transactions
      for (var t in dayTransactions) {
        if (t.isCredit) {
          currentBal -= t.amount;
        } else {
          currentBal += t.amount;
        }
      }
      data[i] = currentBal;
    }
    return data;
  }

  void updateUser(UserModel? user) {
    _user = user;
    if (_user != null) {
      loadTransactions(_user!.uid);
    } else {
      _transactions = [];
      notifyListeners();
    }
  }

  Future<void> loadTransactions(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (kFirebaseAvailable) {
        _transactions = await _fs.getTransactions(uid);
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        _transactions = List.from(DemoService.instance.transactions);
      }
    } catch (e) {
      _error = 'Failed to load transactions';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> transfer({required String toAccount, required String toName, required double amount, required String description}) async {
    _isTransferLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (balance < amount) {
        throw Exception('Insufficient funds');
      }

      if (kFirebaseAvailable && _user != null) {
        final newBalance = balance - amount;
        await _fs.updateBalance(_user!.uid, newBalance);
        
        final tx = TransactionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: TransactionType.debit,
          amount: amount,
          description: description.isEmpty ? 'Transfer' : description,
          category: TransactionCategory.transfer,
          timestamp: DateTime.now(),
          counterparty: toName,
        );
        await _fs.addTransaction(_user!.uid, tx);
        
        _user = _user!.copyWith(balance: newBalance);
        _transactions.insert(0, tx);
      } else {
        final success = await DemoService.instance.transfer(toAccount: toAccount, toName: toName, amount: amount, description: description);
        if (!success) throw Exception('Transfer failed');
        _user = DemoService.instance.currentUser;
        _transactions = List.from(DemoService.instance.transactions);
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isTransferLoading = false;
      notifyListeners();
    }
  }

  Future<bool> depositMobileMoney({required String phone, required double amount, required String provider, required bool isDeposit}) async {
    _isTransferLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!isDeposit && balance < amount) {
        throw Exception('Insufficient funds for withdrawal');
      }

      if (kFirebaseAvailable && _user != null) {
        final newBalance = isDeposit ? balance + amount : balance - amount;
        await _fs.updateBalance(_user!.uid, newBalance);
        
        final tx = TransactionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: isDeposit ? TransactionType.credit : TransactionType.debit,
          amount: amount,
          description: isDeposit ? 'Deposit from $provider' : 'Withdrawal to $provider',
          category: TransactionCategory.mobileMoney,
          timestamp: DateTime.now(),
          counterparty: phone,
        );
        await _fs.addTransaction(_user!.uid, tx);
        
        _user = _user!.copyWith(balance: newBalance);
        _transactions.insert(0, tx);
      } else {
        final success = await DemoService.instance.depositMobileMoney(phone: phone, amount: amount, provider: provider, isDeposit: isDeposit);
        if (!success) throw Exception('Transaction failed');
        _user = DemoService.instance.currentUser;
        _transactions = List.from(DemoService.instance.transactions);
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isTransferLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
