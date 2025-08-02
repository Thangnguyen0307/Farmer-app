import 'dart:async';
import 'package:farmrole/modules/auth/services/Chat_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/Chat_Room_Model.dart';
import 'package:farmrole/shared/types/DB_Helper.dart';
import 'package:flutter/material.dart';
import 'package:farmrole/modules/auth/services/Chat_Socket_Service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ChatPrivateButton extends StatefulWidget {
  final String targetUserId;
  final String targetFullName;

  const ChatPrivateButton({
    super.key,
    required this.targetUserId,
    required this.targetFullName,
  });

  @override
  State<ChatPrivateButton> createState() => _ChatPrivateButtonState();
}

class _ChatPrivateButtonState extends State<ChatPrivateButton> {
  StreamSubscription? _roomReadySub;
  bool _isWaiting = false;
  Timer? _timeoutTimer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
  }

  Future<ChatRoom?> findPrivateRoomWith(String userId) async {
    // Lấy danh sách các room từ local
    final rooms = await DBHelper().getAllRooms();
    final currentUserId = context.read<UserProvider>().user?.id;
    if (currentUserId == null) return null;
    for (final room in rooms) {
      final isPrivate = room.mode == 'private';
      final hasTargetUser = room.users.any((user) => user.userId == userId);
      final hasCurrentUser = room.users.any(
        (user) => user.userId == currentUserId,
      );

      final isOnly2Users = room.users.length == 2;
      if (isPrivate && isOnly2Users && hasTargetUser && hasCurrentUser) {
        return room;
      }
    }
    return null;
  }

  void _onPressChat() async {
    if (_isNavigating) return;

    setState(() => _isWaiting = true);

    final existingRoom = await findPrivateRoomWith(widget.targetUserId);

    if (!mounted) return;

    if (existingRoom != null) {
      setState(() {
        _isWaiting = false;
        _isNavigating = true;
      });
      await context.push('/chat/room/${existingRoom.roomId}');
      if (mounted) setState(() => _isNavigating = false);
    } else {
      _startPrivateChat();
    }
  }

  void _startPrivateChat() {
    setState(() => _isWaiting = true);
    final currentUserId = context.read<UserProvider>().user!.id;
    ChatSocketService().startPrivateChat(
      targetUserId: widget.targetUserId,
      targetFullName: widget.targetFullName,
      onRoomReady: (room) async {
        final token = context.read<UserProvider>().user?.token;
        final currentUserId = context.read<UserProvider>().user!.id;

        ChatRoom fixedRoom = room;

        if (room.users.isEmpty) {
          final fetched = await ChatService().getRoomInfo(
            token: token,
            roomId: room.roomId,
          );
          if (fetched != null) {
            fixedRoom = fetched;
            debugPrint('📦 Đã gọi API để lấy room đầy đủ: ${fixedRoom.roomId}');
          }
        }

        final exist = await DBHelper().getRoomById(
          fixedRoom.roomId,
          currentUserId,
        );
        if (exist == null) {
          await DBHelper().insertRoom(fixedRoom, currentUserId);
          await DBHelper().setRoomHasJoin(fixedRoom.roomId, currentUserId);
          debugPrint('📦 Đã insert room vào DB: ${fixedRoom.roomId}');
        }

        final hasMessages = await DBHelper().hasMessages(fixedRoom.roomId);
        if (!hasMessages) {
          ChatSocketService().loadOldMessages(fixedRoom.roomId);
        }

        if (!mounted) return;
        setState(() {
          _isWaiting = false;
          _isNavigating = true;
        });

        await context.push('/chat/room/${fixedRoom.roomId}');

        if (mounted) {
          setState(() => _isNavigating = false);
        }
      },
    );

    _timeoutTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isWaiting = false);
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _roomReadySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isWaiting
        ? const CircularProgressIndicator()
        : TextButton.icon(
          onPressed: _onPressChat,
          icon: Image.asset(
            'lib/assets/icon/chat2_Line.png', // thay đường dẫn bằng ảnh thật của bạn
            width: 30,
            height: 30,
            color:
                Colors
                    .grey, // nếu ảnh là ảnh SVG hoặc PNG 1 màu, có thể tô lại màu
          ),
          label: const Text(
            'Nhắn tin',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        );
  }
}
