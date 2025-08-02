import 'package:flutter/material.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/shared/types/Post_Model.dart';
import 'package:go_router/go_router.dart';

class PostOptionsMenu extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onDeleted;
  final VoidCallback? onUpdated;

  const PostOptionsMenu({
    super.key,
    required this.post,
    this.onDeleted,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'update':
            final updated = await GoRouter.of(
              context,
            ).push<bool>('/update-post', extra: post);
            if (updated == true) {
              onUpdated?.call();
            }
            break;

          case 'delete':
            _showDeleteConfirm(context);
            break;
        }
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'update',
              child: Text('Chỉnh sửa bài viết'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Xóa bài viết')),
          ],
      icon: const Icon(Icons.more_vert),
    );
  }

  void _showDeleteConfirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Xóa bài viết'),
            content: const Text(
              'Bạn có chắc chắn muốn xóa bài viết này không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    final success = await PostService.deletePost(context, post.id);
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_outline : Icons.error_outline,
              color: success ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                success
                    ? 'Đã xóa bài viết thành công.'
                    : 'Xóa bài viết thất bại. Vui lòng thử lại.',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey.shade900,
        duration: const Duration(seconds: 3),
      ),
    );

    if (success) {
      onDeleted?.call();
    }
  }
}
