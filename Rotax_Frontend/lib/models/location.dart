class Location {
  final int? id;
  final String? address;
  final String? city;
  final String? district;
  final String? postalCode;
  final double? latitude;
  final double? longitude;

  Location({
    this.id,
    this.address,
    this.city,
    this.district,
    this.postalCode,
    this.latitude,
    this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      address: json['address'],
      city: json['city'],
      district: json['district'],
      postalCode: json['postalCode'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'city': city,
      'district': district,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (district != null && district!.isNotEmpty) parts.add(district!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    return parts.join(', ');
  }
}
