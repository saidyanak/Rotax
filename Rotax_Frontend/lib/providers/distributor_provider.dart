import 'package:flutter/material.dart';
import '../core/services/distributor_service.dart';
import '../models/cargo.dart';

class DistributorProvider with ChangeNotifier {
  Map<String, dynamic>? _dashboard;
  List<Cargo> _cargos = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;
  
  Map<String, dynamic>? get dashboard => _dashboard;
  List<Cargo> get cargos => _cargos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  
  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _dashboard = await DistributorService.getDashboard();
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> loadCargos({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _cargos = [];
      _hasMore = true;
    }
    
    if (!_hasMore) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await DistributorService.getCargos(page: _currentPage);
      final List<dynamic> content = response['content'] ?? [];
      final newCargos = content.map((json) => Cargo.fromJson(json)).toList();
      
      _cargos.addAll(newCargos);
      _currentPage++;
      _hasMore = newCargos.length >= 20;
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> createCargo({
    required String description,
    required String phoneNumber,
    required Map<String, dynamic> selfLocation,
    required Map<String, dynamic> targetLocation,
    required Map<String, dynamic> measure,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await DistributorService.createCargo(
        description: description,
        phoneNumber: phoneNumber,
        selfLocation: selfLocation,
        targetLocation: targetLocation,
        measure: measure,
      );
      await loadCargos(refresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> cancelCargo(int cargoId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await DistributorService.cancelCargo(cargoId);
      await loadCargos(refresh: true);
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
