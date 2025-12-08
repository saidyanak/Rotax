import 'package:flutter/material.dart';
import '../core/services/admin_service.dart';
import '../models/admin_models.dart';

class AdminProvider with ChangeNotifier {
  AdminDashboard? _dashboard;
  List<AdminUser> _users = [];
  List<UserDocument> _pendingDocuments = [];
  List<AdminCargo> _cargos = [];
  List<PendingWithdrawal> _pendingWithdrawals = [];
  
  bool _isLoading = false;
  String? _error;
  
  // Pagination
  int _usersTotalPages = 0;
  int _usersCurrentPage = 0;
  int _cargosTotalPages = 0;
  int _cargosCurrentPage = 0;

  // Getters
  AdminDashboard? get dashboard => _dashboard;
  List<AdminUser> get users => _users;
  List<UserDocument> get pendingDocuments => _pendingDocuments;
  List<AdminCargo> get cargos => _cargos;
  List<PendingWithdrawal> get pendingWithdrawals => _pendingWithdrawals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get usersTotalPages => _usersTotalPages;
  int get usersCurrentPage => _usersCurrentPage;
  int get cargosTotalPages => _cargosTotalPages;
  int get cargosCurrentPage => _cargosCurrentPage;

  // Dashboard
  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboard = await AdminService.getDashboard();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Users
  Future<void> loadUsers({int page = 0, String? role}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AdminService.getUsers(page: page, role: role);
      _users = result['content'] as List<AdminUser>;
      _usersTotalPages = result['totalPages'] as int;
      _usersCurrentPage = result['currentPage'] as int;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> toggleUserStatus(int userId) async {
    try {
      final updatedUser = await AdminService.toggleUserStatus(userId);
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleUserLock(int userId) async {
    try {
      final updatedUser = await AdminService.toggleUserLock(userId);
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Documents
  Future<void> loadPendingDocuments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingDocuments = await AdminService.getPendingDocuments();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> approveDocument(int documentId) async {
    try {
      await AdminService.approveDocument(documentId);
      _pendingDocuments.removeWhere((d) => d.id == documentId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectDocument(int documentId, String reason) async {
    try {
      await AdminService.rejectDocument(documentId, reason);
      _pendingDocuments.removeWhere((d) => d.id == documentId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Cargos
  Future<void> loadCargos({int page = 0, String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AdminService.getCargos(page: page, status: status);
      _cargos = result['content'] as List<AdminCargo>;
      _cargosTotalPages = result['totalPages'] as int;
      _cargosCurrentPage = result['currentPage'] as int;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> cancelCargo(int cargoId, String reason) async {
    try {
      await AdminService.cancelCargo(cargoId, reason);
      await loadCargos(page: _cargosCurrentPage);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Withdrawals
  Future<void> loadPendingWithdrawals({int page = 0}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await AdminService.getPendingWithdrawals(page: page);
      _pendingWithdrawals = result['content'] as List<PendingWithdrawal>;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> approveWithdrawal(int transactionId) async {
    try {
      await AdminService.approveWithdrawal(transactionId);
      _pendingWithdrawals.removeWhere((w) => w.id == transactionId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectWithdrawal(int transactionId, String reason) async {
    try {
      await AdminService.rejectWithdrawal(transactionId, reason);
      _pendingWithdrawals.removeWhere((w) => w.id == transactionId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
