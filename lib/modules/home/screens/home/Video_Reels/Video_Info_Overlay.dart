import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/home/widgets/Post/Report_Video.dart';
import 'package:farmrole/modules/home/widgets/video/Chat_Private_Video_Button.dart';
import 'package:farmrole/modules/home/widgets/Post/Video_Comment.dart';
import 'package:farmrole/shared/types/Video_Model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VideoInfoOverlay extends StatefulWidget {
  final VideoModel video;
  final int index;
  final List<VideoModel> videos;

  const VideoInfoOverlay({
    super.key,
    required this.video,
    required this.index,
    required this.videos,
  });

  @override
  State<VideoInfoOverlay> createState() => _VideoInfoOverlayState();
}

class _VideoInfoOverlayState extends State<VideoInfoOverlay> {
  final Map<int, bool> _isExpandedTitle = {};

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // LEFT: Avatar + title
        Positioned(
          bottom: 55,
          left: 16,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      context.push('/profile/${widget.video.uploadedById}');
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(
                            AuthService.getFullAvatarUrl(widget.video.avatar),
                          ),
                          backgroundColor: Colors.grey.shade200,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 180,
                              child: Text(
                                widget.video.uploadedBy,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  shadows: [
                                    Shadow(blurRadius: 4, color: Colors.black),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.video.farmName,
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
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildTitle(widget.index),
            ],
          ),
        ),

        // RIGHT: like / comment / chat
        Positioned(
          right: 12,
          bottom: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () async {
                  final success =
                      widget.video.yourLike
                          ? await PostService().unlikeVideo(
                            context: context,
                            videoId: widget.video.id,
                          )
                          : await PostService().likeVideo(
                            context: context,
                            videoId: widget.video.id,
                          );
                  if (success) {
                    setState(() {
                      widget.video.yourLike = !widget.video.yourLike;
                      widget.video.likeCount += widget.video.yourLike ? 1 : -1;
                    });
                  }
                },
                icon: Image.asset(
                  widget.video.yourLike
                      ? 'lib/assets/icon2/Heart2.png'
                      : 'lib/assets/icon2/Heart_Line2.png',
                  width: 35,
                  height: 35,
                ),
              ),
              Text(
                '${widget.video.likeCount}',
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
                      return VideoCommentScreen(videoId: widget.video.id);
                    },
                  );
                },
                icon: Image.asset(
                  'lib/assets/icon/comment_Fill.png',
                  width: 34,
                  height: 34,
                  color: Colors.white,
                ),
              ),
              Text(
                '${widget.video.commentCount}',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  ChatPrivateVideoButton(
                    targetUserId: widget.video.uploadedById,
                    targetFullName: widget.video.uploadedBy,
                  ),

                  const Text(
                    'Gửi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                    ),
                  ),
                  const SizedBox(height: 4),
                  ReportVideo(video: widget.video),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(int index) {
    final video = widget.videos[index];
    final isExpanded = _isExpandedTitle[index] ?? false;

    return LayoutBuilder(
      builder: (context, constraints) {
        final textSpan = TextSpan(
          text: video.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        );

        final tp = TextPainter(
          text: textSpan,
          maxLines: 2,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflowing = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: Text(
                video.title,
                maxLines: isExpanded ? null : 2,
                overflow:
                    isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                ),
              ),
            ),
            if (isOverflowing || isExpanded)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpandedTitle[index] = !isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    isExpanded ? 'Thu gọn' : 'Xem thêm',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
