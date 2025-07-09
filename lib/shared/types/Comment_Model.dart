class CommentModel {
  final UserModel user;
  final UserModel postAuthor;
  final String comment;
  final bool status;
  final DateTime createdAt;
  final List<ReplyModel> replies;
  final int index;

  CommentModel({
    required this.user,
    required this.postAuthor,
    required this.comment,
    required this.status,
    required this.createdAt,
    required this.replies,
    required this.index,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      user: UserModel.fromJson(json['userId']),
      postAuthor: UserModel.fromJson(json['postAuthorId']),
      comment: json['comment'] ?? '',
      status: json['status'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      replies:
          (json['replies'] as List<dynamic>)
              .map((e) => ReplyModel.fromJson(e))
              .toList(),
      index: json['index'] ?? 0,
    );
  }
}

class ReplyModel {
  final UserModel user;
  final String comment;
  final bool status;
  final DateTime createdAt;

  ReplyModel({
    required this.user,
    required this.comment,
    required this.status,
    required this.createdAt,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      user: UserModel.fromJson(json['userId']),
      comment: json['comment'] ?? '',
      status: json['status'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
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
      id: json['_id'],
      fullName: json['fullName'],
      avatar: json['avatar'],
    );
  }
}
