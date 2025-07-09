import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:farmrole/shared/types/Video_Model.dart';

class ReelsScreen extends StatefulWidget {
  final List<VideoModel> videos;
  final int initialIndex;

  const ReelsScreen({
    Key? key,
    required this.videos,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.videos.length,
        scrollDirection: Axis.vertical,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (context, index) {
          final video = widget.videos[index];
          return _ReelVideoPlayer(
            videoUrl: video.youtubeLink,
          ); // tên cũ nhưng là mp4
        },
      ),
    );
  }
}

class _ReelVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const _ReelVideoPlayer({required this.videoUrl});

  @override
  State<_ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<_ReelVideoPlayer> {
  late VideoPlayerController _controller;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() => isInitialized = true);
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isInitialized
        ? Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
            // thêm overlay UI nếu cần
            const Positioned(
              bottom: 20,
              left: 20,
              child: Icon(Icons.favorite, color: Colors.white),
            ),
          ],
        )
        : const Center(child: CircularProgressIndicator());
  }
}
