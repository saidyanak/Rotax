import 'package:flutter/material.dart';
import '../core/services/driver_service.dart';
import '../models/cargo.dart';

class DriverProvider with ChangeNotifier {
  Map<String, dynamic>? _dashboard;
  List<Cargo> _offers = [];
  bool _isLoading = false;
  String? _error;
  String _currentStatus = 'OFFLINE';
  
  Map<String, dynamic>? get dashboard => _dashboard;
  List<Cargo> get offers => _offers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentStatus => _currentStatus;
  
  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _dashboard = await DriverService.getDashboard();
      _currentStatus = _dashboard?['driverStatus'] ?? 'OFFLINE';
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> loadOffers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _offers = await DriverService.getOffers();
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> updateStatus(String status, double lat, double lng) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await DriverService.updateStatus(status, lat, lng);
      _currentStatus = status;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> acceptOffer(int cargoId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await DriverService.acceptOffer(cargoId);
      await loadOffers();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> markPickedUp(int cargoId, String verificationCode) async {
    try {
      await DriverService.markPickedUp(cargoId, verificationCode);
      await loadDashboard();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> markDelivered(int cargoId, String verificationCode) async {
    try {
      await DriverService.markDelivered(cargoId, verificationCode);
      await loadDashboard();
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
