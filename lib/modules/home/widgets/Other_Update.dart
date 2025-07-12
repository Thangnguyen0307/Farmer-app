import 'package:flutter/material.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/shared/types/Post_Model.dart';
import 'package:go_router/go_router.dart';

class PostOptionsMenu extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onDeleted;

  const PostOptionsMenu({super.key, required this.post, this.onDeleted});

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có chắc muốn xoá bài viết này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Huỷ'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final success = await PostService.deletePost(
                    context,
                    post.id,
                  );
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xoá bài viết')),
                    );
                    onDeleted?.call();
                  }
                },
                child: const Text('Xoá', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'update':
            GoRouter.of(context).push('/update-post', extra: post);
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
              child: Text('Cập nhật bài viết'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Xoá bài viết')),
          ],
      icon: const Icon(Icons.more_vert),
    );
  }
}
