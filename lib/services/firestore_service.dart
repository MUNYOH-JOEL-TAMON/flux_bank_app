import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flux_bank/models/user_model.dart';
import 'package:flux_bank/models/transaction_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _users => _db.collection('users');

  Future<void> createUser(UserModel user) async {
    await _users.doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<void> updateBalance(String uid, double newBalance) async {
    await _users.doc(uid).update({'balance': newBalance});
  }

  Future<void> addTransaction(String uid, TransactionModel transaction) async {
    await _users.doc(uid).collection('transactions').doc(transaction.id).set(transaction.toMap());
  }

  Future<List<TransactionModel>> getTransactions(String uid) async {
    final snapshot = await _users.doc(uid).collection('transactions').orderBy('timestamp', descending: true).limit(50).get();
    return snapshot.docs.map((doc) => TransactionModel.fromMap(doc.data(), doc.id)).toList();
  }
}
