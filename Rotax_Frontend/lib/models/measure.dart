class Measure {
  final int? id;
  final double? weight;
  final double? length;
  final double? width;
  final double? height;
  final String? size;

  Measure({
    this.id,
    this.weight,
    this.length,
    this.width,
    this.height,
    this.size,
  });

  factory Measure.fromJson(Map<String, dynamic> json) {
    return Measure(
      id: json['id'],
      weight: json['weight']?.toDouble(),
      length: json['length']?.toDouble(),
      width: json['width']?.toDouble(),
      height: json['height']?.toDouble(),
      size: json['size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'length': length,
      'width': width,
      'height': height,
      'size': size,
    };
  }

  String get dimensions {
    if (length != null && width != null && height != null) {
      return '${length!.toStringAsFixed(1)} x ${width!.toStringAsFixed(1)} x ${height!.toStringAsFixed(1)} cm';
    }
    return size ?? 'Belirtilmemiş';
  }
}
