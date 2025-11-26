class Tenant {
  final int id;
  final String name;
  final String domain;
  final int? userCount;
  final int? propertyCount;
  final int? unitCount;
  final int? activeLeaseCount;
  final int? pendingMaintenanceCount;
  final double? totalPayments;
  final String? subscriptionStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Tenant({
    required this.id,
    required this.name,
    required this.domain,
    this.userCount,
    this.propertyCount,
    this.unitCount,
    this.activeLeaseCount,
    this.pendingMaintenanceCount,
    this.totalPayments,
    this.subscriptionStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'],
      name: json['name'],
      domain: json['domain'],
      userCount: json['user_count'] ?? json['total_users'],
      propertyCount: json['property_count'] ?? json['total_properties'],
      unitCount: json['unit_count'] ?? json['total_units'],
      activeLeaseCount: json['active_lease_count'] ?? json['active_leases'],
      pendingMaintenanceCount: json['pending_maintenance_count'] ?? json['pending_maintenance'],
      totalPayments: json['total_payments'] != null ? double.parse(json['total_payments'].toString()) : null,
      subscriptionStatus: json['subscription_status'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'domain': domain,
      'user_count': userCount,
      'property_count': propertyCount,
      'unit_count': unitCount,
      'active_lease_count': activeLeaseCount,
      'pending_maintenance_count': pendingMaintenanceCount,
      'total_payments': totalPayments,
      'subscription_status': subscriptionStatus,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class Payment {
  final int id;
  final int leaseId;
  final int tenantId;
  final double amount;
  final String status; // pending, completed, failed, refunded
  final String? paymentMethod;
  final String? notes;
  final DateTime? paymentDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Payment({
    required this.id,
    required this.leaseId,
    required this.tenantId,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.notes,
    this.paymentDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      leaseId: json['lease_id'],
      tenantId: json['tenant_id'],
      amount: double.parse(json['amount'].toString()),
      status: json['status'],
      paymentMethod: json['payment_method'],
      notes: json['notes'],
      paymentDate: json['payment_date'] != null ? DateTime.parse(json['payment_date']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lease_id': leaseId,
      'tenant_id': tenantId,
      'amount': amount,
      'status': status,
      'payment_method': paymentMethod,
      'notes': notes,
      'payment_date': paymentDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}