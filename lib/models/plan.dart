class Plan {
  final int id;
  final String name;
  final String? description;
  final double monthlyPrice;
  final double yearlyPrice;
  final int maxProperties;
  final int maxUnits;
  final int maxUsers;
  final List<String>? features;
  final bool isActive;
  final int? trialDays;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Plan({
    required this.id,
    required this.name,
    this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.maxProperties,
    required this.maxUnits,
    required this.maxUsers,
    this.features,
    required this.isActive,
    this.trialDays,
    this.createdAt,
    this.updatedAt,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      monthlyPrice: double.parse(json['monthly_price'].toString()),
      yearlyPrice: double.parse(json['yearly_price'].toString()),
      maxProperties: json['max_properties'],
      maxUnits: json['max_units'],
      maxUsers: json['max_users'],
      features: json['features'] != null ? List<String>.from(json['features']) : null,
      isActive: json['is_active'] ?? true,
      trialDays: json['trial_days'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'monthly_price': monthlyPrice,
      'yearly_price': yearlyPrice,
      'max_properties': maxProperties,
      'max_units': maxUnits,
      'max_users': maxUsers,
      'features': features,
      'is_active': isActive,
      'trial_days': trialDays,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class Subscription {
  final int id;
  final int planId;
  final int tenantId;
  final String billingCycle; // monthly, yearly
  final String status; // active, expired, cancelled
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Plan? plan;

  Subscription({
    required this.id,
    required this.planId,
    required this.tenantId,
    required this.billingCycle,
    required this.status,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    this.plan,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      planId: json['plan_id'],
      tenantId: json['tenant_id'],
      billingCycle: json['billing_cycle'],
      status: json['status'],
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      plan: json['plan'] != null ? Plan.fromJson(json['plan']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_id': planId,
      'tenant_id': tenantId,
      'billing_cycle': billingCycle,
      'status': status,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'plan': plan?.toJson(),
    };
  }
}