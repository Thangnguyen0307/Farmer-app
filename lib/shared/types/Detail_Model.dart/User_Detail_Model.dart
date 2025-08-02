// class UserDetailModel {
//   final String id;
//   final String fullName;
//   final String email;
//   final String avatar;
//   final List<String> role;
//   final bool isActive;
//   final String note;
//   final String phone;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final DateTime? lastLogin;
//   final List<UserFarmModel> farms;
//   final List<UserVideoModel> videos;

//   UserDetailModel({
//     required this.id,
//     required this.fullName,
//     required this.email,
//     required this.avatar,
//     required this.role,
//     required this.isActive,
//     required this.note,
//     required this.phone,
//     required this.createdAt,
//     required this.updatedAt,
//     this.lastLogin,
//     required this.farms,
//     required this.videos,
//   });

//   factory UserDetailModel.fromJson(Map<String, dynamic> json) {
//     return UserDetailModel(
//       id: json['user']['id'],
//       fullName: json['user']['fullName'],
//       email: json['user']['email'],
//       avatar: json['user']['avatar'],
//       role: List<String>.from(json['user']['role']),
//       isActive: json['user']['isActive'],
//       note: json['user']['note'] ?? '',
//       phone: json['user']['phone'] ?? '',
//       createdAt: DateTime.parse(json['user']['createdAt']),
//       updatedAt: DateTime.parse(json['user']['updatedAt']),
//       lastLogin:
//           json['user']['lastLogin'] != null
//               ? DateTime.tryParse(json['user']['lastLogin'])
//               : null,
//       farms:
//           (json['farms'] as List)
//               .map((e) => UserFarmModel.fromJson(e))
//               .toList(),
//       videos:
//           (json['videos'] as List)
//               .map((e) => UserVideoModel.fromJson(e))
//               .toList(),
//     );
//   }
// }

// class UserFarmModel {
//   final String id;
//   final String code;
//   final String name;
//   final String location;
//   final String province;
//   final String district;
//   final String ward;
//   final String street;
//   final double area;
//   final double cultivatedArea;
//   final bool isAvailable;
//   final String status;
//   final DateTime createdAt;

//   UserFarmModel({
//     required this.id,
//     required this.code,
//     required this.name,
//     required this.location,
//     required this.province,
//     required this.district,
//     required this.ward,
//     required this.street,
//     required this.area,
//     required this.cultivatedArea,
//     required this.isAvailable,
//     required this.status,
//     required this.createdAt,
//   });

//   factory UserFarmModel.fromJson(Map<String, dynamic> json) {
//     return UserFarmModel(
//       id: json['id'],
//       code: json['code'],
//       name: json['name'],
//       location: json['location'],
//       province: json['province'],
//       district: json['district'],
//       ward: json['ward'],
//       street: json['street'],
//       area: (json['area'] as num).toDouble(),
//       cultivatedArea: (json['cultivatedArea'] as num).toDouble(),
//       isAvailable: json['isAvailable'],
//       status: json['status'],
//       createdAt: DateTime.parse(json['createdAt']),
//     );
//   }
// }

// class UserVideoModel {
//   final String id;
//   final String title;
//   final String youtubeLink;
//   final String localFilePath;
//   final String playlistId;
//   final String playlistName;
//   final String farmId;
//   final String uploadedBy;
//   final String thumbnailPath;
//   final String status;
//   final DateTime createdAt;

//   UserVideoModel({
//     required this.id,
//     required this.title,
//     required this.youtubeLink,
//     required this.localFilePath,
//     required this.playlistId,
//     required this.playlistName,
//     required this.farmId,
//     required this.uploadedBy,
//     required this.thumbnailPath,
//     required this.status,
//     required this.createdAt,
//   });

//   factory UserVideoModel.fromJson(Map<String, dynamic> json) {
//     return UserVideoModel(
//       id: json['_id'],
//       title: json['title'],
//       youtubeLink: json['youtubeLink'],
//       localFilePath: json['localFilePath'],
//       playlistId: json['playlistId'],
//       playlistName: json['playlistName'],
//       farmId: json['farmId'],
//       uploadedBy: json['uploadedBy'],
//       thumbnailPath: json['thumbnailPath'],
//       status: json['status'],
//       createdAt: DateTime.parse(json['createdAt']),
//     );
//   }
// }
