import 'user.dart';
import 'lease.dart';

class Dispute {
  final int id;
  final int leaseId;
  final int tenantId;
  final String issue;
  final String status; // resolved, rejected
  final String? adminResolutionNotes;
  final List<String>? evidence;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Lease? lease;
  final User? tenant;

  Dispute({
    required this.id,
    required this.leaseId,
    required this.tenantId,
    required this.issue,
    required this.status,
    this.adminResolutionNotes,
    this.evidence,
    this.createdAt,
    this.updatedAt,
    this.lease,
    this.tenant,
  });

  factory Dispute.fromJson(Map<String, dynamic> json) {
    return Dispute(
      id: json['id'],
      leaseId: json['lease_id'],
      tenantId: json['tenant_id'],
      issue: json['issue'],
      status: json['status'],
      adminResolutionNotes: json['admin_resolution_notes'],
      evidence: json['evidence'] != null ? List<String>.from(json['evidence']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      lease: json['lease'] != null ? Lease.fromJson(json['lease']) : null,
      tenant: json['tenant'] != null ? User.fromJson(json['tenant']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lease_id': leaseId,
      'tenant_id': tenantId,
      'issue': issue,
      'status': status,
      'admin_resolution_notes': adminResolutionNotes,
      'evidence': evidence,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'lease': lease?.toJson(),
      'tenant': tenant?.toJson(),
    };
  }
}