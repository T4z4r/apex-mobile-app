class Property {
  final int id;
  final String title;
  final String? description;
  final String address;
  final String neighborhood;
  final double? geoLat;
  final double? geoLng;
  final List<String>? amenities;
  final int? landlordId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Unit>? units;

  Property({
    required this.id,
    required this.title,
    this.description,
    required this.address,
    required this.neighborhood,
    this.geoLat,
    this.geoLng,
    this.amenities,
    this.landlordId,
    this.createdAt,
    this.updatedAt,
    this.units,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      address: json['address'],
      neighborhood: json['neighborhood'],
      geoLat: json['geo_lat'] != null ? double.parse(json['geo_lat'].toString()) : null,
      geoLng: json['geo_lng'] != null ? double.parse(json['geo_lng'].toString()) : null,
      amenities: json['amenities'] != null ? List<String>.from(json['amenities']) : null,
      landlordId: json['landlord_id'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      units: json['units'] != null ? (json['units'] as List).map((u) => Unit.fromJson(u)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'address': address,
      'neighborhood': neighborhood,
      'geo_lat': geoLat,
      'geo_lng': geoLng,
      'amenities': amenities,
      'landlord_id': landlordId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'units': units?.map((u) => u.toJson()).toList(),
    };
  }
}

// Import Unit to avoid circular dependency issues
class Unit {
  final int id;
  final int propertyId;
  final String unitLabel;
  final int bedrooms;
  final int bathrooms;
  final double? sizeM2;
  final double rentAmount;
  final double depositAmount;
  final bool isAvailable;
  final List<String>? photos;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Unit({
    required this.id,
    required this.propertyId,
    required this.unitLabel,
    required this.bedrooms,
    required this.bathrooms,
    this.sizeM2,
    required this.rentAmount,
    required this.depositAmount,
    required this.isAvailable,
    this.photos,
    this.createdAt,
    this.updatedAt,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      propertyId: json['property_id'],
      unitLabel: json['unit_label'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      sizeM2: json['size_m2'] != null ? double.parse(json['size_m2'].toString()) : null,
      rentAmount: double.parse(json['rent_amount'].toString()),
      depositAmount: double.parse(json['deposit_amount'].toString()),
      isAvailable: json['is_available'] ?? true,
      photos: json['photos'] != null ? List<String>.from(json['photos']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'unit_label': unitLabel,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'size_m2': sizeM2,
      'rent_amount': rentAmount,
      'deposit_amount': depositAmount,
      'is_available': isAvailable,
      'photos': photos,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}