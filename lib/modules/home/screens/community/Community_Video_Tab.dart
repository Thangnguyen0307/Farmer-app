import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/home/widgets/Post/Video_Comment.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/shared/types/Video_Model.dart';

class CommunityReelsVideoTab extends StatefulWidget {
  const CommunityReelsVideoTab({super.key});

  @override
  State<CommunityReelsVideoTab> createState() => _CommunityReelsVideoTabState();
}

class _CommunityReelsVideoTabState extends State<CommunityReelsVideoTab> {
  List<VideoModel> videos = [];
  bool isLoading = true;
  final Map<int, dynamic> _controllers = {};
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  Future<void> loadVideos() async {
    final res = await PostService().fetchLatestVideos(context: context);
    if (res != null && res.videos != null) {
      setState(() {
        videos = res.videos;
        isLoading = false;
      });
      _initializeController(0); // init video đầu tiên
      _playOnly(0);
    } else {
      setState(() => isLoading = false);
    }
  }

  bool _isYoutube(String url) =>
      url.contains('youtube.com') || url.contains('youtu.be');

  void _initializeController(int index) {
    if (_controllers.containsKey(index)) return;
    final url = videos[index].youtubeLink;

    if (_isYoutube(url)) {
      final videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null) {
        _controllers[index] = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(autoPlay: true),
        );
      }
    } else {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      controller.initialize().then((_) {
        if (mounted) setState(() {});
      });
      _controllers[index] = controller;
    }
  }

  void _playOnly(int index) {
    _controllers.forEach((i, ctrl) {
      if (i == index) {
        if (ctrl is YoutubePlayerController) ctrl.play();
        if (ctrl is VideoPlayerController) ctrl.play();
      } else {
        if (ctrl is YoutubePlayerController) ctrl.pause();
        if (ctrl is VideoPlayerController) ctrl.pause();
      }
    });
  }

  Future<void> _handleLike(int index) async {
    final video = videos[index];
    final liked = video.yourLike;
    final success =
        liked
            ? await PostService().unlikeVideo(
              context: context,
              videoId: video.id,
            )
            : await PostService().likeVideo(
              context: context,
              videoId: video.id,
            );
    if (success) {
      setState(() {
        videos[index] = video.copyWith(
          yourLike: !liked,
          likeCount: liked ? video.likeCount - 1 : video.likeCount + 1,
        );
      });
    }
  }

  Widget _buildVideo(int index) {
    _initializeController(index);
    final controller = _controllers[index];
    final video = videos[index];

    return Stack(
      alignment: Alignment.center,
      children: [
        controller == null
            ? const Center(child: CircularProgressIndicator())
            : controller is YoutubePlayerController
            ? YoutubePlayer(controller: controller)
            : controller.value.isInitialized
            ? Center(
              child: GestureDetector(
                onTap: () {
                  if (controller.value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                  setState(() {});
                },
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
            )
            : const Center(child: CircularProgressIndicator()),

        Positioned(
          bottom: 55,
          left: 16,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      AuthService.getFullAvatarUrl(video.avatar),
                    ),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  const SizedBox(width: 8),
                  // Tên + farm
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.uploadedBy,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            shadows: [
                              Shadow(blurRadius: 4, color: Colors.black),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          video.farmName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            shadows: [
                              Shadow(blurRadius: 4, color: Colors.black),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                ),
              ),
            ],
          ),
        ),

        //like + cmt + chat
        Positioned(
          right: 12,
          bottom: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () async {
                  final success =
                      video.yourLike
                          ? await PostService().unlikeVideo(
                            context: context,
                            videoId: video.id,
                          )
                          : await PostService().likeVideo(
                            context: context,
                            videoId: video.id,
                          );
                  if (success) {
                    setState(() {
                      video.yourLike = !video.yourLike;
                      video.likeCount += video.yourLike ? 1 : -1;
                    });
                  }
                },
                icon: Icon(
                  video.yourLike ? Icons.favorite : Icons.favorite_border,
                  color: video.yourLike ? Colors.red : Colors.white,
                  size: 32,
                ),
              ),
              Text(
                '${video.likeCount}',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    barrierColor: Colors.black38,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(2),
                      ),
                    ),
                    builder: (_) {
                      return VideoCommentScreen(videoId: video.id);
                    },
                  );
                },
                icon: const Icon(Icons.comment, color: Colors.white, size: 30),
              ),
              Text(
                '${video.commentCount}',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              IconButton(
                onPressed: () {
                  // TODO: mở màn hình chat
                },
                icon: const Icon(Icons.send, color: Colors.white, size: 28),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (final ctrl in _controllers.values) {
      ctrl.pause();
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (videos.isEmpty) return const Center(child: Text('Chưa có video nào'));

    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: videos.length,
      onPageChanged: (index) {
        setState(() {
          currentIndex = index;
          _initializeController(index);
          _playOnly(index);
        });
      },
      itemBuilder: (_, index) {
        return _buildVideo(index);
      },
    );
  }
}
