import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _userModel?.isAdmin ?? false;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _userModel = null;
        _isInitializing = false;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData(String uid) async {
    _userModel = await _authService.getUserData(uid);
    _isInitializing = false;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    bool isAdmin = false,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signUp(
        email: email,
        password: password,
        name: name,
        isAdmin: isAdmin,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Clean up error message
      String errorMsg = e.toString();

      // Remove common prefixes
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }

      // Check for Firebase configuration issues
      if (errorMsg.contains('YOUR_') ||
          errorMsg.contains('DefaultFirebaseOptions') ||
          errorMsg.contains('not initialized')) {
        errorMsg = 'Firebase not configured. Please run: flutterfire configure';
      }

      _errorMessage = errorMsg;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signIn(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Clean up error message
      String errorMsg = e.toString();

      // Remove common prefixes
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }

      // Check for Firebase configuration issues
      if (errorMsg.contains('YOUR_') ||
          errorMsg.contains('DefaultFirebaseOptions') ||
          errorMsg.contains('not initialized')) {
        errorMsg = 'Firebase not configured. Please run: flutterfire configure';
      }

      _errorMessage = errorMsg;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _userModel = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    String? profilePicUrl,
  }) async {
    try {
      if (_user == null) return false;

      _isLoading = true;
      notifyListeners();

      await _authService.updateUserProfile(
        uid: _user!.uid,
        name: name,
        profilePicUrl: profilePicUrl,
      );

      await _loadUserData(_user!.uid);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.resetPassword(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

