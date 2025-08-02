import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/shared/types/Chat_Room_Model.dart';
import 'package:flutter/material.dart';

class ChatRoomTile extends StatelessWidget {
  final ChatRoomWithLastMessage roomData;
  final Color primaryColor;
  final String currentUserId;
  final bool isPrivate;
  final VoidCallback onTap;

  const ChatRoomTile({
    super.key,
    required this.roomData,
    required this.primaryColor,
    required this.currentUserId,
    required this.isPrivate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final room = roomData.room;
    final lastMsg = roomData.lastMessage?.message ?? '';
    final lastTime = roomData.lastMessage?.createdAt;
    final timeText =
        lastTime != null
            ? '${lastTime.hour.toString().padLeft(2, '0')}:${lastTime.minute.toString().padLeft(2, '0')}'
            : '';

    /// Xử lý hiển thị avatar / tên phòng
    String displayName = room.roomName;
    String? avatarUrl;

    if (isPrivate && room.users.length > 1) {
      final other = room.users.firstWhere(
        (u) => u.userId != currentUserId,
        orElse: () => room.users.first, // fallback nếu API có bug
      );
      displayName = other.fullName;
      avatarUrl =
          (other.avatar != null && other.avatar!.isNotEmpty)
              ? AuthService.getFullAvatarUrl(other.avatar!)
              : null;
    } else {
      avatarUrl =
          (room.roomAvatar != null && room.roomAvatar!.isNotEmpty)
              ? AuthService.getFullAvatarUrl(room.roomAvatar!)
              : null;
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child:
                  avatarUrl == null
                      ? Icon(Icons.person, color: primaryColor, size: 20)
                      : null,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          room.hasNewMessage
                              ? FontWeight.bold
                              : FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMsg,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight:
                          room.hasNewMessage
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    if (timeText.isNotEmpty)
                      Text(
                        timeText,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight:
                              room.hasNewMessage
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    if (room.unreadCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
