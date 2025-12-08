import 'dart:convert';
import '../constants/api_constants.dart';
import 'api_service.dart';
import 'storage_service.dart';
import '../../models/user.dart';

class AuthService {
  static User? _currentUser;
  
  static User? get currentUser => _currentUser;
  
  static Future<bool> login(String username, String password) async {
    try {
      // Önce mevcut token'ı temizle (farklı kullanıcı ile giriş için)
      await StorageService.clearAll();
      ApiService.setToken(null);
      
      final response = await ApiService.post(ApiConstants.login, body: {
        'usernameOrEmail': username,
        'password': password,
      });
      
      final token = response['token'];
      if (token != null) {
        await StorageService.saveToken(token);
        ApiService.setToken(token);
        
        // Get user info
        await getCurrentUser();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Register with documents (multipart/form-data) - Web uyumlu
  static Future<bool> register({
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
    try {
      final requestData = {
        'username': username,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'roles': role, // Backend 'roles' bekliyor
      };
      
      if (role == 'DRIVER') {
        if (tc != null) requestData['tc'] = tc;
        if (carType != null) requestData['carType'] = carType;
      } else if (role == 'DISTRIBUTOR') {
        if (vkn != null) requestData['vkn'] = vkn;
      }
      
      final response = await ApiService.multipartPost(
        ApiConstants.register,
        fields: {},
        jsonField: 'request',
        jsonData: requestData,
        files: documents,
        filesField: 'documents',
      );
      
      // Kayıt sonrası token kaydetmiyoruz
      // Kullanıcı belgelerinin onaylanması gerekiyor, 
      // bu yüzden login ekranına yönlendirilecek
      // Mevcut token varsa temizle (admin giriş sorunu için)
      await StorageService.clearAll();
      ApiService.setToken(null);
      
      return true;
    } catch (e) {
      rethrow;
    }
  }
  
  static Future<User?> getCurrentUser() async {
    try {
      final response = await ApiService.get(ApiConstants.me);
      _currentUser = User.fromJson(response);
      
      // Save user data locally
      await StorageService.saveUserData(jsonEncode(response));
      await StorageService.saveUserRole(_currentUser!.role);
      
      return _currentUser;
    } catch (e) {
      return null;
    }
  }
  
  static Future<void> logout() async {
    // Önce lokaldeki verileri temizle (API başarısız olsa bile)
    _currentUser = null;
    ApiService.setToken(null);
    await StorageService.clearAll();
    
    // Sonra backend'e logout isteği gönder (opsiyonel, başarısız olabilir)
    try {
      await ApiService.post(ApiConstants.logout);
    } catch (e) {
      // Backend logout başarısız olsa bile lokal temizlik yapıldı
      print('Logout API error (ignored): $e');
    }
  }
  
  static Future<bool> checkAuthStatus() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;
      
      ApiService.setToken(token);
      
      // Verify token by getting current user
      final user = await getCurrentUser();
      return user != null;
    } catch (e) {
      await StorageService.clearAll();
      return false;
    }
  }
  
  static Future<void> forgotPassword(String email) async {
    await ApiService.post(ApiConstants.forgotPassword, body: {'email': email});
  }
  
  static Future<void> resetPassword(String token, String newPassword) async {
    await ApiService.post(ApiConstants.resetPassword, body: {
      'token': token,
      'newPassword': newPassword,
    });
  }
  
  static Future<void> changePassword(String currentPassword, String newPassword) async {
    await ApiService.post(ApiConstants.changePassword, body: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}
