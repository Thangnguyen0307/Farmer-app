import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/home/widgets/Post/Video_Comment.dart';
import 'package:farmrole/shared/types/Video_Model.dart';
import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoTile extends StatefulWidget {
  final VideoModel video;
  const VideoTile({Key? key, required this.video}) : super(key: key);

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  late bool isLiked;
  late int likeCount;
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isVisible = false;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.video.yourLike;
    likeCount = widget.video.likeCount;
  }

  void _initControllerIfNeeded() {
    if (_hasInitialized || !_isVisible) return;

    final url = AuthService.getFullAvatarUrl(widget.video.youtubeLink);
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _hasInitialized = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final video = widget.video;

    return VisibilityDetector(
      key: Key('video-tile-${video.id}'),
      onVisibilityChanged: (info) {
        final visible = info.visibleFraction > 0.2;
        if (visible != _isVisible) {
          if (mounted) {
            setState(() {
              _isVisible = visible;
            });
          }
          if (visible) _initControllerIfNeeded();
        }
      },
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        video.avatar.isNotEmpty
                            ? NetworkImage(
                              AuthService.getFullAvatarUrl(video.avatar),
                            )
                            : null,
                    radius: 18,
                    backgroundColor: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.uploadedBy,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${video.createdAt.day.toString().padLeft(2, '0')}/'
                                '${video.createdAt.month.toString().padLeft(2, '0')} '
                                '${video.createdAt.hour.toString().padLeft(2, '0')}:' +
                            '${video.createdAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            /// Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                video.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// Video player
            if (_isInitialized && _controller != null)
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_controller!),
                    VideoProgressIndicator(_controller!, allowScrubbing: true),
                    Center(
                      child: IconButton(
                        icon: Icon(
                          _controller!.value.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                          size: 48,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _controller!.value.isPlaying
                                ? _controller!.pause()
                                : _controller!.play();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            else if (_isVisible)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              const SizedBox(height: 200), // placeholder height

            const SizedBox(height: 8),

            /// Like - Comment - Share
            Row(
              children: [
                const SizedBox(width: 16),
                Icon(
                  Icons.thumb_up,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '$likeCount lượt thích',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '${video.commentCount} bình luận',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final success =
                        isLiked
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
                        isLiked = !isLiked;
                        likeCount += isLiked ? 1 : -1;
                        widget.video.yourLike = isLiked;
                        widget.video.likeCount = likeCount;
                      });
                    }
                  },
                  icon: Icon(
                    isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                    color:
                        isLiked
                            ? theme.colorScheme.primary
                            : Colors.grey.shade600,
                  ),
                  label: Text(
                    'Thích',
                    style: TextStyle(
                      color:
                          isLiked
                              ? theme.colorScheme.primary
                              : Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton.icon(
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
                  icon: Icon(
                    Icons.comment_outlined,
                    color: Colors.grey.shade600,
                  ),
                  label: Text(
                    'Bình luận',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Nhắn tin
                  },
                  icon: Icon(
                    Icons.message_outlined,
                    color: Colors.grey.shade600,
                  ),
                  label: Text(
                    'Nhắn tin',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
