class User {
  final int id;
  final String name;
  final String? domain;
  final String? phone;
  final String? email;
  final String role;
  final bool? isVerified;
  final String? idDocumentUrl;
  final int? tenantId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    this.domain,
    this.phone,
    this.email,
    required this.role,
    this.isVerified,
    this.idDocumentUrl,
    this.tenantId,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      domain: json['domain'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'] ?? 'tenant', // Default to 'tenant' if not provided
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
      idDocumentUrl: json['id_document_url'],
      tenantId: json['tenant_id'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'domain': domain,
      'phone': phone,
      'email': email,
      'role': role,
      'is_verified': isVerified == true ? 1 : 0,
      'id_document_url': idDocumentUrl,
      'tenant_id': tenantId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}