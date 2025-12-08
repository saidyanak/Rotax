import '../constants/api_constants.dart';
import 'api_service.dart';
import '../../models/admin_models.dart';

class AdminService {
  // Dashboard
  static Future<AdminDashboard> getDashboard() async {
    final response = await ApiService.get(ApiConstants.adminDashboard);
    return AdminDashboard.fromJson(response);
  }

  // Users
  static Future<Map<String, dynamic>> getUsers({
    int page = 0,
    int size = 20,
    String? role,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'size': size.toString(),
    };
    if (role != null) queryParams['role'] = role;
    
    final response = await ApiService.get(ApiConstants.adminUsers, queryParams: queryParams);
    return {
      'content': (response['content'] as List).map((e) => AdminUser.fromJson(e)).toList(),
      'totalElements': response['totalElements'] ?? 0,
      'totalPages': response['totalPages'] ?? 0,
      'currentPage': response['currentPage'] ?? 0,
    };
  }

  static Future<AdminUser> getUserById(int userId) async {
    final response = await ApiService.get(ApiConstants.adminUserDetail(userId));
    return AdminUser.fromJson(response);
  }

  static Future<AdminUser> toggleUserStatus(int userId) async {
    final response = await ApiService.put(ApiConstants.adminUserToggleStatus(userId));
    return AdminUser.fromJson(response);
  }

  static Future<AdminUser> toggleUserLock(int userId) async {
    final response = await ApiService.put(ApiConstants.adminUserToggleLock(userId));
    return AdminUser.fromJson(response);
  }

  // Documents
  static Future<List<UserDocument>> getPendingDocuments() async {
    final response = await ApiService.get(ApiConstants.adminPendingDocuments);
    return (response as List).map((e) => UserDocument.fromJson(e)).toList();
  }

  static Future<UserDocument> approveDocument(int documentId) async {
    final response = await ApiService.post(ApiConstants.adminApproveDocument(documentId));
    return UserDocument.fromJson(response);
  }

  static Future<UserDocument> rejectDocument(int documentId, String reason) async {
    final response = await ApiService.post(
      ApiConstants.adminRejectDocument(documentId),
      body: {'rejectionReason': reason},
    );
    return UserDocument.fromJson(response);
  }

  // Cargos
  static Future<Map<String, dynamic>> getCargos({
    int page = 0,
    int size = 20,
    String? status,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'size': size.toString(),
    };
    if (status != null) queryParams['status'] = status;
    
    final response = await ApiService.get(ApiConstants.adminCargos, queryParams: queryParams);
    return {
      'content': (response['content'] as List).map((e) => AdminCargo.fromJson(e)).toList(),
      'totalElements': response['totalElements'] ?? 0,
      'totalPages': response['totalPages'] ?? 0,
      'currentPage': response['currentPage'] ?? 0,
    };
  }

  static Future<void> cancelCargo(int cargoId, String reason) async {
    await ApiService.put(
      '${ApiConstants.adminCancelCargo(cargoId)}?reason=$reason',
    );
  }

  // Withdrawals
  static Future<Map<String, dynamic>> getPendingWithdrawals({
    int page = 0,
    int size = 20,
  }) async {
    final response = await ApiService.get(
      ApiConstants.adminPendingWithdrawals,
      queryParams: {'page': page.toString(), 'size': size.toString()},
    );
    return {
      'content': (response['content'] as List).map((e) => PendingWithdrawal.fromJson(e)).toList(),
      'totalElements': response['totalElements'] ?? 0,
      'totalPages': response['totalPages'] ?? 0,
      'currentPage': response['currentPage'] ?? 0,
    };
  }

  static Future<void> approveWithdrawal(int transactionId) async {
    await ApiService.post(ApiConstants.adminApproveWithdrawal(transactionId));
  }

  static Future<void> rejectWithdrawal(int transactionId, String reason) async {
    await ApiService.post(
      '${ApiConstants.adminRejectWithdrawal(transactionId)}?reason=$reason',
    );
  }
}
