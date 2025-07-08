import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ReelsViewer extends StatefulWidget {
  final List<String> youtubeLinks;

  const ReelsViewer({super.key, required this.youtubeLinks});

  @override
  State<ReelsViewer> createState() => _ReelsViewerState();
}

class _ReelsViewerState extends State<ReelsViewer> {
  late List<YoutubePlayerController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers =
        widget.youtubeLinks.map((link) {
          final id = YoutubePlayer.convertUrlToId(link) ?? '';
          return YoutubePlayerController(
            initialVideoId: id,
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
              loop: true,
              controlsVisibleAtStart: false,
              hideControls: true,
            ),
          );
        }).toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _controllers.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: YoutubePlayer(
                controller: _controllers[index],
                showVideoProgressIndicator: false,
                progressIndicatorColor: Colors.redAccent,
              ),
            ),
          );
        },
      ),
    );
  }
}
