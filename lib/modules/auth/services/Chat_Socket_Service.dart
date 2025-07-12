import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/Chat_Room_Model.dart';
import 'package:farmrole/shared/types/DB_Helper.dart';

class ChatSocketService {
  static ChatSocketService? _instance;
  factory ChatSocketService() => _instance ??= ChatSocketService._();
  ChatSocketService._();
  bool _connected = false;

  io.Socket? _socket;

  final _messageController = StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get messages => _messageController.stream;

  final _statusController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get statusUpdates => _statusController.stream;

  final _onlineStatusCtrl = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onlineStatus => _onlineStatusCtrl.stream;

  final Map<String, bool> _userOnlineMap = {};
  Map<String, bool> get userOnlineMap => _userOnlineMap;

  void connect(BuildContext context) {
    if (_connected) return;
    final token = context.read<UserProvider>().user?.token;
    if (token == null) {
      debugPrint('⚠️ Không kết nối socket vì chưa có token');
      return;
    }

    _socket = io.io(
      'https://api-ndolv2.nongdanonline.cc/chat',
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
      _socket!.emit('userOnline', {});
    });

    _socket!.on('disconnect', (_) => debugPrint('🔌 Socket disconnected'));

    _socket!.on('noti', (data) async {
      try {
        final type = data['type'];
        final d = data['data'];
        debugPrint('📥 Socket noti received: type=$type | data=$d');
        if (type == 'chatMessage') {
          final m = ChatMessage.fromJsonSafe(d);
          _messageController.add(m);
          await DBHelper().insertMessage(m);
        } else if (type == 'userStatusUpdate') {
          debugPrint('🔥 Online status received from noti: $d');
          _userOnlineMap[d['userId']] = d['online'] ?? false;
          _onlineStatusCtrl.add(d);
          _statusController.add(d);
        }
      } catch (e) {
        debugPrint('❌ Socket message parse error: $e');
      }
    });
    _socket!.onError((err) {
      debugPrint('❌ Socket error: $err');
    });
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
    debugPrint('📤 Emit chatMessage: room=$roomId | message=$message');
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

  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _connected = false;
    debugPrint('🔌 Socket service disposed');
  }
}
