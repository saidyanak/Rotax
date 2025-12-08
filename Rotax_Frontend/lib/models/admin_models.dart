// Admin Models

class AdminDashboard {
  final int totalUsers;
  final int totalDrivers;
  final int totalDistributors;
  final int activeDrivers;
  final int pendingVerifications;
  final int totalCargos;
  final int activeCargos;
  final int deliveredCargos;
  final int cancelledCargos;
  final double totalRevenue;
  final double totalTransactions;
  final double pendingWithdrawals;
  final Map<String, int>? cargosPerDay;
  final Map<String, int>? newUsersPerDay;
  final List<RecentActivity>? recentActivities;

  AdminDashboard({
    required this.totalUsers,
    required this.totalDrivers,
    required this.totalDistributors,
    required this.activeDrivers,
    required this.pendingVerifications,
    required this.totalCargos,
    required this.activeCargos,
    required this.deliveredCargos,
    required this.cancelledCargos,
    required this.totalRevenue,
    required this.totalTransactions,
    required this.pendingWithdrawals,
    this.cargosPerDay,
    this.newUsersPerDay,
    this.recentActivities,
  });

  factory AdminDashboard.fromJson(Map<String, dynamic> json) {
    return AdminDashboard(
      totalUsers: json['totalUsers'] ?? 0,
      totalDrivers: json['totalDrivers'] ?? 0,
      totalDistributors: json['totalDistributors'] ?? 0,
      activeDrivers: json['activeDrivers'] ?? 0,
      pendingVerifications: json['pendingVerifications'] ?? 0,
      totalCargos: json['totalCargos'] ?? 0,
      activeCargos: json['activeCargos'] ?? 0,
      deliveredCargos: json['deliveredCargos'] ?? 0,
      cancelledCargos: json['cancelledCargos'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalTransactions: (json['totalTransactions'] ?? 0).toDouble(),
      pendingWithdrawals: (json['pendingWithdrawals'] ?? 0).toDouble(),
      cargosPerDay: json['cargosPerDay'] != null 
          ? Map<String, int>.from(json['cargosPerDay'].map((k, v) => MapEntry(k, v as int)))
          : null,
      newUsersPerDay: json['newUsersPerDay'] != null 
          ? Map<String, int>.from(json['newUsersPerDay'].map((k, v) => MapEntry(k, v as int)))
          : null,
      recentActivities: json['recentActivities'] != null
          ? (json['recentActivities'] as List).map((e) => RecentActivity.fromJson(e)).toList()
          : null,
    );
  }
}

class RecentActivity {
  final String type;
  final String description;
  final String timestamp;
  final int? relatedId;

  RecentActivity({
    required this.type,
    required this.description,
    required this.timestamp,
    this.relatedId,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      timestamp: json['timestamp'] ?? '',
      relatedId: json['relatedId'],
    );
  }
}

class AdminUser {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String role;
  final bool enabled;
  final bool accountNonLocked;
  final String? createdAt;
  final String? updatedAt;
  final String? profilePictureUrl;
  final String? tc;
  final String? driverStatus;
  final String? carType;
  final String? vkn;
  final int totalDocuments;
  final int approvedDocuments;
  final int pendingDocuments;

  AdminUser({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.role,
    required this.enabled,
    required this.accountNonLocked,
    this.createdAt,
    this.updatedAt,
    this.profilePictureUrl,
    this.tc,
    this.driverStatus,
    this.carType,
    this.vkn,
    this.totalDocuments = 0,
    this.approvedDocuments = 0,
    this.pendingDocuments = 0,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? '',
      enabled: json['enabled'] ?? false,
      accountNonLocked: json['accountNonLocked'] ?? true,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      profilePictureUrl: json['profilePictureUrl'],
      tc: json['tc'],
      driverStatus: json['driverStatus'],
      carType: json['carType'],
      vkn: json['vkn'],
      totalDocuments: json['totalDocuments'] ?? 0,
      approvedDocuments: json['approvedDocuments'] ?? 0,
      pendingDocuments: json['pendingDocuments'] ?? 0,
    );
  }

  String get fullName => '$firstName $lastName';
}

class UserDocument {
  final int id;
  final int userId;
  final String? username;
  final String documentType;
  final String fileUrl;
  final String verificationStatus;
  final String? rejectionReason;
  final String? uploadedAt;

  UserDocument({
    required this.id,
    required this.userId,
    this.username,
    required this.documentType,
    required this.fileUrl,
    required this.verificationStatus,
    this.rejectionReason,
    this.uploadedAt,
  });

  factory UserDocument.fromJson(Map<String, dynamic> json) {
    return UserDocument(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      username: json['username'],
      documentType: json['documentType'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      verificationStatus: json['verificationStatus'] ?? 'PENDING',
      rejectionReason: json['rejectionReason'],
      uploadedAt: json['uploadedAt'],
    );
  }

  String get documentTypeTr {
    switch (documentType) {
      case 'DRIVERS_LICENSE':
        return 'Ehliyet';
      case 'VEHICLE_REGISTRATION':
        return 'Ruhsat';
      case 'IDENTITY_CARD':
        return 'Kimlik';
      case 'TAX_CERTIFICATE':
        return 'Vergi Levhası';
      default:
        return documentType;
    }
  }

  String get statusTr {
    switch (verificationStatus) {
      case 'PENDING':
        return 'Beklemede';
      case 'APPROVED':
        return 'Onaylı';
      case 'REJECTED':
        return 'Reddedildi';
      default:
        return verificationStatus;
    }
  }
}

class AdminCargo {
  final int id;
  final String trackingCode;
  final String status;
  final String? distributorName;
  final String? driverName;
  final String pickupCity;
  final String deliveryCity;
  final double price;
  final String? createdAt;

  AdminCargo({
    required this.id,
    required this.trackingCode,
    required this.status,
    this.distributorName,
    this.driverName,
    required this.pickupCity,
    required this.deliveryCity,
    required this.price,
    this.createdAt,
  });

  factory AdminCargo.fromJson(Map<String, dynamic> json) {
    return AdminCargo(
      id: json['id'] ?? 0,
      trackingCode: json['trackingCode'] ?? '',
      status: json['status'] ?? '',
      distributorName: json['distributorName'],
      driverName: json['driverName'],
      pickupCity: json['pickupCity'] ?? '',
      deliveryCity: json['deliveryCity'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      createdAt: json['createdAt'],
    );
  }

  String get statusTr {
    switch (status) {
      case 'PENDING':
        return 'Beklemede';
      case 'ACCEPTED':
        return 'Kabul Edildi';
      case 'PICKED_UP':
        return 'Alındı';
      case 'IN_TRANSIT':
        return 'Yolda';
      case 'DELIVERED':
        return 'Teslim Edildi';
      case 'CANCELLED':
        return 'İptal';
      default:
        return status;
    }
  }
}

class PendingWithdrawal {
  final int id;
  final int userId;
  final String? username;
  final double amount;
  final String status;
  final String? createdAt;
  final String? iban;

  PendingWithdrawal({
    required this.id,
    required this.userId,
    this.username,
    required this.amount,
    required this.status,
    this.createdAt,
    this.iban,
  });

  factory PendingWithdrawal.fromJson(Map<String, dynamic> json) {
    return PendingWithdrawal(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      username: json['username'],
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      createdAt: json['createdAt'],
      iban: json['iban'],
    );
  }
}
