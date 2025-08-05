import 'package:farmrole/env/env.dart';
import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/services/Chat_Service.dart';
import 'package:farmrole/modules/auth/services/Chat_Socket_Service.dart';
import 'package:farmrole/modules/auth/services/Filter_Service.dart';
import 'package:farmrole/modules/auth/services/Home_Service.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/auth/state/Chat_Notifier.dart';
import 'package:farmrole/modules/auth/state/Upload_Manager.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/screens/home/VideoListScreen.dart';
import 'package:farmrole/modules/home/screens/home/Youtube/Youtube_Catelogy_Screen.dart';
import 'package:farmrole/modules/home/widgets/video/UploadStatusBar.dart';
import 'package:farmrole/shared/types/Chat_Room_Model.dart';
import 'package:farmrole/shared/types/DB_Helper.dart';
import 'package:farmrole/shared/types/Post_Model.dart';
import 'package:farmrole/shared/types/Video_Model.dart';
import 'package:farmrole/shared/types/Youtube_Catelogy_Model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatRoom> rooms = [];
  List<VideoModel> videos = [];
  bool isRoomLoading = true;
  bool isVideoLoading = true;
  ScrollController videoScrollController = ScrollController();
  List<PostModel> postsByFirstTag = [];
  bool isPostLoading = true;
  List<YoutubeCategoryModel> cate = [];
  List<PostModel> posts = [];
  int unreadCount = 0;
  @override
  void initState() {
    super.initState();
    loadUnreadCount();
    loadHomepageData();
    loadTopLikedPosts();
    final userId = context.read<UserProvider>().user!.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatNotifier = Provider.of<ChatNotifier>(context, listen: false);
      ChatSocketService().setNotifier(chatNotifier);
      chatNotifier.fetchTotalUnread(userId);
    });
  }

  Future<void> loadUnreadCount() async {
    final count = await DBHelper().getUnreadNotificationsCount();
    if (mounted) {
      setState(() {
        unreadCount = count;
      });
    }
  }

  Future<void> loadHomepageData() async {
    try {
      setState(() {
        isRoomLoading = true;
        isVideoLoading = true;
      });

      final homepageData = await HomeService().fetchHomepageData(context);
      print('🎥 Homepage videos count: ${homepageData.videos.length}');
      setState(() {
        videos = homepageData.videos;
        posts = homepageData.posts;
        rooms = homepageData.publicRooms;
        cate = homepageData.youtubeCategories;
        isRoomLoading = false;
        isVideoLoading = false;
      });
    } catch (e) {
      print('❌ Lỗi loadHomepageData: $e');
      setState(() {
        isRoomLoading = false;
        isVideoLoading = false;
      });
    }
  }

  Future<void> loadTopLikedPosts() async {
    try {
      if (!mounted) return;
      setState(() => isPostLoading = true);
      final res = await PostService().fetchAllPosts(
        context: context,
        page: 1,
        limit: 20,
        type: 'all',
        sortByLike: 'desc',
      );
      // lấy posts ra từ Map
      if (!mounted) return;
      setState(() {
        postsByFirstTag = res['posts'];
        isPostLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isPostLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = context.read<UserProvider>().user!.id;
    final token = context.read<UserProvider>().user!.token;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.primary,
        centerTitle: false,
        foregroundColor: Colors.white,
        title: Text(
          "FarmTalk",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          FutureBuilder<int>(
            future: DBHelper().getUnreadNotificationsCount(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;

              return Stack(
                children: [
                  IconButton(
                    onPressed: () async {
                      if (context.mounted) {
                        context.push('/noti');
                        await loadUnreadCount();
                      }
                    },
                    icon: Image.asset(
                      'lib/assets/icon/Noti.png',
                      width: 40,
                      height: 40,
                      color: Colors.white,
                    ),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          SizedBox(width: 4),
          Consumer<ChatNotifier>(
            builder: (context, notifier, _) {
              print("🎯 Widget rebuild với unread = ${notifier.totalUnread}");
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      context.push('/chat');
                      setState(() {});
                    },
                    icon: Image.asset(
                      'lib/assets/icon2/chat.png',
                      width: 34,
                      height: 34,
                    ),
                  ),
                  if (notifier.totalUnread > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '${notifier.totalUnread}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body:
          isRoomLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const UploadStatusBar(),
                    // PHẦN 1: Chat Room
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Nhắn tin cộng đồng cùng ',
                                ),
                                TextSpan(
                                  text: 'FarmTalk',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 100,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              itemCount: rooms.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, i) {
                                final room = rooms[i];

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    /// ✅ ẢNH PHÒNG — BẤM LÀ JOIN
                                    GestureDetector(
                                      onTap: () async {
                                        final roomId = room.roomId;
                                        try {
                                          if (room.hasJoin == true) {
                                            context.push('/chat/room/$roomId');
                                            return;
                                          }
                                          await ChatSocketService().joinRoom(
                                            roomId,
                                            userId,
                                          );
                                          await ChatSocketService().enterRoom(
                                            roomId,
                                          );
                                          await ChatSocketService()
                                              .loadOldMessages(roomId);

                                          final updatedRoom =
                                              await ChatService().getRoomInfo(
                                                token: token,
                                                roomId: roomId,
                                              );

                                          if (updatedRoom != null) {
                                            await DBHelper().updateRoom(
                                              updatedRoom,
                                              userId,
                                            );
                                            if (room.hasJoin != true) {
                                              await DBHelper().setRoomHasJoin(
                                                room.roomId,
                                                userId,
                                              );
                                              room.hasJoin = true;
                                            }
                                          }

                                          context.push('/chat/room/$roomId');
                                        } catch (e) {
                                          print('Join room failed: $e');
                                          await DBHelper().deleteRoom(roomId);
                                          if (!context.mounted) return;
                                          showDialog(
                                            context: context,
                                            builder:
                                                (_) => AlertDialog(
                                                  title: const Text(
                                                    'Phòng không tồn tại',
                                                  ),
                                                  content: const Text(
                                                    'Phòng chat này đã bị xoá.',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        loadHomepageData();
                                                      },
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                          );
                                        }
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(0),
                                        child:
                                            room.roomAvatar?.isNotEmpty == true
                                                ? Image.network(
                                                  AuthService.getFullAvatarUrl(
                                                    room.roomAvatar!,
                                                  ),
                                                  width: 130,
                                                  height: 70,
                                                  fit: BoxFit.cover,
                                                )
                                                : Container(
                                                  width: 130,
                                                  height: 70,
                                                  color: Colors.grey.shade200,
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    Icons.group,
                                                    size: 24,
                                                    color: Colors.grey.shade400,
                                                  ),
                                                ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      width: 130,
                                      child: Text(
                                        room.roomName,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    YoutubeCategoryGridSection(categories: cate),
                    Divider(height: 1, color: Colors.grey.shade300),

                    // PHẦN 2: Video Reels
                    if (videos.isNotEmpty || isVideoLoading)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      const TextSpan(text: 'FarmTalk '),
                                      TextSpan(
                                        text: 'Video',
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.push('/video-list');
                                  },
                                  child: Text(
                                    'Xem thêm',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            isVideoLoading
                                ? const SizedBox(
                                  height: 270,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                                : SizedBox(
                                  height: 270,
                                  child: ListView.separated(
                                    controller: videoScrollController,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: videos.length,
                                    separatorBuilder:
                                        (_, __) => const SizedBox(width: 16),
                                    itemBuilder: (_, i) {
                                      final video = videos[i];
                                      return RepaintBoundary(
                                        child: GestureDetector(
                                          onTap: () {
                                            context.push(
                                              '/community-videos',
                                              extra: {
                                                'videos': videos,
                                                'initialVideoId': video.id,
                                              },
                                            );
                                          },
                                          child: Container(
                                            width: 190,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            clipBehavior:
                                                Clip.hardEdge, // Giúp cắt hình bên trong gọn hơn
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                // Thumbnail
                                                CachedNetworkImage(
                                                  imageUrl:
                                                      AuthService.getFullAvatarUrl(
                                                        video.thumbnail ?? "",
                                                      ),
                                                  fit: BoxFit.cover,
                                                  memCacheHeight: 300,
                                                  fadeInDuration:
                                                      const Duration(
                                                        milliseconds: 200,
                                                      ),
                                                  placeholder:
                                                      (_, __) => Container(
                                                        color: Colors.black26,
                                                        alignment:
                                                            Alignment.center,
                                                        child:
                                                            const CircularProgressIndicator(
                                                              strokeWidth: 1.5,
                                                            ),
                                                      ),
                                                  errorWidget:
                                                      (_, __, ___) => Container(
                                                        color: Colors.grey,
                                                        child: const Icon(
                                                          Icons.error,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                ),

                                                // Nếu không có thumbnail
                                                if (video.thumbnail == null ||
                                                    video.thumbnail!.isEmpty)
                                                  Container(
                                                    color: Colors.black26,
                                                    alignment: Alignment.center,
                                                    child: const Icon(
                                                      Icons.play_arrow,
                                                      color: Colors.white,
                                                      size: 48,
                                                    ),
                                                  ),

                                                // Avatar & uploader
                                                Positioned(
                                                  left: 8,
                                                  bottom: 24,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 14,
                                                        backgroundImage:
                                                            video
                                                                    .avatar
                                                                    .isNotEmpty
                                                                ? NetworkImage(
                                                                  AuthService.getFullAvatarUrl(
                                                                    video
                                                                        .avatar,
                                                                  ),
                                                                )
                                                                : null,
                                                        backgroundColor:
                                                            Colors.grey[400],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        video.uploadedBy,
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.white,
                                                          shadows: [
                                                            Shadow(
                                                              color:
                                                                  Colors
                                                                      .black54,
                                                              blurRadius: 6,
                                                            ),
                                                          ],
                                                        ),
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // Title
                                                Positioned(
                                                  left: 8,
                                                  right: 8,
                                                  bottom: 8,
                                                  child: Text(
                                                    video.title,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      shadows: [
                                                        Shadow(
                                                          color: Colors.black54,
                                                          blurRadius: 6,
                                                        ),
                                                      ],
                                                      fontSize: 13,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                          ],
                        ),
                      ),
                    // Divider(height: 1, color: Colors.grey.shade300),
                    // buildHorizontalPostSection(),
                    Divider(height: 5, color: Colors.grey.shade300),

                    if (!isPostLoading && postsByFirstTag.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Top 20 ',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: 'Bài viết nhiều like nhất',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: postsByFirstTag.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final post = postsByFirstTag[i];
                                return GestureDetector(
                                  onTap:
                                      () => context.push(
                                        '/post-detail/${post.id}',
                                      ),
                                  child: Container(
                                    padding: const EdgeInsets.all(0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        // 👉 Ảnh bài post
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            0,
                                          ),
                                          child: SizedBox(
                                            width: 82,
                                            height: 58,
                                            child:
                                                post.images.isNotEmpty
                                                    ? Image.network(
                                                      AuthService.getFullAvatarUrl(
                                                        post.images.first,
                                                      ),
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            _,
                                                            __,
                                                            ___,
                                                          ) => Container(
                                                            color:
                                                                Colors
                                                                    .grey[200],
                                                          ),
                                                    )
                                                    : Container(
                                                      color: Colors.grey[200],
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        size: 20,
                                                        color: Colors.grey[400],
                                                      ),
                                                    ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                post.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey[900],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 10,
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    backgroundImage:
                                                        post
                                                                .author
                                                                .avatar
                                                                .isNotEmpty
                                                            ? NetworkImage(
                                                              AuthService.getFullAvatarUrl(
                                                                post
                                                                    .author
                                                                    .avatar,
                                                              ),
                                                            )
                                                            : null,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      post.author.fullName,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Image.asset(
                                                    'lib/assets/icon/like_Fill.png',
                                                    width: 15,
                                                    height: 15,
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    '${post.like}',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Image.asset(
                                                    'lib/assets/icon/comment_Fill.png',
                                                    width: 15,
                                                    height: 15,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    '${post.commentCount}',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
    );
  }

  Widget buildHorizontalPostSection() {
    if (posts.isEmpty) {
      return const SizedBox(); // Hoặc loader nếu đang loading
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Text(
            'Bài viết mới nhất',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 300,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: posts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final post = posts[index];
              final imageUrl =
                  post.images.isNotEmpty
                      ? "${Environment.config.baseUrl}${post.images.first}"
                      : "https://via.placeholder.com/150";

              return SizedBox(
                width: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        height: 150,
                        width: 220,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.favorite_border, size: 16),
                        const SizedBox(width: 4),
                        Text("${post.like}"),
                        const SizedBox(width: 12),
                        const Icon(Icons.comment, size: 16),
                        const SizedBox(width: 4),
                        Text("${post.commentCount}"),
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          post.createdAt != null
                              ? post.createdAt.toLocal().toString().substring(
                                0,
                                10,
                              )
                              : '',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
