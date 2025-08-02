import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/widgets/Post/Post_Tile.dart';
import 'package:farmrole/modules/home/widgets/video/Video_Tile.dart';
import 'package:farmrole/shared/types/Post_Model.dart';
import 'package:farmrole/shared/types/Video_Model.dart' as video_model;
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
  List<video_model.VideoModel> _videos = [];
  bool _loading = false, _hasError = false, _showPosts = true;
  video_model.Pagination? _videoPagination;
  @override
  void initState() {
    super.initState();
    _loadPage(1);
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_loading) return;

    if (_showPosts &&
        _pagination != null &&
        _pagination!.page < _pagination!.totalPages &&
        _scrollCtrl.position.pixels >
            _scrollCtrl.position.maxScrollExtent - 200) {
      _loadPage(_pagination!.page + 1);
    }

    if (!_showPosts &&
        _videoPagination != null &&
        _videoPagination!.page < _videoPagination!.totalPages &&
        _scrollCtrl.position.pixels >
            _scrollCtrl.position.maxScrollExtent - 200) {
      _loadVideos(page: _videoPagination!.page + 1);
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

  Future<void> _loadVideos({int page = 1}) async {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      final r = await _service.fetchVideosByUserId(
        context: context,
        userId: user.id,
        page: page,
        limit: 10,
      );
      if (r != null) {
        if (page == 1) {
          _videos = r.videos;
        } else {
          _videos.addAll(r.videos);
        }
        _videoPagination = r.pagination;
      }
    } catch (_) {
      _hasError = true;
    } finally {
      setState(() => _loading = false);
    }
  }

  //ham gọi my profile để load lại rank + point
  Future<void> _reloadProfile() async {
    final authService = AuthService();
    await authService.myProfile(context);

    try {
      if (!mounted) return;

      final updatedUser = context.read<UserProvider>().user;
      if (updatedUser == null) throw Exception("User chưa đăng nhập");

      showDialog(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              title: const Text('Cập nhật thành công'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (updatedUser.rank != null)
                    Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Hạng: ${updatedUser.rank}')),
                      ],
                    ),
                  const SizedBox(height: 8),
                  if (updatedUser.totalPoint != null)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Điểm: ${updatedUser.totalPoint}'),
                        ),
                      ],
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // đóng dialog
                  },
                  child: const Text('Đóng'),
                ),
              ],
            ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder:
            (dialogContext) => AlertDialog(
              title: const Text('Lỗi'),
              content: Text('Không thể tải dữ liệu người dùng.\n$e'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // đóng dialog
                  },
                  child: const Text('Đóng'),
                ),
              ],
            ),
      );
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
            : const AssetImage('lib/assets/icon/person_Fill.png')
                as ImageProvider;
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

    return WillPopScope(
      onWillPop: () async {
        context.go('/home');
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: CustomScrollView(
          controller: _scrollCtrl,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              backgroundColor: Colors.white,
              foregroundColor: theme.colorScheme.primary,
              leading: Container(
                height: 50,
                width: 50,
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.only(right: 2),
                child: Image.asset(
                  "lib/assets/image/LogoCut2.png",
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                'Trang cá nhân',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
              actions: [
                IconButton(
                  icon: Image.asset(
                    'lib/assets/icon/Setting.png',
                    width: 38,
                    height: 38,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () => context.push('/setting'),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                          if (user?.rank != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.emoji_events,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  user!.rank!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (user?.totalPoint != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${user!.totalPoint} điểm',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Image.asset(
                        'lib/assets/icon2/Reload.png',
                        width: 35,
                        height: 35,
                        color: theme.colorScheme.primary,
                      ),
                      tooltip: 'Tải lại rank & điểm',
                      onPressed: _reloadProfile,
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(height: 3, color: Colors.grey.shade300),
            ),

            // Tab post + video
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
                pagination: _pagination,
                posts: _posts,
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
                        PostTile(
                          post: _posts[i],
                          onDeleted: () {
                            setState(() {
                              _posts.removeAt(i);
                              if (_pagination != null) {
                                _pagination = _pagination!.copyWith(
                                  total: _pagination!.total - 1,
                                );
                              }
                            });
                          },
                          onUpdated: () async {
                            await _loadPage(1);
                          },
                        ),

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
                  final video = _videos[i];
                  return Column(
                    children: [
                      VideoTile(video: video),
                      if (i < _videos.length - 1)
                        Container(height: 3, color: Colors.grey.shade300),
                    ],
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
      ),
    );
  }
}

class _SliverTabDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final bool showPosts;
  final VoidCallback onTapPosts, onTapVideos;
  final Pagination? pagination;
  final List<PostModel> posts;

  _SliverTabDelegate({
    required this.height,
    required this.showPosts,
    required this.onTapPosts,
    required this.onTapVideos,
    required this.pagination,
    required this.posts,
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
    final totalPosts = pagination?.total ?? posts.length;
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
                    'Bài viết: $totalPosts',
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
    return old.showPosts != showPosts ||
        old.pagination != pagination ||
        old.posts.length != posts.length;
  }
}
