class Wallet {
  final int id;
  final int userId;
  final double balance;
  final double frozenBalance;
  final double totalEarnings;
  final double totalSpent;
  final String currency;
  final bool isActive;
  final DateTime? createdAt;

  Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    required this.frozenBalance,
    required this.totalEarnings,
    required this.totalSpent,
    required this.currency,
    required this.isActive,
    this.createdAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      balance: (json['balance'] ?? 0).toDouble(),
      frozenBalance: (json['frozenBalance'] ?? 0).toDouble(),
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'TRY',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  double get availableBalance => balance - frozenBalance;
}
