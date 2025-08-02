import 'dart:convert';

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
  final String mode;
  final List<ChatUser> users;
  final String? lastMessage;
  final bool hasNewMessage;
  int unreadCount;
  bool hasJoin;
  ChatRoom({
    required this.roomId,
    required this.roomName,
    this.roomAvatar,
    required this.mode,
    required this.users,
    this.lastMessage,
    this.hasNewMessage = false,
    this.unreadCount = 0,
    this.hasJoin = false,
  });
  Map<String, dynamic> toMap() => {
    'roomId': roomId,
    'roomName': roomName,
    'roomAvatar': roomAvatar,
    'mode': mode,
    'unreadCount': unreadCount,
    'hasNewMessage': hasNewMessage ? 1 : 0,
    'users': jsonEncode(
      users
          .map(
            (e) => {
              'userId': e.userId,
              'fullName': e.fullName,
              'avatar': e.avatar,
              'online': e.online,
            },
          )
          .toList(),
    ),
    'hasJoin': hasJoin ? 1 : 0,
  };

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    List<ChatUser> users = [];
    final usersStr = map['users'];
    if (usersStr != null && usersStr is String && usersStr.isNotEmpty) {
      final List decoded = jsonDecode(usersStr);
      users =
          decoded.map((u) {
            return ChatUser(
              userId: u['userId'],
              fullName: u['fullName'],
              avatar: u['avatar'],
              online: u['online'] ?? false,
            );
          }).toList();
    }

    return ChatRoom(
      roomId: map['roomId'],
      roomName: map['roomName'],
      roomAvatar: map['roomAvatar'],
      mode: map['mode'],
      unreadCount: map['unreadCount'] ?? 0,
      hasNewMessage: (map['hasNewMessage'] ?? 0) == 1,
      users: users,
      hasJoin: (map['hasJoin'] ?? 0) == 1,
    );
  }

  //json roompublic
  factory ChatRoom.fromPublicJson(Map<String, dynamic> json) {
    return ChatRoom(
      roomId: json['roomId'] ?? json['_id'] ?? '',
      roomName: json['roomName'] ?? 'Room',
      roomAvatar: json['roomAvatar'],
      mode: 'public',
      users: [],
      hasJoin: false,
    );
  }

  factory ChatRoom.fromJsonSafe(
    Map<String, dynamic> json, {
    String? currentUserId,
    int? oldUnreadCount,
  }) {
    try {
      final usersJson = (json['users'] as List?) ?? [];
      final users =
          usersJson.map((u) {
            return ChatUser(
              userId: u['userId'] ?? '',
              fullName: u['fullName'] ?? 'Không tên',
              avatar: u['avatar'],
              online: u['online'] ?? false,
            );
          }).toList();

      String roomName = json['roomName'] ?? 'Room';

      if ((json['mode'] ?? 'public') == 'private' &&
          users.length == 2 &&
          currentUserId != null) {
        final other = users.firstWhere((u) => u.userId != currentUserId);
        roomName = other.fullName;
      }

      return ChatRoom(
        roomId: json['roomId'] ?? '',
        roomName: roomName,
        roomAvatar: json['roomAvatar'],
        mode: json['mode'] ?? 'private',
        users: users,
        unreadCount: json['unreadCount'] ?? oldUnreadCount ?? 0,
      );
    } catch (e) {
      throw Exception('Lỗi tạo ChatRoom từ JSON: $e');
    }
  }

  ChatRoom copyWith({
    String? roomId,
    String? roomName,
    String? roomAvatar,
    String? mode,
    List<ChatUser>? users,
    String? lastMessage,
    bool? hasNewMessage,
    int? unreadCount,
  }) {
    return ChatRoom(
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      roomAvatar: roomAvatar ?? this.roomAvatar,
      mode: mode ?? this.mode,
      users: users ?? this.users,
      lastMessage: lastMessage ?? this.lastMessage,
      hasNewMessage: hasNewMessage ?? this.hasNewMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class ChatRoomWithLastMessage {
  final ChatRoom room;
  final ChatMessage? lastMessage;

  ChatRoomWithLastMessage({required this.room, this.lastMessage});
}

// lib/models/chat_message.dart
class ChatMessage {
  final String clientId;
  final String? id;
  final String roomId;
  final String userId;
  final String fullName;
  final String? avatar;
  final String? message;
  final String? imageUrl;
  final DateTime createdAt;

  ChatMessage({
    required this.clientId,
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
    clientId: m['clientId'],
    id: m['id'],
    roomId: m['roomId'],
    userId: m['userId'],
    fullName: m['fullName'],
    avatar: m['avatar'],
    message: m['message'],
    imageUrl: m['imageUrl'],
    createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
  );

  factory ChatMessage.fromJsonSafe(
    Map<String, dynamic> json, {
    String? roomIdOverride,
  }) {
    try {
      final createdStr = json['timestamp'] ?? json['createdAt'];
      if (createdStr == null || createdStr == 'null') {
        throw Exception('createdAt/timestamp bị null');
      }
      final created = DateTime.tryParse(createdStr);
      if (created == null) {
        throw Exception('createdAt không parse được: $createdStr');
      }
      final clientId =
          json['clientId'] ??
          '${created.microsecondsSinceEpoch}_${json['userId'] ?? 'unknown'}';
      final id = json['_id']?.toString();

      return ChatMessage(
        clientId: clientId,
        id: id,
        roomId: roomIdOverride ?? json['roomId'] ?? '',
        userId: json['userId'] ?? '',
        fullName: json['fullName'] ?? 'Không tên',
        avatar: json['avatar'] is String ? json['avatar'] : null,
        message: json['message'] is String ? json['message'] : null,
        imageUrl: json['imageUrl'] is String ? json['imageUrl'] : null,
        createdAt: created,
      );
    } catch (e) {
      throw Exception('Lỗi tạo ChatMessage từ JSON: $e');
    }
  }

  // Chuyển về Map để insert
  Map<String, dynamic> toMap() => {
    'clientId': clientId,
    'id': id,
    'roomId': roomId,
    'userId': userId,
    'fullName': fullName,
    'avatar': avatar,
    'message': message,
    'imageUrl': imageUrl,
    'createdAt': createdAt.toIso8601String(),
  };
}

extension ChatRoomWithLastMessageExt on ChatRoomWithLastMessage {
  ChatRoomWithLastMessage copyWithUnread(int unread) {
    return ChatRoomWithLastMessage(
      room: room.copyWith(unreadCount: unread),
      lastMessage: lastMessage,
    );
  }
}
