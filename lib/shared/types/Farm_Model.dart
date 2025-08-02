import 'package:farmrole/env/env.dart';

class FarmModel {
  final String id;
  final String name;
  final String code;
  final String location;
  final double area;
  final bool isAvailable;
  final String status;
  final List<String> services;
  final List<String> features;
  final List<String> tags;
  final double ratings;
  final OwnerInfo ownerInfo;
  final List<FarmImage> images;
  final String phone;
  final String zalo;
  final double cultivatedArea;
  final String province;
  final String district;
  final String ward;
  final String street;

  const FarmModel({
    required this.id,
    required this.name,
    required this.code,
    required this.location,
    required this.area,
    required this.isAvailable,
    required this.status,
    required this.services,
    required this.features,
    required this.tags,
    required this.ratings,
    required this.ownerInfo,
    required this.images,
    required this.phone,
    required this.zalo,
    required this.cultivatedArea,
    required this.province,
    required this.district,
    required this.ward,
    required this.street,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      location: json['location'] ?? '',
      area: (json['area'] ?? 0).toDouble(),
      isAvailable: json['isAvailable'] ?? false,
      status: json['status'] ?? 'pending',
      services: List<String>.from(json['services'] ?? []),
      features: List<String>.from(json['features'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      ratings: (json['ratings'] ?? 0).toDouble(),
      ownerInfo: OwnerInfo.fromJson(json['ownerInfo'] ?? {}),
      images:
          (json['pictures'] as List?)
              ?.map((e) => FarmImage.fromJson(e))
              .toList() ??
          [],
      phone: json['phone'] ?? '',
      zalo: json['zalo'] ?? '',
      cultivatedArea: (json['cultivatedArea'] ?? 0).toDouble(),
      province: json['province'] ?? '',
      district: json['district'] ?? '',
      ward: json['ward'] ?? '',
      street: json['street'] ?? '',
    );
  }

  factory FarmModel.empty() {
    return FarmModel(
      id: '',
      name: '',
      code: '',
      location: '',
      area: 0.0,
      isAvailable: true,
      status: 'pending',
      services: [],
      features: [],
      tags: [],
      ratings: 0,
      ownerInfo: const OwnerInfo(name: '', phone: '', email: ''),
      images: const [],
      phone: '',
      zalo: '',
      cultivatedArea: 0.0,
      province: '',
      district: '',
      ward: '',
      street: '',
    );
  }

  FarmModel copyWith({
    String? id,
    String? name,
    String? code,
    String? location,
    double? area,
    bool? isAvailable,
    String? status,
    List<String>? services,
    List<String>? features,
    List<String>? tags,
    double? ratings,
    int? reviewCount,
    Coordinates? coordinates,
    OwnerInfo? ownerInfo,
    List<FarmImage>? images,
    String? phone,
    String? zalo,
    String? operationTime,
    double? cultivatedArea,
    String? province,
    String? district,
    String? ward,
    String? street,
  }) {
    return FarmModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      location: location ?? this.location,
      area: area ?? this.area,
      isAvailable: isAvailable ?? this.isAvailable,
      status: status ?? this.status,
      services: services ?? this.services,
      features: features ?? this.features,
      tags: tags ?? this.tags,
      ratings: ratings ?? this.ratings,
      ownerInfo: ownerInfo ?? this.ownerInfo,
      images: images ?? this.images,
      phone: phone ?? this.phone,
      zalo: zalo ?? this.zalo,
      cultivatedArea: cultivatedArea ?? this.cultivatedArea,
      province: province ?? this.province,
      district: district ?? this.district,
      ward: ward ?? this.ward,
      street: street ?? this.street,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'area': area,
      'services': services,
      'features': features,
      'tags': tags,
      'phone': phone,
      'zalo': zalo,
      'cultivatedArea': cultivatedArea,
      'province': province,
      'district': district,
      'ward': ward,
      'street': street,
    };
  }
}

class Coordinates {
  final double lat;
  final double lng;

  const Coordinates({required this.lat, required this.lng});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
    );
  }
}

class OwnerInfo {
  final String name;
  final String phone;
  final String email;

  const OwnerInfo({
    required this.name,
    required this.phone,
    required this.email,
  });

  factory OwnerInfo.fromJson(Map<String, dynamic> json) {
    return OwnerInfo(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class FarmImage {
  final String id;
  final String farmId;
  final String imageUrl;
  final String description;
  final bool isDefault;
  final String uploadedBy;
  final DateTime createdAt;

  FarmImage({
    required this.id,
    required this.farmId,
    required this.imageUrl,
    required this.description,
    required this.isDefault,
    required this.uploadedBy,
    required this.createdAt,
  });

  factory FarmImage.fromJson(Map<String, dynamic> json) {
    return FarmImage(
      id: json['_id'] ?? '',
      farmId: json['farmId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      isDefault: json['isDefault'] ?? false,
      uploadedBy: json['uploadedBy'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
  static final String _baseUrl = Environment.config.baseUrl;

  String getFullUrl() {
    if (imageUrl.startsWith('http')) return imageUrl;
    return '$_baseUrl$imageUrl';
  }
}
