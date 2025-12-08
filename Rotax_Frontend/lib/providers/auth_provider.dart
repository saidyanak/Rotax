import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/storage_service.dart';
import '../models/user.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _error;
  
  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  
  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();
    
    try {
      await StorageService.init();
      final isAuth = await AuthService.checkAuthStatus();
      
      if (isAuth) {
        _user = AuthService.currentUser;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = e.toString();
    }
    
    notifyListeners();
  }
  
  Future<bool> login(String username, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    
    try {
      final success = await AuthService.login(username, password);
      if (success) {
        _user = AuthService.currentUser;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _status = AuthStatus.unauthenticated;
      _error = 'Giriş başarısız';
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String role,
    String? tc,
    String? vkn,
    String? carType,
    List<WebFile>? documents,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    
    try {
      await AuthService.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        role: role,
        tc: tc,
        vkn: vkn,
        carType: carType,
        documents: documents,
      );
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();
    
    try {
      await AuthService.logout();
    } finally {
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
