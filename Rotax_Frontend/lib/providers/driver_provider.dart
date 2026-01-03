import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/services/driver_service.dart';
import '../models/cargo.dart';

class DriverProvider with ChangeNotifier {
  Map<String, dynamic>? _dashboard;
  List<Cargo> _offers = [];
  bool _isLoading = false;
  String? _error;
  String _currentStatus = 'OFFLINE';
  
  // Hedef lokasyon (DESTINATION_BASED modu için)
  double? _destinationLat;
  double? _destinationLng;
  String? _destinationCity;
  double _maxDeviationKm = 5.0;
  
  Map<String, dynamic>? get dashboard => _dashboard;
  List<Cargo> get offers => _offers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentStatus => _currentStatus;
  double? get destinationLat => _destinationLat;
  double? get destinationLng => _destinationLng;
  String? get destinationCity => _destinationCity;
  double get maxDeviationKm => _maxDeviationKm;
  
  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _dashboard = await DriverService.getDashboard();
      _currentStatus = _dashboard?['driverStatus'] ?? 'OFFLINE';
      
      // Hedef lokasyonu yükle
      final destination = _dashboard?['destination'];
      if (destination != null) {
        _destinationLat = destination['latitude'];
        _destinationLng = destination['longitude'];
        _destinationCity = destination['city'];
      }
      
      _maxDeviationKm = _dashboard?['maxDeviationKm'] ?? 5.0;
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
  
  Future<bool> updateStatus(
    String status, 
    double lat, 
    double lng, {
    double? destLat,
    double? destLng,
    String? destCity,
    double? maxDeviation,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      Map<String, dynamic>? destination;
      if (status == 'DESTINATION_BASED' && destLat != null && destLng != null) {
        destination = {
          'latitude': destLat,
          'longitude': destLng,
          'city': destCity,
        };
        _destinationLat = destLat;
        _destinationLng = destLng;
        _destinationCity = destCity;
        _maxDeviationKm = maxDeviation ?? 5.0;
      }
      
      await DriverService.updateStatus(
        status, 
        lat, 
        lng,
        destination: destination,
        maxDeviationKm: maxDeviation,
      );
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
  
  // Hedef lokasyonu temizle
  void clearDestination() {
    _destinationLat = null;
    _destinationLng = null;
    _destinationCity = null;
    notifyListeners();
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
  
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String carType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await DriverService.updateProfile({
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'carType': carType,
      });
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

  Future<bool> updateProfilePicture(WebFile file) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await DriverService.updateProfilePicture(file);
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
