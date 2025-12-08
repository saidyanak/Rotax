import '../constants/api_constants.dart';
import 'api_service.dart';
import '../../models/cargo.dart';

class DriverService {
  static Future<Map<String, dynamic>> getDashboard() async {
    return await ApiService.get(ApiConstants.driverDashboard);
  }
  
  static Future<void> updateStatus(String status, double latitude, double longitude) async {
    await ApiService.put(ApiConstants.driverStatus, body: {
      'driverStatus': status,
      'latitude': latitude,
      'longitude': longitude,
    });
  }
  
  static Future<void> updateProfile(Map<String, dynamic> profileData) async {
    await ApiService.put(ApiConstants.driverProfile, body: profileData);
  }
  
  static Future<List<Cargo>> getOffers() async {
    final response = await ApiService.get(ApiConstants.driverOffers);
    if (response is List) {
      return response.map((json) => Cargo.fromJson(json)).toList();
    }
    return [];
  }
  
  static Future<void> acceptOffer(int cargoId) async {
    await ApiService.post(ApiConstants.driverAcceptOffer(cargoId));
  }
  
  static Future<void> markPickedUp(int cargoId, String verificationCode) async {
    await ApiService.put(ApiConstants.driverPickedUp(cargoId), body: {
      'verificationCode': verificationCode,
    });
  }
  
  static Future<void> markDelivered(int cargoId, String verificationCode) async {
    await ApiService.put(ApiConstants.driverDelivered(cargoId), body: {
      'verificationCode': verificationCode,
    });
  }
}
