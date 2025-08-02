import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/widgets/Post/Chat_Private_Button.dart';
import 'package:farmrole/modules/home/widgets/Post/Comment_Bottom_Sheet.dart';
import 'package:farmrole/modules/home/widgets/Post/Like_User_List_Screen.dart';
import 'package:farmrole/modules/home/widgets/Post/Report_Post.dart';
import 'package:farmrole/shared/types/Post_Model.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class PostPersonal extends StatefulWidget {
  final PostModel post;
  const PostPersonal({Key? key, required this.post}) : super(key: key);

  @override
  State<PostPersonal> createState() => _PostPersonalState();
}

class _PostPersonalState extends State<PostPersonal> {
  late bool isLiked;
  late int likeCount;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.yourLike;
    likeCount = widget.post.like;
    print('Post ID ở Personal: ${widget.post.id}');
  }

  void _handleLike() async {
    final postId = widget.post.id;
    final success =
        isLiked
            ? await PostService().unlikePost(context: context, postId: postId)
            : await PostService().likePost(context: context, postId: postId);
    print('API Like Comment postId: $postId');
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
    final pageController = PageController(initialPage: initialIndex);
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setStateDialog) {
              return Scaffold(
                backgroundColor: Colors.black,
                body: SafeArea(
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: pageController,
                        itemCount: imageUrls.length,
                        itemBuilder: (_, i) {
                          final url = AuthService.getFullAvatarUrl(
                            imageUrls[i],
                          );
                          return PhotoView(
                            imageProvider: NetworkImage(url),
                            backgroundDecoration: const BoxDecoration(
                              color: Colors.black,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 20,
                        right: 20,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Positioned(
                        bottom: 60,
                        left: 40,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              'lib/assets/icon/like_Fill.png',
                              width: 20,
                              height: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$likeCount lượt thích                          ${widget.post.commentCount} bình luận',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                onPressed: () async {
                                  final postId = widget.post.id;
                                  final success =
                                      isLiked
                                          ? await PostService().unlikePost(
                                            context: context,
                                            postId: postId,
                                          )
                                          : await PostService().likePost(
                                            context: context,
                                            postId: postId,
                                          );
                                  if (success) {
                                    setState(() {
                                      isLiked = !isLiked;
                                      likeCount += isLiked ? 1 : -1;
                                    });
                                    setStateDialog(() {});
                                  }
                                },
                                icon: Image.asset(
                                  isLiked
                                      ? 'lib/assets/icon/like_Fill.png'
                                      : 'lib/assets/icon/like_Line.png',
                                  width: 20,
                                  height: 20,
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
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                            : Colors.grey.shade400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder:
                                        (_) => CommentBottomSheet(
                                          postId: widget.post.id,
                                        ),
                                  );
                                },
                                icon: Image.asset(
                                  'lib/assets/icon/comment_Line.png',
                                  width: 20,
                                  height: 20,
                                  color: Colors.grey,
                                ),
                                label: const Text(
                                  'Bình luận',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final post = widget.post;
    final vietnamTime = post.createdAt.toLocal();
    final currentUser = context.read<UserProvider>().user;
    final isMySelf = currentUser?.id == post.author.id;
    print('User ID: ${currentUser?.id}');
    print('Author ID: ${post.author.id}');
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
                        SizedBox(
                          width: 180, // Giới hạn chiều ngang
                          child: Text(
                            post.author.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          '${vietnamTime.day.toString().padLeft(2, '0')}/'
                          '${vietnamTime.month.toString().padLeft(2, '0')} '
                          '${vietnamTime.hour.toString().padLeft(2, '0')}:'
                          '${vietnamTime.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // ReportPost(post: post),
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
                Text(
                  post.description,
                  maxLines: isExpanded ? null : 3,
                  overflow:
                      isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),

                if (post.description.length > 100)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        isExpanded ? 'Thu gọn' : 'Xem thêm',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
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
              const SizedBox(width: 15),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => LikeUserListScreen(postId: widget.post.id),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      '$likeCount lượt thích',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  '${widget.post.commentCount} bình luận',
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
                icon: Image.asset(
                  isLiked
                      ? 'lib/assets/icon/like_Fill.png'
                      : 'lib/assets/icon/like_Line.png',
                  width: 30,
                  height: 30,
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
                icon: Image.asset(
                  'lib/assets/icon/comment_Line.png',
                  width: 30,
                  height: 30,
                  color: Colors.grey,
                ),
                label: Text(
                  'Bình luận',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ),
              if (!isMySelf)
                ChatPrivateButton(
                  targetUserId: post.author.id,
                  targetFullName: post.author.fullName,
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
