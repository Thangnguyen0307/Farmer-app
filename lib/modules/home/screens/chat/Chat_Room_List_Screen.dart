import 'dart:async';
import 'package:intl/intl.dart';
import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/services/Chat_Socket_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/Chat_Room_Model.dart';
import 'package:farmrole/shared/types/DB_Helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ChatRoomListScreen extends StatefulWidget {
  @override
  State<ChatRoomListScreen> createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends State<ChatRoomListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StreamSubscription _messageSub;
  late List<ChatRoomWithLastMessage> _rooms = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRooms();
    ChatSocketService().registerReloadMessages((roomId) {
      _loadRooms();
    });

    _messageSub = ChatSocketService().messages.listen((msg) async {
      final currentRoomId = ChatSocketService().currentRoomId;

      // if (msg.roomId == currentRoomId) {
      //   print('👁️ In current room → resetUnread');
      //   await DBHelper().resetUnread(msg.roomId);
      // } else {
      //   print('🔕 Not in current room → increaseUnread');
      //   await DBHelper().increaseUnread(msg.roomId);
      //   ChatSocketService().needReloadRooms = true;
      // }
      print('[Socket] CurrentRoomId: ${ChatSocketService().currentRoomId}');
      print('[Socket] Message from roomId: ${msg.roomId}');
      final index = _rooms.indexWhere((r) => r.room.roomId == msg.roomId);
      if (index >= 0) {
        final oldRoom = _rooms[index];
        _rooms.removeAt(index);
        _rooms.insert(
          0,
          ChatRoomWithLastMessage(
            room: oldRoom.room.copyWith(
              unreadCount:
                  oldRoom.room.roomId == currentRoomId
                      ? 0
                      : oldRoom.room.unreadCount + 1,
            ),
            lastMessage: msg,
          ),
        );
      }
      setState(() {});
    });
  }

  Future<void> _loadRooms() async {
    final fetched = await _fetchRoomsWithLastMessage();
    if (!mounted) return;
    setState(() {
      _rooms = fetched;
    });
    _sortRooms();
  }

  Future<List<ChatRoomWithLastMessage>> _fetchRoomsWithLastMessage() async {
    final userId = context.read<UserProvider>().user!.id;
    final db = DBHelper();
    final dbRooms = await db.getRoomsByUser(userId);
    final lastMessagesMap = await db.getLastMessagesForAllRooms();
    for (final r in dbRooms) {
      print("📦 Room ${r.roomName}, hasJoin: ${r.hasJoin}");
    }
    return dbRooms.map((room) {
      final lastMessage = lastMessagesMap[room.roomId];
      return ChatRoomWithLastMessage(room: room, lastMessage: lastMessage);
    }).toList();
  }

  void _sortRooms() {
    _rooms.sort((a, b) {
      final aHasJoin = a.room.hasJoin == true;
      final bHasJoin = b.room.hasJoin == true;

      // Ưu tiên phòng đã join
      if (aHasJoin && !bHasJoin) return -1;
      if (!aHasJoin && bHasJoin) return 1;

      final aTime =
          a.lastMessage?.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime =
          b.lastMessage?.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
  }

  @override
  void dispose() {
    _messageSub.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final publicRooms = _rooms.where((r) => r.room.mode == 'public').toList();
    final privateRooms = _rooms.where((r) => r.room.mode == 'private').toList();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: theme.colorScheme.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 4),
            const Text(
              'Nhắn tin',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
            ),
          ],
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
              tabs: const [Tab(text: 'Bạn bè'), Tab(text: 'Cộng đồng')],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRoomList(privateRooms, primaryColor, isPrivate: true),
          _buildRoomList(publicRooms, primaryColor),
        ],
      ),
    );
  }

  Widget _buildRoomList(
    List<ChatRoomWithLastMessage> rooms,
    Color primaryColor, {
    bool isPrivate = false,
  }) {
    final currentUserId = context.read<UserProvider>().user!.id;

    if (rooms.isEmpty) {
      return const Center(child: Text('Không có phòng nào.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: rooms.length,
      separatorBuilder:
          (_, __) => Divider(color: Colors.grey.shade300, height: 1),
      itemBuilder: (_, i) {
        final ChatRoomWithLastMessage currentRoom = _rooms.firstWhere(
          (r) => r.room.roomId == rooms[i].room.roomId,
        );
        final room = currentRoom.room;
        String lastMsg = '';
        if (currentRoom.lastMessage != null) {
          final last = currentRoom.lastMessage!;
          if (last.imageUrl != null && last.imageUrl!.isNotEmpty) {
            lastMsg = '[Hình ảnh]';
          } else if (last.message != null && last.message!.isNotEmpty) {
            lastMsg = last.message!;
          } else {
            lastMsg = '';
          }
        }

        final lastTime = currentRoom.lastMessage?.createdAt;
        final timeText =
            lastTime != null
                ? DateFormat('HH:mm').format(lastTime.toLocal())
                : '';
        final bgColor =
            (!isPrivate && room.hasJoin == false)
                ? Colors.grey.shade200
                : Colors.white;
        String displayName = room.roomName;
        String? avatarUrl;

        if (isPrivate) {
          ChatUser? other;
          try {
            other = room.users.firstWhere((u) => u.userId != currentUserId);
          } catch (e) {
            other = null;
          }

          displayName = other?.fullName ?? 'Người dùng';
          avatarUrl =
              (other?.avatar?.isNotEmpty == true)
                  ? AuthService.getFullAvatarUrl(other!.avatar!)
                  : null;
        } else {
          avatarUrl =
              (room.roomAvatar?.isNotEmpty == true)
                  ? AuthService.getFullAvatarUrl(room.roomAvatar!)
                  : null;
        }

        return Container(
          color: bgColor,
          child: InkWell(
            onTap: () async {
              if (!isPrivate && room.hasJoin == false) {
                showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: const Text('Chưa tham gia phòng'),
                        content: const Text(
                          'Bạn chưa tham gia phòng này. Hãy quay về trang chủ để tham gia trước khi nhắn tin.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Đóng'),
                          ),
                        ],
                      ),
                );
                return;
              }

              setState(() {
                final index = _rooms.indexWhere(
                  (r) => r.room.roomId == room.roomId,
                );
                if (index >= 0) {
                  final oldRoom = _rooms[index];
                  _rooms[index] = ChatRoomWithLastMessage(
                    room: oldRoom.room.copyWith(unreadCount: 0),
                    lastMessage: oldRoom.lastMessage,
                  );
                }
              });

              ChatSocketService().enterRoom(room.roomId);
              context.push('/chat/room/${room.roomId}').then((_) async {
                ChatSocketService().enterRoom(null);
                await DBHelper().resetUnread(room.roomId);
                await _loadRooms();
              });
            },
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
                                room.unreadCount > 0
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
                                room.unreadCount > 0
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
                      if (timeText.isNotEmpty)
                        Text(
                          timeText,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                            fontWeight:
                                room.unreadCount > 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      if (room.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            room.unreadCount > 99
                                ? '99+'
                                : room.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
