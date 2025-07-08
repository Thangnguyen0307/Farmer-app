import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class VideoItem extends StatelessWidget {
  final String youtubeLink;
  final String title;
  final VoidCallback onTap;

  const VideoItem({
    Key? key,
    required this.youtubeLink,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  // 1. Tự tách id bằng regex
  String get _videoId {
    final regExp = RegExp(
      r'(?:v=|\/)([0-9A-Za-z_-]{11}).*',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(youtubeLink);
    return match?.group(1) ?? '';
  }

  // 2. URL thumbnail
  String get _thumbnailUrl =>
      'https://img.youtube.com/vi/$_videoId/hqdefault.jpg';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ảnh thumbnail
            CachedNetworkImage(
              imageUrl: _thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.grey[300]),
              errorWidget: (_, __, ___) => Container(color: Colors.black12),
            ),

            // overlay nút play
            Container(
              color: Colors.black26,
              alignment: Alignment.center,
              child: Icon(
                Icons.play_circle_fill,
                size: 48,
                color: Colors.white70,
              ),
            ),

            // tiêu đề ở đáy
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
