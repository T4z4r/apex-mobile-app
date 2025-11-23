import 'user.dart';
import 'property.dart';

class MaintenanceRequest {
  final int id;
  final int unitId;
  final int tenantId;
  final String title;
  final String description;
  final String priority; // low, medium, high, urgent
  final String status; // open, in_progress, resolved, rejected
  final int? assignedTo;
  final String? resolutionNotes;
  final List<String>? photos;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Unit? unit;
  final User? tenant;
  final User? assignedUser;

  MaintenanceRequest({
    required this.id,
    required this.unitId,
    required this.tenantId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    this.assignedTo,
    this.resolutionNotes,
    this.photos,
    this.createdAt,
    this.updatedAt,
    this.unit,
    this.tenant,
    this.assignedUser,
  });

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      id: json['id'],
      unitId: json['unit_id'],
      tenantId: json['tenant_id'],
      title: json['title'],
      description: json['description'],
      priority: json['priority'],
      status: json['status'],
      assignedTo: json['assigned_to'],
      resolutionNotes: json['resolution_notes'],
      photos: json['photos'] != null ? List<String>.from(json['photos']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      unit: json['unit'] != null ? Unit.fromJson(json['unit']) : null,
      tenant: json['tenant'] != null ? User.fromJson(json['tenant']) : null,
      assignedUser: json['assigned_user'] != null ? User.fromJson(json['assigned_user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unit_id': unitId,
      'tenant_id': tenantId,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'assigned_to': assignedTo,
      'resolution_notes': resolutionNotes,
      'photos': photos,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'unit': unit?.toJson(),
      'tenant': tenant?.toJson(),
      'assigned_user': assignedUser?.toJson(),
    };
  }
}