class FarmModel {
  final String id;
  final String name;
  final String code;
  final String location;
  final double area;
  final double pricePerMonth;
  final bool isAvailable;
  final String status;
  final List<String> services;
  final List<String> tags;
  final double ratings;
  final int reviewCount;
  final Coordinates coordinates;
  final OwnerInfo ownerInfo;
  final List<FarmImage> images;

  FarmModel({
    required this.id,
    required this.name,
    required this.code,
    required this.location,
    required this.area,
    required this.pricePerMonth,
    required this.isAvailable,
    required this.status,
    required this.services,
    required this.tags,
    required this.ratings,
    required this.reviewCount,
    required this.coordinates,
    required this.ownerInfo,
    required this.images,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: json['_id'],
      name: json['name'],
      code: json['code'],
      location: json['location'],
      area: json['area'].toDouble(),
      pricePerMonth: json['pricePerMonth'].toDouble(),
      isAvailable: json['isAvailable'],
      status: json['status'],
      services: List<String>.from(json['services']),
      tags: List<String>.from(json['tags']),
      ratings: (json['ratings'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'],
      coordinates: Coordinates.fromJson(json['coordinates']),
      ownerInfo: OwnerInfo.fromJson(json['ownerInfo']),
      images:
          (json['images'] as List).map((e) => FarmImage.fromJson(e)).toList(),
    );
  }
}

class Coordinates {
  final double lat;
  final double lng;

  Coordinates({required this.lat, required this.lng});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      lat: json['lat'].toDouble(),
      lng: json['lng'].toDouble(),
    );
  }
}

class OwnerInfo {
  final String name;
  final String phone;
  final String email;

  OwnerInfo({required this.name, required this.phone, required this.email});

  factory OwnerInfo.fromJson(Map<String, dynamic> json) {
    return OwnerInfo(
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
    );
  }
}

class FarmImage {
  final String imageUrl;
  final String description;

  FarmImage({required this.imageUrl, required this.description});

  factory FarmImage.fromJson(Map<String, dynamic> json) {
    return FarmImage(
      imageUrl: json['imageUrl'],
      description: json['description'],
    );
  }

  String getFullUrl() {
    if (imageUrl.startsWith("http")) return imageUrl;
    return "https://api-ndolv2.nongdanonline.vn$imageUrl";
  }
}
