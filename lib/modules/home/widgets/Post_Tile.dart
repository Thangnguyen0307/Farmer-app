import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/shared/types/Post_Model.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PostTile extends StatelessWidget {
  final PostModel post;
  const PostTile({Key? key, required this.post}) : super(key: key);

  void _showImageViewer(
    BuildContext context,
    List<String> imageUrls,
    int initialIndex,
  ) {
    final imageWidgets =
        imageUrls
            .map(
              (img) => PhotoView(
                imageProvider: NetworkImage(AuthService.getFullAvatarUrl(img)),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              ),
            )
            .toList();

    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            insetPadding: EdgeInsets.zero,
            child: Stack(
              children: [
                PageView.builder(
                  controller: PageController(initialPage: initialIndex),
                  itemCount: imageWidgets.length,
                  itemBuilder: (_, i) => imageWidgets[i],
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header: avatar + tên + thời gian
          Row(
            children: [
              if (post.author.avatar.isNotEmpty == true)
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    AuthService.getFullAvatarUrl(post.author.avatar),
                  ),
                  backgroundColor: Colors.grey.shade200,
                )
              else
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
              const SizedBox(width: 8),
              Text(
                post.author.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${post.createdAt.day.toString().padLeft(2, '0')}/'
                '${post.createdAt.month.toString().padLeft(2, '0')} '
                '${post.createdAt.hour.toString().padLeft(2, '0')}:'
                '${post.createdAt.minute.toString().padLeft(2, '0')}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            post.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(post.description, style: const TextStyle(fontSize: 14)),

          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildImageGrid(context),
          ],
        ],
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    final images = post.images;
    final count = images.length > 4 ? 4 : images.length;

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: count == 1 ? 1 : 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: count,
      itemBuilder: (_, i) {
        final url = AuthService.getFullAvatarUrl(images[i]);
        return GestureDetector(
          onTap: () => _showImageViewer(context, images, i),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder:
                    (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image),
                    ),
              ),
              if (i == 3 && images.length > 4)
                Container(
                  color: Colors.black45,
                  alignment: Alignment.center,
                  child: Text(
                    '+${images.length - 4}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
