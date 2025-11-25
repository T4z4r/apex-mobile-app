// Import required models
import 'user.dart';
import 'property.dart';

class Lease {
  final int id;
  final int unitId;
  final int tenantId;
  final int? landlordId;
  final DateTime startDate;
  final DateTime endDate;
  final double? rentAmount;
  final double? depositAmount;
  final String paymentFrequency;
  final String status; // pending, active, terminated
  final String? leasePdfUrl;
  final DateTime? signedAt;
  final String? signature;
  final String? signatureType; // typed, image
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Unit? unit;
  final User? tenant;
  final User? landlord;

  Lease({
    required this.id,
    required this.unitId,
    required this.tenantId,
    this.landlordId,
    required this.startDate,
    required this.endDate,
    this.rentAmount,
    this.depositAmount,
    required this.paymentFrequency,
    required this.status,
    this.leasePdfUrl,
    this.signedAt,
    this.signature,
    this.signatureType,
    this.createdAt,
    this.updatedAt,
    this.unit,
    this.tenant,
    this.landlord,
  });

  factory Lease.fromJson(Map<String, dynamic> json) {
    return Lease(
      id: json['id'],
      unitId: json['unit_id'],
      tenantId: json['tenant_id'],
      landlordId: json['landlord_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      rentAmount: json['rent_amount'] != null ? double.parse(json['rent_amount'].toString()) : null,
      depositAmount: json['deposit_amount'] != null ? double.parse(json['deposit_amount'].toString()) : null,
      paymentFrequency: json['payment_frequency'],
      status: json['status'],
      leasePdfUrl: json['lease_pdf_url'],
      signedAt: json['signed_at'] != null ? DateTime.parse(json['signed_at']) : null,
      signature: json['signature'],
      signatureType: json['signature_type'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      unit: json['unit'] != null ? Unit.fromJson(json['unit']) : null,
      tenant: json['tenant'] != null ? User.fromJson(json['tenant']) : null,
      landlord: json['landlord'] != null ? User.fromJson(json['landlord']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unit_id': unitId,
      'tenant_id': tenantId,
      'landlord_id': landlordId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'rent_amount': rentAmount,
      'deposit_amount': depositAmount,
      'payment_frequency': paymentFrequency,
      'status': status,
      'lease_pdf_url': leasePdfUrl,
      'signed_at': signedAt?.toIso8601String(),
      'signature': signature,
      'signature_type': signatureType,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'unit': unit?.toJson(),
      'tenant': tenant?.toJson(),
      'landlord': landlord?.toJson(),
    };
  }
}