class PostModel {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final List<String> images;
  int like;
  final int commentCount;
  final AuthorModel author;
  final bool status;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool yourLike;

  PostModel({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.images,
    required this.like,
    required this.commentCount,
    required this.author,
    required this.status,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.yourLike,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      like: json['likeCount'] ?? json['like'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      author:
          json['authorId'] is Map<String, dynamic>
              ? AuthorModel.fromJson(json['authorId'])
              : AuthorModel(
                id: json['authorId'] ?? '',
                fullName: '',
                avatar: '',
              ),
      status: json['status'] ?? false,
      note: json['note'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      yourLike: json['yourLike'] ?? false,
    );
  }

  /// Tạo copyWith để có thể override author hoặc các trường khác
  PostModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? tags,
    List<String>? images,
    int? like,
    int? commentCount,
    AuthorModel? author,
    bool? status,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? yourLike,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      like: like ?? this.like,
      commentCount: commentCount ?? this.commentCount,
      author: author ?? this.author,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      yourLike: yourLike ?? this.yourLike,
    );
  }
}

class AuthorModel {
  final String id;
  final String fullName;
  final String avatar;

  AuthorModel({required this.id, required this.fullName, required this.avatar});

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}

class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      totalPages: json['totalPages'],
    );
  }
}

extension PaginationCopy on Pagination {
  Pagination copyWith({int? total, int? page, int? limit, int? totalPages}) {
    return Pagination(
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
