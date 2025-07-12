import 'dart:async';

import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:flutter/material.dart';
import 'package:farmrole/modules/auth/services/Chat_Service.dart';
import 'package:farmrole/modules/auth/services/Chat_Socket_Service.dart';
import 'package:farmrole/shared/types/Chat_Room_Model.dart';
import 'package:farmrole/shared/types/DB_Helper.dart';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  const ChatRoomScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late Future<ChatRoom> _roomFuture;
  final List<ChatMessage> _messages = [];

  final _scrollCtrl = ScrollController();
  final _inputCtrl = TextEditingController();

  final _socketSvc = ChatSocketService();
  StreamSubscription<ChatMessage>? _messageSub;

  //Ktra trùng tn
  bool _containsMessage(ChatMessage msg) {
    return _messages.any(
      (m) =>
          m.id != null && m.id == msg.id ||
          (m.message == msg.message && m.createdAt == msg.createdAt),
    );
  }

  @override
  void initState() {
    super.initState();

    // 1) Load room info từ local hoặc từ API
    _roomFuture = _loadRoom(widget.roomId);

    // 2) Lắng nghe tin nhắn socket realtime
    _messageSub = _socketSvc.messages.listen((msg) async {
      if (msg.roomId == widget.roomId) {
        await DBHelper().insertMessage(msg);
        if (mounted) {
          if (!_containsMessage(msg)) {
            setState(() => _messages.add(msg));
          }
          _scrollToBottom();
        }
      }
    });

    // 3) Load tin nhắn lịch sử từ SQLite
    DBHelper().getMessages(widget.roomId).then((localMsgs) {
      if (mounted) {
        setState(() => _messages.addAll(localMsgs));
      }
    });
  }

  Future<ChatRoom> _loadRoom(String roomId) async {
    final localRoom = await DBHelper().getRoomById(roomId);
    if (localRoom != null) return localRoom;

    final rooms = await ChatService.getMyRooms(context);
    final matchedRoom = rooms.firstWhere((r) => r.roomId == roomId);
    await DBHelper().insertRoom(matchedRoom);
    return matchedRoom;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    _socketSvc.sendMessage(roomId: widget.roomId, message: text);
    _inputCtrl.clear();
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChatRoom>(
      future: _roomFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final room = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: Text(room.roomName)),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  itemCount: _messages.length,
                  itemBuilder: (_, i) {
                    final m = _messages[i];
                    return ListTile(
                      leading:
                          m.avatar != null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      AuthService.getFullAvatarUrl(m.avatar!)),
                                )
                              : null,
                      title: Text(m.fullName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (m.message != null) Text(m.message!),
                          if (m.imageUrl != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Image.network(m.imageUrl!),
                            ),
                        ],
                      ),
                      trailing: Text(
                        '${m.createdAt.hour}:${m.createdAt.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.send), onPressed: _send),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
