class CommentVideoModel {
  final String comment;
  final UserModel user;
  final DateTime createdAt;
  final int index;
  final List<CommentVideoModel> replies;

  CommentVideoModel({
    required this.comment,
    required this.user,
    required this.createdAt,
    required this.index,
    this.replies = const [],
  });

  factory CommentVideoModel.fromJson(Map<String, dynamic> json) {
    return CommentVideoModel(
      comment: json['comment'] ?? '',
      user: UserModel.fromJson(json['userId'] ?? {}),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      index: json['index'] ?? 0,
      replies:
          (json['replies'] as List<dynamic>?)
              ?.map((e) => CommentVideoModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class UserModel {
  final String id;
  final String fullName;
  final String avatar;

  UserModel({required this.id, required this.fullName, required this.avatar});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}
