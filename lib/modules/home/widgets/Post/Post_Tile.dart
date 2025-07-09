import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/home/widgets/Post/Comment_Bottom_Sheet.dart';
import 'package:farmrole/shared/types/Post_Model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';

class PostTile extends StatefulWidget {
  final PostModel post;
  const PostTile({Key? key, required this.post}) : super(key: key);

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  late bool isLiked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.yourLike;
    likeCount = widget.post.like;
  }

  void _handleLike() async {
    final postId = widget.post.id;
    final success =
        isLiked
            ? await PostService().unlikePost(context: context, postId: postId)
            : await PostService().likePost(context: context, postId: postId);

    if (success) {
      setState(() {
        isLiked = !isLiked;
        likeCount += isLiked ? 1 : -1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thao tác không thành công')),
      );
    }
  }

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
    final theme = Theme.of(context);
    final post = widget.post;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (avatar, tên, thời gian)
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage:
                          post.author.avatar.isNotEmpty
                              ? NetworkImage(
                                AuthService.getFullAvatarUrl(
                                  post.author.avatar,
                                ),
                              )
                              : null,
                      backgroundColor: Colors.grey.shade200,
                      child:
                          post.author.avatar.isEmpty
                              ? const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 18,
                              )
                              : null,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${post.createdAt.day.toString().padLeft(2, '0')}/'
                          '${post.createdAt.month.toString().padLeft(2, '0')} '
                          '${post.createdAt.hour.toString().padLeft(2, '0')}:'
                          '${post.createdAt.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(post.description, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),

          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildImageGrid(context),
          ],
          const SizedBox(height: 8),

          // Like + Comment summary
          Row(
            children: [
              const SizedBox(width: 20),
              Icon(Icons.thumb_up, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                '$likeCount lượt thích',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  '${post.commentCount} bình luận',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ),
            ],
          ),

          //Nut like + Comment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                onPressed: _handleLike,
                icon: Icon(
                  isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                  color:
                      isLiked
                          ? theme.colorScheme.primary
                          : Colors.grey.shade600,
                ),
                label: Text(
                  'Thích',
                  style: TextStyle(
                    color:
                        isLiked
                            ? theme.colorScheme.primary
                            : Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => CommentBottomSheet(postId: post.id),
                  );
                },
                icon: Icon(Icons.comment_outlined, color: Colors.grey.shade600),
                label: Text(
                  'Bình luận',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // TODO: xử lý nhắn tin
                },
                icon: Icon(Icons.message_outlined, color: Colors.grey.shade600),
                label: Text(
                  'Nhắn tin',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    final images = widget.post.images;
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
