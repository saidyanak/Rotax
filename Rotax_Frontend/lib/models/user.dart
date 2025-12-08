class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String role;
  final String? profilePictureUrl;
  final bool enabled;
  final bool accountNonLocked;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.role,
    this.profilePictureUrl,
    this.enabled = true,
    this.accountNonLocked = true,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? '',
      profilePictureUrl: json['profilePictureUrl'],
      enabled: json['enabled'] ?? true,
      accountNonLocked: json['accountNonLocked'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'role': role,
      'profilePictureUrl': profilePictureUrl,
      'enabled': enabled,
      'accountNonLocked': accountNonLocked,
    };
  }

  String get fullName => '$firstName $lastName';
  
  bool get isDriver => role == 'DRIVER';
  bool get isDistributor => role == 'DISTRIBUTOR';
  bool get isAdmin => role == 'ADMIN';
}
