import 'package:flutter/foundation.dart';
import 'package:flux_bank/models/user_model.dart';
import 'package:flux_bank/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _authService.signIn(email, password);
      return _user != null;
    } catch (e) {
      _error = _mapError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({required String fullName, required String email, required String phone, required String password}) async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _authService.register(fullName: fullName, email: email, phone: phone, password: password);
      return _user != null;
    } catch (e) {
      debugPrint('FLUX REGISTER ERROR: $e');
      _error = _mapError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _user = null;
    } catch (e) {
      _error = _mapError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _error = null;
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _error = _mapError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _mapError(String e) {
    if (e.contains('user-not-found')) return 'No user found for that email.';
    if (e.contains('wrong-password')) return 'Wrong password provided.';
    if (e.contains('invalid-credential')) return 'Invalid email or password.';
    if (e.contains('email-already-in-use')) return 'An account already exists for that email.';
    if (e.contains('weak-password')) return 'Password must be at least 6 characters.';
    if (e.contains('invalid-email')) return 'The email address is not valid.';
    if (e.contains('network-request-failed')) return 'Network connection failed. Check your internet.';
    if (e.contains('too-many-requests')) return 'Too many attempts. Please try again later.';
    if (e.contains('operation-not-allowed')) return 'Email/password sign-in is not enabled. Contact support.';
    if (e.contains('CONFIGURATION_NOT_FOUND') || e.contains('configuration-not-found')) return 'Firebase is not configured correctly.';
    debugPrint('FLUX UNMAPPED ERROR: $e');
    return 'Something went wrong. Please try again.';
  }
}
