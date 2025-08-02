class VideoModel {
  final String id;
  final String title;
  final String youtubeLink;
  final String farmId;
  final String farmName;
  final String uploadedById;
  final String uploadedBy;
  final String avatar;
  final String? thumbnail;
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
    required this.farmId,
    required this.farmName,
    required this.uploadedById,
    required this.uploadedBy,
    required this.avatar,
    required this.thumbnail,
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
    String? farmId,
    String? farmName,
    String? uploadedById,
    String? uploadedBy,
    String? avatar,
    String? thumbnail,
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
      farmId: farmId ?? this.farmId,
      farmName: farmName ?? this.farmName,
      uploadedById: uploadedById ?? this.uploadedById,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      avatar: avatar ?? this.avatar,
      thumbnail: thumbnail ?? this.thumbnail,
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
      farmId:
          json['farmId'] is Map<String, dynamic>
              ? json['farmId']['_id'] ?? ''
              : '',
      farmName:
          json['farmId'] is Map<String, dynamic>
              ? json['farmId']['name'] ?? ''
              : '',
      uploadedById:
          json['uploadedBy'] is Map<String, dynamic>
              ? json['uploadedBy']['_id'] ?? ''
              : '',
      uploadedBy:
          json['uploadedBy'] is Map<String, dynamic>
              ? json['uploadedBy']['fullName'] ?? 'Ẩn danh'
              : 'Ẩn danh',
      avatar:
          json['uploadedBy'] is Map<String, dynamic>
              ? json['uploadedBy']['avatar'] ?? ''
              : '',
      thumbnail: json['thumbnailPath'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      likeCount:
          (json['likeCount'] is String)
              ? int.tryParse(json['likeCount']) ?? 0
              : json['likeCount'] ?? 0,
      yourLike: json['yourLike'] ?? false,
      commentCount:
          (json['commentCount'] is String)
              ? int.tryParse(json['commentCount']) ?? 0
              : json['commentCount'] ?? 0,
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
  int get totalPages => (total / limit).ceil();
}

class VideoPaginationResponse {
  final List<VideoModel> videos;
  List<VideoModel> get items => videos;
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
