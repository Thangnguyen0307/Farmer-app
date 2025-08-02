import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/services/Chat_Service.dart';
import 'package:farmrole/modules/auth/services/Chat_Socket_Service.dart';
import 'package:farmrole/modules/auth/services/Filter_Service.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/auth/state/Upload_Manager.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/widgets/video/UploadStatusBar.dart';
import 'package:farmrole/shared/types/Chat_Room_Model.dart';
import 'package:farmrole/shared/types/DB_Helper.dart';
import 'package:farmrole/shared/types/Post_Model.dart';
import 'package:farmrole/shared/types/Video_Model.dart';
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
  List<Map<String, dynamic>> tags = [];
  List<VideoModel> videos = [];
  bool isTagLoading = true;
  String? selectedTag = 'Tất cả';
  bool isRoomLoading = true;
  bool isVideoLoading = true;
  int videoPage = 1;
  final int videoLimit = 10;
  bool isFetchingMore = false;
  bool hasMoreVideo = true;
  ScrollController videoScrollController = ScrollController();
  List<PostModel> postsByFirstTag = [];
  bool isPostLoading = true;
  bool isFilterVisible = false;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  List<VideoModel> previousVideos = [];
  int currentSearchPage = 1;
  bool hasMoreSearchVideos = true;
  String lastSearchKeyword = '';
  bool noSearchResult = false;
  @override
  void initState() {
    super.initState();
    loadPublicRooms();
    loadLatestVideos();
    loadTopLikedPosts();
    videoScrollController.addListener(() {
      if (videoScrollController.position.pixels >=
          videoScrollController.position.maxScrollExtent - 200) {
        if (isSearching) {
          if (hasMoreSearchVideos && !isVideoLoading) {
            searchVideosByTitle(lastSearchKeyword, isNewSearch: false);
          }
        } else {
          loadMoreVideos();
        }
      }
    });
  }

  Future<void> loadPublicRooms() async {
    try {
      final dbHelper = DBHelper();
      final allRooms = await dbHelper.getAllRooms();

      final publicRooms =
          allRooms.where((room) => room.mode == 'public').toList();

      setState(() {
        rooms = publicRooms;
        isRoomLoading = false;
      });
    } catch (e) {
      print('❌ Lỗi loadPublicRooms: $e');
      setState(() => isRoomLoading = false);
    }
  }

  Future<void> loadLatestVideos({bool isLoadMore = false}) async {
    if (isLoadMore && (isFetchingMore || !hasMoreVideo)) return;

    if (isLoadMore) {
      setState(() => isFetchingMore = true);
    } else {
      setState(() {
        isVideoLoading = true;
        videoPage = 1;
        videos = [];
        hasMoreVideo = true;
      });
    }

    final res = await PostService().fetchLatestVideos(
      context: context,
      page: videoPage,
      limit: videoLimit,
    );
    if (!mounted) return;
    if (res != null) {
      setState(() {
        if (isLoadMore) {
          videos.addAll(res.videos);
          isFetchingMore = false;
        } else {
          videos = res.videos;
        }
        hasMoreVideo = (res.videos.length) >= videoLimit;
        isVideoLoading = false;
        videoPage = isLoadMore ? videoPage + 1 : 2;
      });
    }
  }

  Future<void> loadMoreVideos() async {
    if (selectedTag == null || selectedTag == 'Tất cả') {
      await loadLatestVideos(isLoadMore: true);
    } else {
      await loadVideosByTag(selectedTag!, isLoadMore: true);
    }
  }

  Future<void> loadTopTags() async {
    final res = await PostService().fetchTopTags(context);
    if (!mounted) return;
    if (res != null) {
      setState(() {
        tags =
            [
              {'tag': 'Tất cả'},
            ] +
            res.map((e) => {'tag': e['tag'].toString()}).toList();
        isTagLoading = false;
      });
      loadLatestVideos();
    } else {
      setState(() => isTagLoading = false);
    }
  }

  Future<void> loadVideosByTag(String tag, {bool isLoadMore = false}) async {
    if (isLoadMore && (isFetchingMore || !hasMoreVideo)) return;

    if (!isLoadMore) {
      setState(() {
        selectedTag = tag;
        videos = [];
        isVideoLoading = true;
        videoPage = 1;
        hasMoreVideo = true;
      });
    } else {
      setState(() => isFetchingMore = true);
    }

    final res = await PostService().fetchVideosByTag(
      context: context,
      tag: tag,
      page: videoPage,
      limit: videoLimit,
    );

    setState(() {
      if (isLoadMore) {
        videos.addAll(res?.videos ?? []);
        isFetchingMore = false;
      } else {
        videos = res?.videos ?? [];
        isVideoLoading = false;
      }
      hasMoreVideo = (res?.videos.length ?? 0) >= videoLimit;
      if (!isLoadMore)
        videoPage = 2;
      else
        videoPage++;
    });
  }

  Future<void> searchVideosByTitle(
    String title, {
    bool isNewSearch = true,
  }) async {
    if (isNewSearch) {
      setState(() {
        isVideoLoading = true;
        isFilterVisible = true;
        selectedTag = null;
        currentSearchPage = 1;
        hasMoreSearchVideos = true;
        lastSearchKeyword = title;
      });
    }

    // Lưu lại video cũ nếu là trang đầu tiên
    final oldVideos = videos;

    final response = await FilterService().searchVideos(
      context: context,
      title: title,
      page: currentSearchPage,
      limit: 20,
    );

    if (response != null && response.videos.isNotEmpty) {
      setState(() {
        if (isNewSearch) {
          videos = response.videos;
        } else {
          videos.addAll(response.videos);
        }
        currentSearchPage++;
        hasMoreSearchVideos = response.videos.length == 20;
        isVideoLoading = false;
      });
    } else {
      setState(() {
        if (isNewSearch) {
          videos = oldVideos;
          noSearchResult = true;
        }
        hasMoreSearchVideos = false;
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
          Consumer<UploadManager>(
            builder: (context, manager, _) {
              final unseenCompleted =
                  manager.uploads
                      .where((e) => e.isCompleted && !e.isSeen)
                      .length;

              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      context.read<UploadManager>().markAllCompletedAsSeen();
                      context.push('/noti');
                    },
                    icon: Image.asset(
                      'lib/assets/icon/Noti.png',
                      width: 40,
                      height: 40,
                      color: Colors.white,
                    ),
                  ),
                  if (unseenCompleted > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '$unseenCompleted',
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
          IconButton(
            onPressed: () {
              context.push('/chat');
            },
            icon: Image.asset(
              'lib/assets/icon2/chat.png',
              width: 34,
              height: 34,
            ),
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
                      padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
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
                            height: 140,
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
                                    // 1. Ảnh nhỏ bo góc
                                    ClipRRect(
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
                                    GestureDetector(
                                      onTap: () async {
                                        final roomId = room.roomId;
                                        try {
                                          //da join roi thi vao luon
                                          if (room.hasJoin == true) {
                                            context.push('/chat/room/$roomId');
                                            return;
                                          }
                                          //chua join goi joinRoom
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
                                          if (!mounted) return;
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
                                                        loadPublicRooms();
                                                      },
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                          );
                                        }
                                      },
                                      child: SizedBox(
                                        height: 35,
                                        child: Image.asset(
                                          'lib/assets/icon2/Join.png',
                                          fit: BoxFit.cover,
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

                    // PHẦN 2: Video Reels
                    if (videos.isNotEmpty || isVideoLoading)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Image.asset(
                                        'lib/assets/icon/Search3.png',
                                        width: 30,
                                        height: 30,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isSearching = !isSearching;
                                          if (!isSearching) {
                                            searchController.clear();
                                            loadLatestVideos();
                                          }
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: Image.asset(
                                        'lib/assets/icon/Filter.png',
                                        width: 30,
                                        height: 30,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isFilterVisible = !isFilterVisible;
                                        });
                                        if (isFilterVisible && tags.isEmpty) {
                                          loadTopTags();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (isSearching)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 36, // Giảm chiều cao tổng thể
                                      child: TextField(
                                        controller: searchController,
                                        style: const TextStyle(
                                          fontSize: 13,
                                        ), // chữ nhỏ hơn
                                        decoration: InputDecoration(
                                          hintText: 'Tìm kiếm video...',
                                          hintStyle: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300,
                                            color: Colors.grey.shade600,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.search,
                                            size: 18,
                                          ), // icon nhỏ lại
                                          suffixIcon: IconButton(
                                            icon: const Icon(
                                              Icons.clear,
                                              size: 18,
                                            ),
                                            onPressed: () {
                                              searchController.clear();
                                              loadLatestVideos();
                                            },
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[200],
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                vertical:
                                                    8, // giảm padding trong input
                                                horizontal: 12,
                                              ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        onSubmitted: (value) {
                                          if (value.trim().isNotEmpty) {
                                            searchVideosByTitle(value.trim());
                                          }
                                        },
                                      ),
                                    ),
                                    if (noSearchResult)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 6,
                                          left: 12,
                                        ),
                                        child: Text(
                                          'Không tìm thấy video phù hợp với "${searchController.text}"',
                                          style: TextStyle(
                                            color: Colors.red[700],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                            if (isFilterVisible)
                              Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: SizedBox(
                                  height: 36,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: tags.length,
                                    separatorBuilder:
                                        (_, __) => const SizedBox(width: 12),
                                    itemBuilder: (_, i) {
                                      final tag = tags[i];
                                      final isSelected =
                                          selectedTag == tag['tag'];
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedTag = tag['tag'];
                                          });
                                          if (selectedTag == 'Tất cả') {
                                            loadLatestVideos();
                                          } else {
                                            loadVideosByTag(selectedTag!);
                                          }
                                        },
                                        child: Text(
                                          '#${tag['tag']}',
                                          style: TextStyle(
                                            color:
                                                isSelected
                                                    ? Theme.of(
                                                      context,
                                                    ).primaryColor
                                                    : Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

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
}
