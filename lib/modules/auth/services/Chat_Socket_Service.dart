import 'dart:async';
import 'package:farmrole/app/router.dart';
import 'package:farmrole/env/env.dart';
import 'package:farmrole/modules/auth/state/Chat_Notifier.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:farmrole/shared/types/Chat_Room_Model.dart';
import 'package:farmrole/shared/types/DB_Helper.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatSocketService {
  static ChatSocketService? _instance;
  factory ChatSocketService() => _instance ??= ChatSocketService._();
  ChatSocketService._();

  bool _connected = false;
  io.Socket? _socket;

  String? currentRoomId;
  bool needReloadRooms = false;

  final _messageController = StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get messages => _messageController.stream;

  final _statusController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get statusUpdates => _statusController.stream;

  final _onlineStatusCtrl = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onlineStatus => _onlineStatusCtrl.stream;

  final _roomReadyController = StreamController<ChatRoom>.broadcast();
  Stream<ChatRoom> get roomReady => _roomReadyController.stream;

  final Map<String, bool> _userOnlineMap = {};
  Map<String, bool> get userOnlineMap => _userOnlineMap;
  String? _myUserId;
  Function(String roomId)? _reloadMessagesCallback;
  final Set<String> _joinedRooms = {};
  StreamSubscription? _privateChatSub;

  Function(ChatRoom)? _onRoomReadyCallback;

  //lay title trong text ma backend trả
  String extractTitle(String text) {
    final regex = RegExp(r'"(.*?)"');
    final match = regex.firstMatch(text);
    return match != null ? match.group(1)! : '';
  }

  //cap nhat tong unread mess
  Function()? onUnreadChanged;
  ChatNotifier? _notifier;

  final String _baseUrl = Environment.config.baseUrl;

  void setNotifier(ChatNotifier notifier) {
    _notifier = notifier;
  }

  void registerReloadMessages(Function(String roomId) callback) {
    _reloadMessagesCallback = callback;
  }

  void connect({required String token, required String userId}) {
    _myUserId = userId;
    if (_connected) return;

    _socket = io.io(
      '$_baseUrl/chat',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableForceNew()
          .build(),
    );

    _socket!.onConnect((_) {
      _connected = true;
      debugPrint('✅ Socket connected');
      _socket!.emit('bulkJoinRooms');
    });

    _socket!.on('disconnect', (_) {
      _connected = false;
      debugPrint('🔌 Socket disconnected');
    });

    _socket!.on('noti', (data) async {
      try {
        final type = data['type'];
        final d = data['data'];

        debugPrint('📥 Socket noti received: type=$type | data=$d');
        if (type == 'error') {
          final text = d['text'];
          final roomId = d['roomId'];
          debugPrint('🔴 Lỗi từ socket: $text | roomId=${roomId ?? 'null'}');
          if (text == 'Phòng không tồn tại') {
            if (roomId != null) {
              await DBHelper().deleteRoom(roomId);
              debugPrint('🗑️ Đã xoá phòng không tồn tại: $roomId');
            }
          }
        }

        if (type == 'joinedRooms') {
          final List rooms = d['rooms'] ?? [];
          _joinedRooms.clear();
          for (final room in rooms) {
            _joinedRooms.add(room['roomId']);
            final chatRoom = ChatRoom.fromJsonSafe(room, currentUserId: userId);
            chatRoom.hasJoin = true;
            //cap nhat room neu local chua co
            final exist = await DBHelper().getRoomById(chatRoom.roomId, userId);
            final oldUnread = exist?.unreadCount ?? 0;
            chatRoom.unreadCount = oldUnread;
            if (exist == null) {
              await DBHelper().insertRoom(chatRoom, userId);
              await DBHelper().setRoomHasJoin(chatRoom.roomId, userId);
            } else {
              await DBHelper().updateRoom(chatRoom, userId);
              if (exist.hasJoin != true) {
                await DBHelper().setRoomHasJoin(chatRoom.roomId, userId);
              }
            }
            //cap nhat trang thai khi joinroom
            for (final user in chatRoom.users) {
              _userOnlineMap[user.userId] = user.online ?? false;
            }
          }
          await _loadAllMessagesSince();
        }

        if (type == 'chatMessage') {
          final m = ChatMessage.fromJsonSafe(d);
          _messageController.add(m);
          await DBHelper().insertMessage(m);
          if (m.roomId == currentRoomId) {
            debugPrint('👁️ In current room → resetUnread');
            await DBHelper().resetUnread(m.roomId);
          } else {
            debugPrint('🔕 Not in current room → increaseUnread');
            await DBHelper().increaseUnread(m.roomId);
            _notifier?.fetchTotalUnread(userId);
          }
        }

        if (type == 'userStatusUpdate') {
          debugPrint('🔥 Online status received from noti: $d');
          _userOnlineMap[d['userId']] = d['online'] ?? false;
          //onlstaCrl để cap nhật trạng thái online trong initstate mỗi khi có userStatusUpdate
          _onlineStatusCtrl.add(d);
          _statusController.add(d);
        }

        if (type == 'roomReady') {
          final room = ChatRoom.fromJsonSafe(d, currentUserId: userId);
          _roomReadyController.add(room);
          final exist = await DBHelper().getRoomById(room.roomId, userId);

          if (exist == null) {
            await DBHelper().setRoomHasJoin(room.roomId, userId);
            debugPrint('📦 Đã thêm roomReady vào DB local: ${room.roomId}');
          }

          final hasMessages = await DBHelper().hasMessages(room.roomId);
          if (!hasMessages) {
            _socket?.emit('loadMessagesSince', {'roomId': room.roomId});
            debugPrint('📥 Load messages for roomReady: ${room.roomId}');
          }
        }

        if (type == 'oldMessages') {
          final List list = d as List;
          for (final item in list) {
            final m = ChatMessage.fromJsonSafe(item);
            _messageController.add(m);
            await DBHelper().insertMessage(m);
          }
        }

        if (type == 'unreadMessage') {
          final roomId = d['roomId'];
          final List messages = d['messages'] ?? [];
          final int total = d['total'] ?? messages.length;
          debugPrint('🔔 ĐÃ NHẬN UNREAD MESSAGE: $d');
          for (final item in messages) {
            final m = ChatMessage.fromJsonSafe(item, roomIdOverride: roomId);
            await DBHelper().insertMessage(m);
            _messageController.add(m);
          }
          if (total > 0) {
            await DBHelper().setUnread(roomId, total);
            onUnreadChanged?.call();
          }
          _reloadMessagesCallback?.call(roomId);
        }
        if (type == 'filter-popup') {
          final reason = d['text'] ?? 'Tin nhắn không được chấp nhận.';
          debugPrint('🚫 Tin nhắn bị lọc: $reason');
          if (navigatorKey.currentContext != null) {
            showDialog(
              context: navigatorKey.currentContext!,
              builder:
                  (ctx) => AlertDialog(
                    title: const Text('Tin nhắn bị chặn'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(reason),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _launchTermsUrl,
                          child: const Text(
                            'Vui lòng xem chính sách cộng đồng',
                            style: TextStyle(
                              color: Color.fromARGB(255, 5, 207, 120),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
            );
          }
        }
        if (type == 'videoPublic') {
          final videoId = d['videoId'];
          final text = d['text'];
          final title = extractTitle(text);
          final note = 'Video $title của bạn đã được duyệt';
          await DBHelper().insertNotification(
            videoId: videoId,
            title: title,
            note: note,
          );
        }
        if (type == 'videoUploaded') {
          final videoId = d['videoId'];
          final text = d['text'];
          final title = extractTitle(text);
          final note = 'Video $title đã được tải lên và đang chờ xử lý.';
          await DBHelper().insertNotification(
            videoId: videoId,
            title: title,
            note: note,
          );
        }
      } catch (e) {
        debugPrint('❌ Socket message parse error: $e');
      }
    });

    _socket!.onError((err) {
      debugPrint('❌ Socket error: $err');
    });
  }

  //load message khi off
  Future<void> _loadAllMessagesSince() async {
    final localRooms = await DBHelper().getAllRooms();
    final localRoomIds = localRooms.map((r) => r.roomId).toSet();

    final Set<String> allRooms = {..._joinedRooms, ...localRoomIds};

    for (final roomId in allRooms) {
      String? lastId;
      if (localRoomIds.contains(roomId)) {
        final lastMsg = await DBHelper().getLastMessage(roomId);
        lastId = lastMsg?.id;
      }

      final payload = {'roomId': roomId};
      if (lastId != null && lastId.isNotEmpty) {
        payload['lastId'] = lastId;
      }

      _socket?.emit('loadMessagesSince', payload);
      debugPrint(
        '🔍 loadMessagesSince: room=$roomId | lastId=${lastId ?? 'null'}',
      );
    }
  }

  //dung de nhan biet room (truyen vao id room hoac null khi thoat)
  Future<void> enterRoom(String? roomId) async {
    currentRoomId = roomId;
    return;
  }

  void sendMessage({
    required String roomId,
    required String message,
    String? imageUrl,
    required String userId,
    required String fullName,
    String? avatar,
  }) {
    final now = DateTime.now().toIso8601String();
    debugPrint('📤 chatMessage: room=$roomId | message=$message');
    _socket?.emit('chatMessage', {
      'roomId': roomId,
      'userId': userId,
      'fullName': fullName,
      'avatar': avatar,
      'message': message,
      'imageUrl': imageUrl,
      'createdAt': now,
    });
  }

  //load message cũ
  Future<void> loadOldMessages(String roomId, {String? lastId}) async {
    _socket?.emit('loadOldMessages', {'roomId': roomId, 'lastId': lastId});
    debugPrint('🔄 loadOldMessages: room=$roomId | lastId=$lastId');
    return;
  }

  //join room 1 1
  void startPrivateChat({
    required String targetUserId,
    String? targetFullName,
    required Function(ChatRoom) onRoomReady,
  }) {
    debugPrint('📤 startPrivateChat: target=$targetUserId');
    // Lắng nghe luôn
    listenPrivateChat((room) {
      clearPrivateChatListener();
      onRoomReady(room);
    });
    _socket?.emit('startPrivateChat', {
      'targetUserId': targetUserId,
      if (targetFullName != null) 'targetFullName': targetFullName,
    });
  }

  void disposePrivateChatListener() {
    _privateChatSub?.cancel();
    _privateChatSub = null;
  }

  void listenPrivateChat(Function(ChatRoom) onRoomReady) {
    _onRoomReadyCallback = onRoomReady;
    _privateChatSub?.cancel();
    _privateChatSub = _roomReadyController.stream.listen((room) {
      if (_onRoomReadyCallback != null) {
        _onRoomReadyCallback!(room);
      }
    });
  }

  void clearPrivateChatListener() {
    _onRoomReadyCallback = null;
  }

  //-----join room
  Future<void> joinRoom(String roomId, String userId) async {
    _myUserId = userId;
    if (!_connected) {
      debugPrint('⚠️ Socket chưa connect, không thể join room');
      return;
    }
    debugPrint('📤requestJoinRoom: roomId=$roomId');
    _socket?.emit('requestJoinRoom', {roomId});
    await DBHelper().setRoomHasJoin(roomId, userId);
    _joinedRooms.add(roomId);
  }

  //hàm link chính sách
  void _launchTermsUrl() async {
    final uri = Uri.parse('https://webadmin-dev.vercel.app/chinh-sach/bao-mat');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $uri';
    }
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _connected = false;
    debugPrint('🔌 Socket service disposed');
  }
}
