class Role {
  final int id;
  final String name;
  final String guardName;
  final List<String>? permissions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Role({
    required this.id,
    required this.name,
    required this.guardName,
    this.permissions,
    this.createdAt,
    this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      guardName: json['guard_name'] ?? 'web',
      permissions: json['permissions'] != null ? List<String>.from(json['permissions']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'guard_name': guardName,
      'permissions': permissions,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class Permission {
  final int id;
  final String name;
  final String guardName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Permission({
    required this.id,
    required this.name,
    required this.guardName,
    this.createdAt,
    this.updatedAt,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'],
      name: json['name'],
      guardName: json['guard_name'] ?? 'web',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'guard_name': guardName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}