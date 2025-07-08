class VideoModel {
  final String id;
  final String title;
  final String youtubeLink;
  final String farmName;
  final String uploadedBy;
  final String avatar;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;

  VideoModel({
    required this.id,
    required this.title,
    required this.youtubeLink,
    required this.farmName,
    required this.uploadedBy,
    required this.avatar,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['_id'],
      title: json['title'],
      youtubeLink: json['youtubeLink'],
      farmName: json['farmId']?['name'] ?? 'Không rõ',
      uploadedBy: json['uploadedBy']?['fullName'] ?? 'Ẩn danh',
      avatar: json['uploadedBy']?['avatar'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
    );
  }
}
