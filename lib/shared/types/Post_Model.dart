// lib/shared/types/PostModel.dart
class PostModel {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final List<String> images;
  final int like;
  final AuthorModel author;
  final bool status;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.images,
    required this.like,
    required this.author,
    required this.status,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      tags: List<String>.from(json['tags'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      like: json['like'] ?? 0,
      author: AuthorModel.fromJson(json['authorId']),
      status: json['status'] ?? false,
      note: json['note'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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
      id: json['_id'],
      fullName: json['fullName'],
      avatar: json['avatar'],
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
