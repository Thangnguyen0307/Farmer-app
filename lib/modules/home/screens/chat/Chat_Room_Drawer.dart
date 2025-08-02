import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/shared/types/Chat_Room_Model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatRoomDrawer extends StatelessWidget {
  final ChatRoom room;
  final ChatUser? other;

  const ChatRoomDrawer({super.key, required this.room, this.other});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            color: Colors.white,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: NetworkImage(
                    AuthService.getFullAvatarUrl(
                      room.mode == 'private'
                          ? other?.avatar ?? ''
                          : room.roomAvatar ?? '',
                    ),
                  ),
                  child:
                      (room.mode == 'private' && other?.avatar == null) ||
                              (room.mode != 'private' &&
                                  room.roomAvatar == null)
                          ? const Icon(Icons.person)
                          : null,
                ),
                const SizedBox(height: 12),
                Text(
                  room.mode == 'private'
                      ? other?.fullName ?? ''
                      : room.roomName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade300, height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: room.users.length + 1,
              separatorBuilder: (_, __) => Divider(color: Colors.grey.shade200),
              itemBuilder: (ctx, i) {
                if (i == 0) {
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Thành viên',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }
                final u = room.users[i - 1];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  onTap: () {
                    context.push('/profile/${u.userId}');
                  },
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        u.avatar != null
                            ? NetworkImage(
                              AuthService.getFullAvatarUrl(u.avatar!),
                            )
                            : null,
                  ),
                  title: Text(
                    u.fullName,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  trailing: Image.asset(
                    u.online
                        ? 'lib/assets/icon/Onl.png'
                        : 'lib/assets/icon/Off.png',
                    width: 25,
                    height: 25,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
