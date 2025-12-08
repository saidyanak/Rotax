import 'location.dart';
import 'measure.dart';

enum CargoSituation {
  CREATED,
  ASSIGNED,
  PICKED_UP,
  DELIVERED,
  CANCELLED,
  EXPIRED,
  FAILED,
}

class Cargo {
  final int id;
  final String? description;
  final String? phoneNumber;
  final String? verificationCode;
  final CargoSituation status;
  final Location? selfLocation;
  final Location? targetLocation;
  final Measure? measure;
  final int? distributorId;
  final String? distributorName;
  final int? driverId;
  final String? driverName;
  final DateTime? createdAt;
  final DateTime? takingTime;
  final DateTime? deliveredTime;

  Cargo({
    required this.id,
    this.description,
    this.phoneNumber,
    this.verificationCode,
    required this.status,
    this.selfLocation,
    this.targetLocation,
    this.measure,
    this.distributorId,
    this.distributorName,
    this.driverId,
    this.driverName,
    this.createdAt,
    this.takingTime,
    this.deliveredTime,
  });

  factory Cargo.fromJson(Map<String, dynamic> json) {
    return Cargo(
      id: json['id'] ?? 0,
      description: json['description'],
      phoneNumber: json['phoneNumber'],
      verificationCode: json['verificationCode'],
      status: _parseStatus(json['cargoSituation'] ?? json['status'] ?? 'CREATED'),
      selfLocation: json['selfLocation'] != null ? Location.fromJson(json['selfLocation']) : null,
      targetLocation: json['targetLocation'] != null ? Location.fromJson(json['targetLocation']) : null,
      measure: json['measure'] != null ? Measure.fromJson(json['measure']) : null,
      distributorId: json['distributorId'],
      distributorName: json['distributorName'],
      driverId: json['driverId'],
      driverName: json['driverName'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      takingTime: json['takingTime'] != null ? DateTime.parse(json['takingTime']) : null,
      deliveredTime: json['deliveredTime'] != null ? DateTime.parse(json['deliveredTime']) : null,
    );
  }

  static CargoSituation _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'CREATED':
        return CargoSituation.CREATED;
      case 'ASSIGNED':
        return CargoSituation.ASSIGNED;
      case 'PICKED_UP':
        return CargoSituation.PICKED_UP;
      case 'DELIVERED':
        return CargoSituation.DELIVERED;
      case 'CANCELLED':
        return CargoSituation.CANCELLED;
      case 'EXPIRED':
        return CargoSituation.EXPIRED;
      case 'FAILED':
        return CargoSituation.FAILED;
      default:
        return CargoSituation.CREATED;
    }
  }

  String get statusText {
    switch (status) {
      case CargoSituation.CREATED:
        return 'Oluşturuldu';
      case CargoSituation.ASSIGNED:
        return 'Atandı';
      case CargoSituation.PICKED_UP:
        return 'Alındı';
      case CargoSituation.DELIVERED:
        return 'Teslim Edildi';
      case CargoSituation.CANCELLED:
        return 'İptal Edildi';
      case CargoSituation.EXPIRED:
        return 'Süresi Doldu';
      case CargoSituation.FAILED:
        return 'Başarısız';
    }
  }

  bool get isActive => status == CargoSituation.CREATED || 
                       status == CargoSituation.ASSIGNED || 
                       status == CargoSituation.PICKED_UP;
}
