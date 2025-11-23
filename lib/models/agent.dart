// Import required model
import 'user.dart';

class Agent {
  final int id;
  final int userId;
  final String agencyName;
  final String? commissionRate;
  final List<String>? docs;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final User? user;

  Agent({
    required this.id,
    required this.userId,
    required this.agencyName,
    this.commissionRate,
    this.docs,
    required this.isVerified,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'],
      userId: json['user_id'],
      agencyName: json['agency_name'],
      commissionRate: json['commission_rate']?.toString(),
      docs: json['docs'] != null ? List<String>.from(json['docs']) : null,
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'agency_name': agencyName,
      'commission_rate': commissionRate,
      'docs': docs,
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user': user?.toJson(),
    };
  }
}