import 'package:flutter/foundation.dart';

class VetCertificate {
  final int id;
  final String certificateNumber;
  final DateTime? certificateDate;
  final int dayesLimit;
  final int trackingMode;
  final double allowedWeightTon;
  final double allowedRemainingTon;
  final int? allowedBoxes;
  final int? allowedRemainingBoxes;

  VetCertificate({
    required this.id,
    required this.certificateNumber,
    this.certificateDate,
    required this.dayesLimit,
    required this.trackingMode,
    required this.allowedWeightTon,
    required this.allowedRemainingTon,
    this.allowedBoxes,
    this.allowedRemainingBoxes,
  });

  factory VetCertificate.fromJson(Map<String, dynamic> json) {
    return VetCertificate(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      certificateNumber: json['certificate_number']?.toString() ?? '',
      certificateDate: json['certificate_date'] != null
          ? DateTime.tryParse(json['certificate_date'].toString())
          : null,
      dayesLimit: int.tryParse(json['dayesLimit']?.toString() ?? '30') ?? 30,
      trackingMode: int.tryParse(json['tracking_mode']?.toString() ?? '0') ?? 0,
      allowedWeightTon: double.tryParse(json['allowed_weight_ton']?.toString() ?? '0') ?? 0.0,
      allowedRemainingTon: double.tryParse(json['allowed_remaining_ton']?.toString() ?? '0') ?? 0.0,
      allowedBoxes: json['allowed_boxes'] != null
          ? int.tryParse(json['allowed_boxes'].toString())
          : null,
      allowedRemainingBoxes: json['allowed_remaining_boxes'] != null
          ? int.tryParse(json['allowed_remaining_boxes'].toString())
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VetCertificate && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'VetCertificate(id: $id, number: $certificateNumber)';
}