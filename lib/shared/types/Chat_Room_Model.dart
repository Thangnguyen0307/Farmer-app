// lib/shared/models/chat_models.dart

class ChatUser {
  final String userId;
  final String fullName;
  final String? avatar;
  bool online;
  ChatUser({
    required this.userId,
    required this.fullName,
    this.avatar,
    this.online = false,
  });
}

class ChatRoom {
  final String roomId;
  final String roomName;
  final String? roomAvatar;
  final String mode; // "public" hoặc "private"
  final List<ChatUser> users;
  ChatRoom({
    required this.roomId,
    required this.roomName,
    this.roomAvatar,
    required this.mode,
    required this.users,
  });
  Map<String, dynamic> toMap() => {
    'roomId': roomId,
    'roomName': roomName,
    'roomAvatar': roomAvatar,
    'mode': mode,
  };

  factory ChatRoom.fromMap(Map<String, dynamic> map) => ChatRoom(
    roomId: map['roomId'],
    roomName: map['roomName'],
    roomAvatar: map['roomAvatar'],
    mode: map['mode'],
    users: [], // nếu muốn lưu users, cần thêm bảng phụ
  );
}

// lib/models/chat_message.dart
class ChatMessage {
  final int? id;
  final String roomId;
  final String userId;
  final String fullName;
  final String? avatar;
  final String? message;
  final String? imageUrl;
  final DateTime createdAt;

  ChatMessage({
    this.id,
    required this.roomId,
    required this.userId,
    required this.fullName,
    this.avatar,
    this.message,
    this.imageUrl,
    required this.createdAt,
  });

  // Tạo từ Map (DB)
  factory ChatMessage.fromMap(Map<String, dynamic> m) => ChatMessage(
    id: m['id'],
    roomId: m['roomId'],
    userId: m['userId'],
    fullName: m['fullName'],
    avatar: m['avatar'],
    message: m['message'],
    imageUrl: m['imageUrl'],
    createdAt: DateTime.parse(m['createdAt']),
  );

  factory ChatMessage.fromJsonSafe(Map<String, dynamic> json) {
    try {
      return ChatMessage(
        id: json['id'] ?? 0,
        roomId: json['roomId'] ?? '',
        userId: json['userId'] ?? '',
        fullName: json['fullName'] ?? 'Không tên',
        avatar: json['avatar'] is String ? json['avatar'] : null,
        message: json['message'] is String ? json['message'] : null,
        imageUrl: json['imageUrl'] is String ? json['imageUrl'] : null,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      throw Exception('Lỗi tạo ChatMessage từ JSON: $e');
    }
  }

  // Chuyển về Map để insert
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'roomId': roomId,
    'userId': userId,
    'fullName': fullName,
    'avatar': avatar,
    'message': message,
    'imageUrl': imageUrl,
    'createdAt': createdAt.toIso8601String(),
  };
}
