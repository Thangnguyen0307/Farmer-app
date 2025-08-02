import 'package:farmrole/modules/auth/services/Comment_Service.dart';
import 'package:flutter/material.dart';

class CommentOptionMenu extends StatelessWidget {
  final String postId;
  final int commentIndex;
  final int? replyIndex;
  final bool isMyPost;
  final VoidCallback? onDeleted;

  const CommentOptionMenu({
    super.key,
    required this.postId,
    required this.commentIndex,
    this.replyIndex,
    required this.isMyPost,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    if (!isMyPost) return const SizedBox.shrink();
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_vert, size: 20),
      onSelected: (value) async {
        try {
          final commentService = CommentService();
          if (replyIndex == null) {
            await commentService.hideComment(
              context: context,
              postId: postId,
              commentIndex: commentIndex,
            );
          } else {
            await commentService.hideReply(
              context: context,
              postId: postId,
              commentIndex: commentIndex,
              replyIndex: replyIndex!,
            );
            print('Deleting comment reply index $commentIndex');
          }
          print('Deleting comment index $commentIndex');
          onDeleted?.call();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đã ẩn thành công')));
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(value: 'delete', child: Text('Xóa bình luận')),
        ];
      },
    );
  }
}
