class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatar;
  final List<String> roles;
  final bool? isActive;
  final String? token;
  final String? refreshToken;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatar,
    this.roles = const [],
    this.isActive,
    this.token,
    this.refreshToken,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? avatar,
    List<String>? roles,
    bool? isActive,
    String? token,
    String? refreshToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      roles: roles ?? this.roles,
      isActive: isActive ?? this.isActive,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json['user'] ?? json;

    return UserModel(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phone: data['phone'],
      avatar: data['avatar'],
      roles: data['role'] is List ? List<String>.from(data['role']) : [],
      isActive: data['isActive'],
      token: json['token'] ?? json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'avatar': avatar,
      'role': roles,
      'isActive': isActive,
      'token': token,
      'refreshToken': refreshToken,
    };
  }
}
