import '../constants/api_constants.dart';
import 'api_service.dart';
import '../../models/cargo.dart';

class DistributorService {
  static Future<Map<String, dynamic>> getDashboard() async {
    return await ApiService.get(ApiConstants.distributorDashboard);
  }
  
  static Future<void> updateProfile(Map<String, dynamic> profileData) async {
    await ApiService.put(ApiConstants.distributorProfile, body: profileData);
  }
  
  static Future<Map<String, dynamic>> getCargos({int page = 0, int size = 20}) async {
    return await ApiService.get(ApiConstants.distributorCargos, queryParams: {
      'page': page,
      'size': size,
    });
  }
  
  static Future<Cargo> getCargoDetail(int cargoId) async {
    final response = await ApiService.get(ApiConstants.distributorCargoDetail(cargoId));
    return Cargo.fromJson(response);
  }
  
  static Future<Cargo> createCargo({
    required String description,
    required String phoneNumber,
    required Map<String, dynamic> selfLocation,
    required Map<String, dynamic> targetLocation,
    required Map<String, dynamic> measure,
  }) async {
    final response = await ApiService.post(ApiConstants.distributorCargos, body: {
      'description': description,
      'phoneNumber': phoneNumber,
      'selfLocation': selfLocation,
      'targetLocation': targetLocation,
      'measure': measure,
    });
    return Cargo.fromJson(response);
  }
  
  static Future<void> cancelCargo(int cargoId) async {
    await ApiService.put(ApiConstants.distributorCancelCargo(cargoId));
  }
}
