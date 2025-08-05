import 'package:farmrole/shared/types/Farm_Model.dart';

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
  final List<FarmModel> farms;
  final int? totalPoint;
  final String? rank;
  final int? followerCount;
  final int? followCount;
  final bool? yourFollow;

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
    this.farms = const [],
    this.totalPoint,
    this.rank,
    this.followerCount,
    this.followCount,
    this.yourFollow,
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
    List<FarmModel>? farms,
    int? totalPoint,
    String? rank,
    int? followerCount,
    int? followCount,
    bool? yourFollow,
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
      farms: farms ?? this.farms,
      totalPoint: totalPoint ?? this.totalPoint,
      rank: rank ?? this.rank,
      followerCount: followerCount ?? this.followerCount,
      followCount: followCount ?? this.followCount,
      yourFollow: yourFollow ?? this.yourFollow,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json['user'] ?? json;
    final farmsJson = json['farms'] ?? [];
    return UserModel(
      id: data['id'] ?? data['_id'] ?? '',
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phone:
          (data['phone'] as String?)?.isNotEmpty == true ? data['phone'] : null,
      avatar:
          (data['avatar'] as String?)?.isNotEmpty == true
              ? data['avatar']
              : null,
      roles: data['role'] is List ? List<String>.from(data['role']) : [],
      isActive: data['isActive'] as bool?,
      token: json['token'] ?? json['accessToken'] ?? '',
      refreshToken: json['refreshToken'],
      farms: (farmsJson as List).map((e) => FarmModel.fromJson(e)).toList(),
      totalPoint: data['totalPoint'] ?? 0,
      rank: data['rank'] ?? '',
      followerCount: data['followerCount'] ?? 0,
      followCount: data['followCount'] ?? 0,
      yourFollow: data['yourFollow'] as bool?,
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
      'farms': farms.map((e) => e.toJson()).toList(),
    };
  }

  bool get isFarmer => roles.contains('Farmer');
}
