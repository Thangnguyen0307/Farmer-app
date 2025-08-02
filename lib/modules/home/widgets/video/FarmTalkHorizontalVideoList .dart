import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoItemPlayer extends StatefulWidget {
  final String url;
  final bool shouldPlay;
  const VideoItemPlayer({
    super.key,
    required this.url,
    this.shouldPlay = false,
  });

  @override
  State<VideoItemPlayer> createState() => _VideoItemPlayerState();
}

class _VideoItemPlayerState extends State<VideoItemPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {});
        if (widget.shouldPlay) {
          _controller.play();
        }
        _controller.setLooping(true);
        _controller.setVolume(0);
      });
  }

  @override
  void didUpdateWidget(covariant VideoItemPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPlay != oldWidget.shouldPlay) {
      if (widget.shouldPlay) {
        _controller.play();
      } else {
        _controller.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container(
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final isPortrait = _controller.value.aspectRatio < 1;
    return SizedBox.expand(
      child: FittedBox(
        fit: isPortrait ? BoxFit.cover : BoxFit.contain,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
