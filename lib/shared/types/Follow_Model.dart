class FollowUser {
  final String id;
  final String fullName;
  final String? avatar;

  FollowUser({
    required this.id,
    required this.fullName,
    this.avatar,
  });

  factory FollowUser.fromJson(Map<String, dynamic> json) {
    return FollowUser(
      id: json['id'],
      fullName: json['fullName'],
      avatar: json['avatar'],
    );
  }
}
