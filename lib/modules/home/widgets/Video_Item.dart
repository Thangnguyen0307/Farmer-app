import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class VideoItem extends StatelessWidget {
  final String videoUrl; // đường dẫn file .mp4
  final String title;
  final String thumbnailUrl; // bắt buộc có ảnh thumbnail
  final VoidCallback onTap;

  const VideoItem({
    Key? key,
    required this.videoUrl,
    required this.title,
    required this.thumbnailUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: thumbnailUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.grey[300]),
              errorWidget: (_, __, ___) => Container(color: Colors.black12),
            ),
            Container(
              color: Colors.black26,
              alignment: Alignment.center,
              child: const Icon(
                Icons.play_circle_fill,
                size: 48,
                color: Colors.white70,
              ),
            ),
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
