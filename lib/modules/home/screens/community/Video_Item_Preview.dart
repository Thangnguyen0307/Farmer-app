import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoItemPreview extends StatefulWidget {
  final String videoUrl;
  final String avatarUrl;
  final String title;
  final String uploadedBy;
  final VoidCallback onTap;

  const VideoItemPreview({
    Key? key,
    required this.videoUrl,
    required this.avatarUrl,
    required this.title,
    required this.uploadedBy,
    required this.onTap,
  }) : super(key: key);

  @override
  State<VideoItemPreview> createState() => _VideoItemPreviewState();
}

class _VideoItemPreviewState extends State<VideoItemPreview> {
  late VideoPlayerController _controller;
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
          ..setVolume(0)
          ..setLooping(true)
          ..initialize().then((_) {
            if (mounted) setState(() {});
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleVisibility(bool visible) {
    if (_controller.value.isInitialized) {
      if (visible) {
        _controller.play();
      } else {
        _controller.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: VisibilityDetector(
        key: Key(widget.videoUrl),
        onVisibilityChanged: (info) {
          final visible = info.visibleFraction > 0.5;
          if (visible != isVisible) {
            isVisible = visible;
            _handleVisibility(visible);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio:
                  _controller.value.isInitialized
                      ? _controller.value.aspectRatio
                      : 16 / 9,
              child:
                  _controller.value.isInitialized
                      ? VideoPlayer(_controller)
                      : const Center(child: CircularProgressIndicator()),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(widget.avatarUrl),
                    backgroundColor: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
