import 'package:flutter/material.dart';
import '../core/services/wallet_service.dart';
import '../models/wallet.dart';
import '../models/transaction.dart';

class WalletProvider with ChangeNotifier {
  Wallet? _wallet;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;
  
  Wallet? get wallet => _wallet;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  
  Future<void> loadWallet() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _wallet = await WalletService.getWallet();
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> loadTransactions({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _transactions = [];
      _hasMore = true;
    }
    
    if (!_hasMore) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await WalletService.getTransactions(page: _currentPage);
      final List<dynamic> content = response['content'] ?? [];
      final newTransactions = content.map((json) => Transaction.fromJson(json)).toList();
      
      _transactions.addAll(newTransactions);
      _currentPage++;
      _hasMore = newTransactions.length >= 20;
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> deposit(double amount, String paymentMethod) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await WalletService.deposit(amount, paymentMethod);
      await loadWallet();
      await loadTransactions(refresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> withdraw(double amount, String bankAccount) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await WalletService.withdraw(amount, bankAccount);
      await loadWallet();
      await loadTransactions(refresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
