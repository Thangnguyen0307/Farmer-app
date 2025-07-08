import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/shared/types/Post_Model.dart';
import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final PostService _postService = PostService();
  final ScrollController _scrollController = ScrollController();

  List<PostModel> _posts = [];
  Pagination? _pagination;
  bool _loading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadPosts(1);
    _scrollController.addListener(() {
      if (!_loading &&
          _pagination != null &&
          _pagination!.page < _pagination!.totalPages &&
          _scrollController.position.pixels >
              _scrollController.position.maxScrollExtent - 200) {
        _loadPosts(_pagination!.page + 1);
      }
    });
  }

  Future<void> _loadPosts(int page) async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final result = await _postService.fetchAllPosts(
        context: context,
        page: page,
        limit: 10,
      );
      setState(() {
        if (page == 1) {
          _posts = result['posts'];
        } else {
          _posts.addAll(result['posts']);
        }
        _pagination = result['pagination'];
      });
    } catch (_) {
      setState(() => _hasError = true);
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildPostItem(PostModel post) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (post.author.avatar?.isNotEmpty == true)
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    AuthService.getFullAvatarUrl(post.author.avatar),
                  ),
                  backgroundColor: Colors.grey[200],
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
                '${post.createdAt.hour}:${post.createdAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            post.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(post.description, style: const TextStyle(fontSize: 14)),

          // Ảnh (nếu có)
          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: post.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder:
                    (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        AuthService.getFullAvatarUrl(post.images[i]),
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        appBar: AppBar(title: Text('Cộng đồng')),
        body: Center(child: Text("Không thể tải bài đăng")),
      );
    }
    if (_posts.isEmpty && _loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Cộng đồng')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Cộng đồng')),
      body: RefreshIndicator(
        onRefresh: () => _loadPosts(1),
        child: ListView.separated(
          controller: _scrollController,
          itemCount: _posts.length + (_loading ? 1 : 0),
          separatorBuilder:
              (_, __) => Container(height: 3, color: Colors.grey.shade300),
          itemBuilder: (_, index) {
            if (index == _posts.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return _buildPostItem(_posts[index]);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
