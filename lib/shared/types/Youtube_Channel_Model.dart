class YoutubeChannelModel {
  final String id;
  final String channelId;
  final String title;
  final String? imageThumbnail;
  final CategoryInfo category;
  final DateTime createdAt;
  final DateTime updatedAt;

  YoutubeChannelModel({
    required this.id,
    required this.channelId,
    required this.title,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.imageThumbnail,
  });

  factory YoutubeChannelModel.fromJson(Map<String, dynamic> json) {
    return YoutubeChannelModel(
      id: json['_id'] ?? '',
      channelId: json['channelId'] ?? '',
      title: json['title'] ?? '',
      imageThumbnail: json['imageThumbnail'],
      category: CategoryInfo.fromJson(json['category']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class CategoryInfo {
  final String id;
  final String name;

  CategoryInfo({required this.id, required this.name});

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(id: json['_id'] ?? '', name: json['name'] ?? '');
  }
}
