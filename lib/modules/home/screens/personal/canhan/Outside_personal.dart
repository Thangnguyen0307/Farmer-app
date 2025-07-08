import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/widgets/Post_Tile.dart';
import 'package:farmrole/shared/types/Post_Model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class OutsidePersonalScreen extends StatefulWidget {
  const OutsidePersonalScreen({Key? key}) : super(key: key);
  @override
  State<OutsidePersonalScreen> createState() => _OutsidePersonalScreenState();
}

class _OutsidePersonalScreenState extends State<OutsidePersonalScreen> {
  final _service = PostService();
  final _scrollCtrl = ScrollController();
  List<PostModel> _posts = [];
  Pagination? _pagination;
  List<Map<String, dynamic>> _videos = [];
  bool _loading = false, _hasError = false, _showPosts = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _loadPage(1);
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_loading &&
        _pagination != null &&
        _pagination!.page < _pagination!.totalPages &&
        _scrollCtrl.position.pixels >
            _scrollCtrl.position.maxScrollExtent - 200) {
      _showPosts ? _loadPage(_pagination!.page + 1) : _loadVideos();
    }
  }

  Future<void> _loadPage(int page) async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final r = await _service.fetchUserPosts(
        context: context,
        userId: user.id,
        page: page,
        limit: 10,
      );
      if (page == 1)
        _posts = r['posts'];
      else
        _posts.addAll(r['posts']);
      _pagination = r['pagination'];
    } catch (_) {
      _hasError = true;
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadVideos() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final r = await _service.fetchLatestVideos(context: context, page: 1);
      _videos = r?['data'] ?? [];
    } catch (_) {
      _hasError = true;
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final user = context.watch<UserProvider>().user;
    final avatarProvider =
        (user?.avatar?.isNotEmpty == true)
            ? NetworkImage(AuthService.getFullAvatarUrl(user!.avatar!))
            : const AssetImage('lib/assets/image/avatar.png') as ImageProvider;
    final name = user?.fullName ?? 'Người dùng';
    final email = user?.email ?? '';

    // lỗi / loading empty
    if (_hasError && _posts.isEmpty && _showPosts) {
      return Scaffold(
        appBar: AppBar(title: const Text('Khám phá mở rộng')),
        body: Center(
          child: Text(
            'Không thể tải bài viết',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // AppBar snap/float/pinned
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            backgroundColor: primary,
            foregroundColor: Colors.white,
            title: const Text('Khám phá mở rộng'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/setting'),
              ),
            ],
          ),

          // Profile header (avatar left, text right)
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(radius: 36, backgroundImage: avatarProvider),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bài viết: ${_pagination?.total ?? _posts.length}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(height: 3, color: Colors.grey.shade300),
          ),

          // Tab header pinned
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabDelegate(
              height: 48,
              showPosts: _showPosts,
              onTapPosts: () {
                setState(() {
                  _showPosts = true;
                  _loadPage(1);
                });
              },
              onTapVideos: () {
                setState(() {
                  _showPosts = false;
                  _loadVideos();
                });
              },
            ),
          ),

          // Content: Posts or Videos
          if (_showPosts)
            if (_posts.isEmpty && !_loading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text('Chưa có bài viết')),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((ctx, i) {
                  return Column(
                    children: [
                      PostTile(post: _posts[i]),
                      if (i < _posts.length - 1)
                        Container(height: 3, color: Colors.grey.shade300),
                    ],
                  );
                }, childCount: _posts.length),
              )
          else if (_videos.isEmpty && !_loading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('Chưa có video')),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((ctx, i) {
                final v = _videos[i];
                return ListTile(
                  leading: const Icon(Icons.play_circle_fill),
                  title: Text(v['title'] ?? ''),
                  subtitle: Text(v['description'] ?? ''),
                );
              }, childCount: _videos.length),
            ),
          if (_loading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

class _SliverTabDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final bool showPosts;
  final VoidCallback onTapPosts, onTapVideos;

  _SliverTabDelegate({
    required this.height,
    required this.showPosts,
    required this.onTapPosts,
    required this.onTapVideos,
  });

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTapPosts,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bài viết',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: showPosts ? primary : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 2,
                    width: 60,
                    color: showPosts ? primary : Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onTapVideos,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Video',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: !showPosts ? primary : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 2,
                    width: 60,
                    color: !showPosts ? primary : Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SliverTabDelegate old) {
    return old.showPosts != showPosts;
  }
}
