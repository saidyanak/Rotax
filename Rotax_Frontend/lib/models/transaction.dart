enum TransactionType {
  DEPOSIT,
  WITHDRAWAL,
  CARGO_PAYMENT,
  DRIVER_EARNING,
  COMMISSION,
  REFUND,
  BONUS,
}

enum TransactionStatus {
  PENDING,
  COMPLETED,
  FAILED,
  CANCELLED,
  REFUNDED,
}

class Transaction {
  final int id;
  final String transactionReference;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final double? fee;
  final double? balanceBefore;
  final double? balanceAfter;
  final String currency;
  final String? description;
  final int? cargoId;
  final DateTime? createdAt;
  final DateTime? completedAt;

  Transaction({
    required this.id,
    required this.transactionReference,
    required this.type,
    required this.status,
    required this.amount,
    this.fee,
    this.balanceBefore,
    this.balanceAfter,
    required this.currency,
    this.description,
    this.cargoId,
    this.createdAt,
    this.completedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      transactionReference: json['transactionReference'] ?? '',
      type: _parseType(json['transactionType'] ?? 'DEPOSIT'),
      status: _parseStatus(json['status'] ?? 'PENDING'),
      amount: (json['amount'] ?? 0).toDouble(),
      fee: json['fee']?.toDouble(),
      balanceBefore: json['balanceBefore']?.toDouble(),
      balanceAfter: json['balanceAfter']?.toDouble(),
      currency: json['currency'] ?? 'TRY',
      description: json['description'],
      cargoId: json['cargoId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }

  static TransactionType _parseType(String type) {
    switch (type.toUpperCase()) {
      case 'DEPOSIT':
        return TransactionType.DEPOSIT;
      case 'WITHDRAWAL':
        return TransactionType.WITHDRAWAL;
      case 'CARGO_PAYMENT':
        return TransactionType.CARGO_PAYMENT;
      case 'DRIVER_EARNING':
        return TransactionType.DRIVER_EARNING;
      case 'COMMISSION':
        return TransactionType.COMMISSION;
      case 'REFUND':
        return TransactionType.REFUND;
      case 'BONUS':
        return TransactionType.BONUS;
      default:
        return TransactionType.DEPOSIT;
    }
  }

  static TransactionStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return TransactionStatus.PENDING;
      case 'COMPLETED':
        return TransactionStatus.COMPLETED;
      case 'FAILED':
        return TransactionStatus.FAILED;
      case 'CANCELLED':
        return TransactionStatus.CANCELLED;
      case 'REFUNDED':
        return TransactionStatus.REFUNDED;
      default:
        return TransactionStatus.PENDING;
    }
  }

  String get typeText {
    switch (type) {
      case TransactionType.DEPOSIT:
        return 'Yükleme';
      case TransactionType.WITHDRAWAL:
        return 'Çekim';
      case TransactionType.CARGO_PAYMENT:
        return 'Kargo Ödemesi';
      case TransactionType.DRIVER_EARNING:
        return 'Kazanç';
      case TransactionType.COMMISSION:
        return 'Komisyon';
      case TransactionType.REFUND:
        return 'İade';
      case TransactionType.BONUS:
        return 'Bonus';
    }
  }

  String get statusText {
    switch (status) {
      case TransactionStatus.PENDING:
        return 'Beklemede';
      case TransactionStatus.COMPLETED:
        return 'Tamamlandı';
      case TransactionStatus.FAILED:
        return 'Başarısız';
      case TransactionStatus.CANCELLED:
        return 'İptal';
      case TransactionStatus.REFUNDED:
        return 'İade Edildi';
    }
  }

  bool get isIncome => type == TransactionType.DEPOSIT || 
                       type == TransactionType.DRIVER_EARNING || 
                       type == TransactionType.REFUND ||
                       type == TransactionType.BONUS;
}
