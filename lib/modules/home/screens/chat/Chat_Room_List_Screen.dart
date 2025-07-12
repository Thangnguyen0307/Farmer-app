import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/services/Chat_Service.dart';
import 'package:farmrole/shared/types/Chat_Room_Model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatRoomListScreen extends StatefulWidget {
  @override
  _ChatRoomListScreenState createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends State<ChatRoomListScreen> {
  late Future<List<ChatRoom>> _roomsFut;

  @override
  void initState() {
    super.initState();
    _roomsFut = ChatService.getMyRooms(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phòng chat')),
      body: FutureBuilder<List<ChatRoom>>(
        future: _roomsFut,
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done)
            return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Lỗi: ${snap.error}'));
          final rooms = snap.data!;
          return ListView.separated(
            itemCount: rooms.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final r = rooms[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      r.roomAvatar != null && r.roomAvatar!.isNotEmpty
                          ? NetworkImage(
                            AuthService.getFullAvatarUrl(r.roomAvatar!),
                          )
                          : null,
                  child:
                      r.roomAvatar == null || r.roomAvatar!.isEmpty
                          ? const Icon(Icons.chat)
                          : null,
                ),
                title: Text(r.roomName),
                subtitle: Text(
                  r.mode == 'public' ? 'Public Room' : 'Private Chat',
                ),
                onTap: () {
                  context.push('/chat/room/${r.roomId}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
