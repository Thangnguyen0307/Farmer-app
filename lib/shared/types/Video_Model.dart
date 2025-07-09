class VideoModel {
  final String id;
  final String title;
  final String youtubeLink;
  final String localFilePath;
  final String farmName;
  final String uploadedBy;
  final String avatar;
  final DateTime createdAt;
  int likeCount;
  bool yourLike;
  final int commentCount;
  final String playlistId;
  final String playlistName;
  final String status;

  VideoModel({
    required this.id,
    required this.title,
    required this.youtubeLink,
    required this.localFilePath,
    required this.farmName,
    required this.uploadedBy,
    required this.avatar,
    required this.createdAt,
    required this.likeCount,
    required this.yourLike,
    required this.commentCount,
    required this.playlistId,
    required this.playlistName,
    required this.status,
  });

  VideoModel copyWith({
    String? id,
    String? title,
    String? youtubeLink,
    String? localFilePath,
    String? farmName,
    String? uploadedBy,
    String? avatar,
    DateTime? createdAt,
    int? likeCount,
    bool? yourLike,
    int? commentCount,
    String? playlistId,
    String? playlistName,
    String? status,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      youtubeLink: youtubeLink ?? this.youtubeLink,
      localFilePath: localFilePath ?? this.localFilePath,
      farmName: farmName ?? this.farmName,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      yourLike: yourLike ?? this.yourLike,
      commentCount: commentCount ?? this.commentCount,
      playlistId: playlistId ?? this.playlistId,
      playlistName: playlistName ?? this.playlistName,
      status: status ?? this.status,
    );
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      youtubeLink: json['youtubeLink'] ?? '',
      localFilePath: json['localFilePath'] ?? '',
      farmName: json['farmId']?['name'] ?? 'Không rõ',
      uploadedBy: json['uploadedBy']?['fullName'] ?? 'Ẩn danh',
      avatar: json['uploadedBy']?['avatar'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      likeCount: json['likeCount'] ?? 0,
      yourLike: json['yourLike'] ?? false,
      commentCount: json['commentCount'] ?? 0,
      playlistId: json['playlistId'] ?? '',
      playlistName: json['playlistName'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class Pagination {
  final int total;
  final int page;
  final int limit;

  Pagination({required this.total, required this.page, required this.limit});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
    );
  }
}

class VideoPaginationResponse {
  final List<VideoModel> videos;
  final Pagination pagination;

  VideoPaginationResponse({required this.videos, required this.pagination});

  factory VideoPaginationResponse.fromJson(Map<String, dynamic> json) {
    return VideoPaginationResponse(
      videos:
          (json['videos'] as List<dynamic>)
              .map((v) => VideoModel.fromJson(v))
              .toList(),
      pagination: Pagination.fromJson(json),
    );
  }
}
