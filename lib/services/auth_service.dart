import 'package:firebase_auth/firebase_auth.dart';
import 'package:flux_bank/main.dart';
import 'package:flux_bank/models/user_model.dart';
import 'package:flux_bank/services/demo_service.dart';
import 'package:flux_bank/services/firestore_service.dart';

class AuthService {
  static final Map<String, Map<String, String>> _demoUsers = {};
  final _firestoreService = FirestoreService();

  Future<UserModel?> signIn(String email, String password) async {
    if (kFirebaseAvailable) {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        return await _firestoreService.getUser(credential.user!.uid);
      }
      return null;
    } else {
      await Future.delayed(const Duration(milliseconds: 800));
      final userMap = _demoUsers[email.toLowerCase()];
      if (userMap != null && userMap['password'] == password) {
        DemoService.instance.initDemoUser(
          fullName: userMap['fullName']!,
          email: email,
          phone: userMap['phone'],
        );
        return DemoService.instance.currentUser;
      }
      if (_demoUsers.isEmpty) {
        // Fallback for demo when no users are registered
        DemoService.instance.initDemoUser(
          fullName: 'Demo User',
          email: email,
          phone: '+1234567890',
        );
        return DemoService.instance.currentUser;
      }
      throw Exception('Invalid email or password');
    }
  }

  Future<UserModel?> register({required String fullName, required String email, required String phone, required String password}) async {
    if (kFirebaseAvailable) {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        await credential.user!.updateDisplayName(fullName);
        final user = UserModel(
          uid: credential.user!.uid,
          fullName: fullName,
          email: email,
          phone: phone,
          balance: 250000.0,
          accountNumber: _generateAccountNumber(),
          createdAt: DateTime.now(),
        );
        await _firestoreService.createUser(user);
        return user;
      }
      return null;
    } else {
      await Future.delayed(const Duration(milliseconds: 1000));
      _demoUsers[email.toLowerCase()] = {
        'fullName': fullName,
        'phone': phone,
        'password': password,
      };
      DemoService.instance.initDemoUser(
        fullName: fullName,
        email: email,
        phone: phone,
      );
      return DemoService.instance.currentUser;
    }
  }

  Future<void> signOut() async {
    if (kFirebaseAvailable) {
      await FirebaseAuth.instance.signOut();
    } else {
      DemoService.instance.clearUser();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (kFirebaseAvailable) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } else {
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  String _generateAccountNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return timestamp.substring(timestamp.length - 10);
  }
}
