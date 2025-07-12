import 'dart:async';

import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/widgets/Upload_Image/Upload_Chat_Image.dart';
import 'package:flutter/material.dart';
import 'package:farmrole/modules/auth/services/Chat_Service.dart';
import 'package:farmrole/modules/auth/services/Chat_Socket_Service.dart';
import 'package:farmrole/shared/types/Chat_Room_Model.dart';
import 'package:farmrole/shared/types/DB_Helper.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

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
  StreamSubscription<Map<String, dynamic>>? _statusSub;
  ChatRoom? _room;

  @override
  void initState() {
    super.initState();
    _roomFuture = _loadRoom(widget.roomId);

    // Lắng nghe tin nhắn mới
    _messageSub = _socketSvc.messages.listen((msg) async {
      if (msg.roomId == widget.roomId) {
        await DBHelper().insertMessage(msg);
        if (mounted) {
          setState(() => _messages.add(msg));
          _scrollToBottom();
        }
      }
    });

    // Lắng nghe thay đổi trạng thái online
    _statusSub = _socketSvc.onlineStatus.listen((data) {
      final userId = data['userId'];
      final online = data['online'];

      if (mounted && _room != null) {
        final user = _room!.users.cast<ChatUser?>().firstWhere(
          (u) => u?.userId == userId,
          orElse: () => null,
        );
        if (user != null && user.online != online) {
          setState(() {
            user.online = online;
          });
        }
      }
    });
    // Load tin nhắn cũ từ DB
    DBHelper().getMessages(widget.roomId).then((localMsgs) {
      if (mounted) {
        _messages.clear();
        setState(() => _messages.addAll(localMsgs));
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });
  }

  void _applyOnlineStatusFromSocket(ChatRoom room) {
    final socket = ChatSocketService();
    for (final user in room.users) {
      final online = socket.userOnlineMap[user.userId];
      if (online != null) {
        user.online = online;
      }
    }
  }

  Future<ChatRoom> _loadRoom(String roomId) async {
    final localRoom = await DBHelper().getRoomById(roomId);
    if (localRoom != null && localRoom.users.isNotEmpty) {
      _room = localRoom;
      return localRoom;
    }

    final room = await ChatService.getRoomDetail(context, roomId);
    _applyOnlineStatusFromSocket(room);
    await DBHelper().insertRoom(room);
    _room = room;
    return room;
  }

  void _sendImage() async {
    final user = context.read<UserProvider>().user!;
    final file = await UploadChatImage().pickImageWithDialog(context);
    if (file == null) return;

    try {
      final imageUrl = await ChatService.uploadChatImage(
        roomId: widget.roomId,
        imageFile: file,
        token: user.token!,
      );

      if (imageUrl != null) {
        _socketSvc.sendMessage(
          roomId: widget.roomId,
          userId: user.id,
          fullName: user.fullName,
          avatar: user.avatar,
          message: '', // hoặc "🖼️ Đã gửi một ảnh"
          imageUrl: imageUrl,
        );
      }
    } catch (e) {
      debugPrint('❌ Lỗi upload ảnh: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lỗi upload ảnh')));
    }
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

    final user = context.read<UserProvider>().user!;
    _socketSvc.sendMessage(
      roomId: widget.roomId,
      message: text,
      userId: user.id,
      fullName: user.fullName,
      avatar: user.avatar,
    );

    _inputCtrl.clear();
  }

  void _showImageViewer(
    BuildContext context,
    List<String> imageUrls,
    int initialIndex,
  ) {
    final imageWidgets =
        imageUrls
            .map(
              (img) => PhotoView(
                imageProvider: NetworkImage(AuthService.getFullAvatarUrl(img)),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              ),
            )
            .toList();
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            insetPadding: EdgeInsets.zero,
            child: Stack(
              children: [
                PageView.builder(
                  controller: PageController(initialPage: initialIndex),
                  itemCount: imageWidgets.length,
                  itemBuilder: (_, i) => imageWidgets[i],
                ),
              ],
            ),
          ),
    );
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _statusSub?.cancel();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_room == null) {
      return FutureBuilder<ChatRoom>(
        future: _roomFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Lỗi: ${snapshot.error}')),
            );
          }

          _room = snapshot.data!;
          return buildChatUI();
        },
      );
    }

    return buildChatUI();
  }

  Widget buildChatUI() {
    final currentUserId = context.read<UserProvider>().user?.id;
    final room = _room!;

    return Scaffold(
      appBar: AppBar(title: Text(room.roomName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final isMe = currentUserId == m.userId;
                final localTime = m.createdAt.toLocal();
                final sender = room.users.firstWhere(
                  (u) => u.userId == m.userId,
                  orElse:
                      () => ChatUser(
                        userId: '',
                        fullName: '',
                        avatar: null,
                        online: false,
                      ),
                );

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isMe
                              ? Theme.of(context).primaryColor.withOpacity(0.15)
                              : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isMe ? 12 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundImage:
                                        sender.avatar != null
                                            ? NetworkImage(
                                              AuthService.getFullAvatarUrl(
                                                sender.avatar!,
                                              ),
                                            )
                                            : null,
                                    child:
                                        sender.avatar == null
                                            ? const Icon(Icons.person, size: 14)
                                            : null,
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            sender.online
                                                ? Colors.green
                                                : Colors.grey,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                sender.fullName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        if (!isMe) const SizedBox(height: 4),
                        if (m.message?.isNotEmpty == true)
                          Text(
                            m.message!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        if (m.imageUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: GestureDetector(
                              onTap: () {
                                // Lấy tất cả ảnh trong room
                                final imageList =
                                    _messages
                                        .where((msg) => msg.imageUrl != null)
                                        .map((msg) => msg.imageUrl!)
                                        .toList();

                                final initialIndex = imageList.indexOf(
                                  m.imageUrl!,
                                );

                                _showImageViewer(
                                  context,
                                  imageList,
                                  initialIndex,
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  AuthService.getFullAvatarUrl(m.imageUrl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 6),
                        Text(
                          '${localTime.hour}:${localTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(
            height: 0.25,
            color: Color.fromARGB(255, 216, 215, 215),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image_outlined),
                  onPressed: _sendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w300,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
