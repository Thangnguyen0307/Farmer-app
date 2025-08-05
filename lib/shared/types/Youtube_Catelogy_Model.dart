class YoutubeCategoryModel {
  final String id;
  final String name;
  final String description;
  final String imageThumbnail;
  final DateTime createdAt;
  final DateTime updatedAt;

  YoutubeCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageThumbnail,
    required this.createdAt,
    required this.updatedAt,
  });

  factory YoutubeCategoryModel.fromJson(Map<String, dynamic> json) {
    return YoutubeCategoryModel(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      imageThumbnail: json['imageThumbnail'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'description': description,
    'imageThumbnail': imageThumbnail,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
