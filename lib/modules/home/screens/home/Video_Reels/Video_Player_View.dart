import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerView extends StatefulWidget {
  final String videoUrl;
  final bool isPlaying;

  const VideoPlayerView({
    super.key,
    required this.videoUrl,
    required this.isPlaying,
  });

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showControls = false;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    try {
      await _controller!.initialize();
      setState(() => _isInitialized = true);
      if (widget.isPlaying) _controller!.play();
    } catch (e) {
      debugPrint('Video init error: $e');
    }
  }

  void _togglePlayPause() {
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    setState(() {}); // update UI
  }

  void _changeVolume(double delta) {
    setState(() {
      _volume += delta;
      _volume = _volume.clamp(0.0, 1.0);
      _controller?.setVolume(_volume);
    });
  }

  @override
  void didUpdateWidget(VideoPlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller != null) {
      if (widget.isPlaying && !_controller!.value.isPlaying) {
        _controller!.play();
      } else if (!widget.isPlaying && _controller!.value.isPlaying) {
        _controller!.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_isInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _togglePlayPause();
                setState(() {
                  _showControls = !_showControls;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller!),
                  if (!_controller!.value.isPlaying)
                    Container(
                      color: Colors.black45,
                      child: const Icon(
                        Icons.play_arrow,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),

            // Volume controls
            if (_showControls)
              Positioned(
                top: 16,
                right: 16,
                child: Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.white),
                      onPressed: () => _changeVolume(0.1),
                    ),
                    Text(
                      "${(_volume * 100).round()}%",
                      style: const TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_mute, color: Colors.white),
                      onPressed: () => _changeVolume(-0.1),
                    ),
                  ],
                ),
              ),

            if (_showControls || !_controller!.value.isPlaying)
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: Colors.blueAccent,
                    backgroundColor: Colors.grey,
                    bufferedColor: Colors.lightBlue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
