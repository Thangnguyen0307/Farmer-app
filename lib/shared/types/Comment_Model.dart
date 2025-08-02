class CommentModel {
  final CommentUserModel user;
  final CommentUserModel postAuthor;
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
      user: CommentUserModel.fromJson(json['userId']),
      postAuthor: CommentUserModel.fromJson(json['postAuthorId']),
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
  final CommentUserModel user;
  final String comment;
  final bool status;
  final DateTime createdAt;
  final int index;

  ReplyModel({
    required this.user,
    required this.comment,
    required this.status,
    required this.createdAt,
    required this.index,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      user: CommentUserModel.fromJson(json['userId']),
      comment: json['comment'] ?? '',
      status: json['status'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      index: json['index'] ?? 0,
    );
  }
}

class CommentUserModel {
  final String id;
  final String fullName;
  final String avatar;

  CommentUserModel({
    required this.id,
    required this.fullName,
    required this.avatar,
  });

  factory CommentUserModel.fromJson(Map<String, dynamic> json) {
    return CommentUserModel(
      id: json['_id'],
      fullName: json['fullName'],
      avatar: json['avatar'],
    );
  }
}
