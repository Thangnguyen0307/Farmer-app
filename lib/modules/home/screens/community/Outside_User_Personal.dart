import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/services/Follow_Service.dart';
import 'package:farmrole/modules/auth/services/Personal_Service.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/widgets/Follow/Follow_Button.dart';
import 'package:farmrole/modules/home/widgets/Follow/Follow_List_Screen.dart';
import 'package:farmrole/modules/home/widgets/Post/Comment_Option_Menu.dart';
import 'package:farmrole/modules/home/widgets/Post/Post_Personal.dart';
import 'package:farmrole/modules/home/widgets/Post/Report_User.dart';
import 'package:farmrole/modules/home/widgets/video/Chat_Private_Video_Button.dart';
import 'package:farmrole/modules/home/widgets/video/Video_Tile.dart';
import 'package:farmrole/modules/home/widgets/Farm/Farm_Tile.dart';
import 'package:farmrole/shared/types/Farm_Model.dart';
import 'package:farmrole/shared/types/Post_Model.dart' as post;
import 'package:farmrole/shared/types/User_Model.dart';
import 'package:farmrole/shared/types/Video_Model.dart' as video;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

enum OutsideUserTab { posts, videos, farms }

class OutsideUserPersonal extends StatefulWidget {
  final String userId;
  const OutsideUserPersonal({super.key, required this.userId});

  @override
  State<OutsideUserPersonal> createState() => _OutsideUserPersonalState();
}

class _OutsideUserPersonalState extends State<OutsideUserPersonal> {
  final _scrollCtrl = ScrollController();
  final _personal = PersonalService();
  final _postService = PostService();

  List<post.PostModel> _posts = [];
  List<video.VideoModel> _videos = [];
  List<FarmModel> _farms = [];

  post.Pagination? _pagination;
  video.Pagination? _videoPagination;

  bool _loading = false, _hasError = false;
  UserModel? _outsideUser;
  OutsideUserTab _currentTab = OutsideUserTab.posts;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _loadOutsideUser().then((_) {
      _loadPage(1);
    });
    _scrollCtrl.addListener(_onScroll);
  }

  Future<void> _loadOutsideUser() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final user = await _personal.fetchUserInfoOnly(
        context: context,
        userId: widget.userId,
      );
      setState(() {
        _outsideUser = user;
        _farms = user?.farms ?? [];
      });
      print('Fetched farms: ${user?.farms}');
      print('Fetched yourFollow: ${user?.yourFollow}');
    } catch (e, stacktrace) {
      print('>>> ERROR fetchUserInfoOnly: $e');
      print(stacktrace);
      _hasError = true;
    } finally {
      setState(() => _loading = false);
    }
  }

  void _onScroll() {
    if (_loading) return;

    if (_currentTab == OutsideUserTab.posts &&
        _pagination != null &&
        _pagination!.page < _pagination!.totalPages &&
        _scrollCtrl.position.pixels >
            _scrollCtrl.position.maxScrollExtent - 200) {
      _loadPage(_pagination!.page + 1);
    }

    if (_currentTab == OutsideUserTab.videos &&
        _videoPagination != null &&
        _videoPagination!.page < _videoPagination!.totalPages &&
        _scrollCtrl.position.pixels >
            _scrollCtrl.position.maxScrollExtent - 200) {
      _loadVideos(page: _videoPagination!.page + 1);
    }
  }

  Future<void> _loadPage(int page) async {
    if (_outsideUser == null) return;

    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      final r = await _postService.fetchUserPosts(
        context: context,
        userId: widget.userId,
        page: page,
        limit: 10,
      );

      final author = post.AuthorModel(
        id: _outsideUser!.id,
        fullName: _outsideUser!.fullName,
        avatar: _outsideUser!.avatar ?? '',
      );

      final newPosts =
          (r['posts'] as List<post.PostModel>)
              .map((p) => p.copyWith(author: author))
              .toList();

      if (page == 1)
        _posts = newPosts;
      else
        _posts.addAll(newPosts);

      _pagination = r['pagination'];
    } catch (e, stacktrace) {
      print('>>> ERROR fetchUserWithResources: $e');
      print(stacktrace);
      _hasError = true;
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadVideos({int page = 1}) async {
    if (_outsideUser == null) return;

    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      final r = await _postService.fetchVideosByUserId(
        context: context,
        userId: widget.userId,
        page: page,
        limit: 10,
      );
      if (r != null) {
        if (page == 1)
          _videos = r.videos;
        else
          _videos.addAll(r.videos);
        _videoPagination = r.pagination;
      }
    } catch (e, stacktrace) {
      print('>>> ERROR fetchVideosByUserId: $e');
      print(stacktrace);
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
    final avatarProvider =
        (_outsideUser?.avatar?.isNotEmpty == true)
            ? NetworkImage(AuthService.getFullAvatarUrl(_outsideUser!.avatar!))
            : const AssetImage('lib/assets/icon/person_Fill.png')
                as ImageProvider;

    final name = _outsideUser?.fullName ?? 'Người dùng';
    final email = _outsideUser?.email ?? '';
    final currentUser = context.read<UserProvider>().user;
    final token = context.read<UserProvider>().user?.token;
    final isMySelf = widget.userId == currentUser?.id;
    print('👉 Pushing to followers with userId: ${_outsideUser?.id}');
    if (_hasError && _posts.isEmpty && _currentTab == OutsideUserTab.posts) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trang cá nhân')),
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
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            backgroundColor: primary,
            foregroundColor: Colors.white,
            centerTitle: true,
            title: Text(
              "Trang cá nhân",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            actions: [
              if (!isMySelf)
                ChatPrivateVideoButton(
                  targetUserId: widget.userId,
                  targetFullName: name,
                ),
            ],
          ),
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
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (_outsideUser?.rank != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.emoji_events,
                                    size: 16,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _outsideUser!.rank!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(width: 12),
                            if (_outsideUser?.totalPoint != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_outsideUser!.totalPoint} điểm',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.amber.shade800,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        if (!isMySelf && token != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      final userId = widget.userId;
                                      try {
                                        final users = await FollowService()
                                            .fetchFollowing(
                                              context: context,
                                              userId: userId,
                                            );
                                        if (context.mounted) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => FollowListScreen(
                                                    title: 'Đang theo dõi',
                                                    users: users,
                                                  ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        print('Lỗi fetch following: $e');
                                      }
                                    },
                                    child: Text(
                                      'Đang theo dõi: ${_outsideUser?.followCount ?? 0}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  GestureDetector(
                                    onTap: () async {
                                      final userId = widget.userId;
                                      try {
                                        final users = await FollowService()
                                            .fetchFollowers(
                                              context: context,
                                              userId: userId,
                                            );
                                        if (context.mounted) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => FollowListScreen(
                                                    title: 'Người theo dõi',
                                                    users: users,
                                                  ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        print('Lỗi fetch followers: $e');
                                      }
                                    },
                                    child: Text(
                                      'Người theo dõi: ${_outsideUser?.followerCount ?? 0}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              FollowButton(
                                targetUserId: widget.userId,
                                token: token,
                                isFollowingInitial:
                                    _outsideUser?.yourFollow ?? false,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  if (!isMySelf) ReportUser(targetUserId: widget.userId),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(height: 3, color: Colors.grey.shade300),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabDelegate(
              height: 48,
              currentTab: _currentTab,
              onTapPosts: () {
                setState(() {
                  _currentTab = OutsideUserTab.posts;
                  _posts.clear();
                  _pagination = null;
                });
                _loadPage(1);
              },
              onTapVideos: () {
                setState(() {
                  _currentTab = OutsideUserTab.videos;
                  _videos.clear();
                  _videoPagination = null;
                });
                _loadVideos();
              },
              onTapFarms: () {
                setState(() {
                  _currentTab = OutsideUserTab.farms;
                });
              },
              pagination: _pagination,
              videoPagination: _videoPagination,
              posts: _posts,
            ),
          ),
          switch (_currentTab) {
            OutsideUserTab.posts =>
              _posts.isEmpty && !_loading
                  ? _buildEmpty('Chưa có bài viết')
                  : _buildPostList(),
            OutsideUserTab.videos =>
              _videos.isEmpty && !_loading
                  ? _buildEmpty('Chưa có video')
                  : _buildVideoList(),
            OutsideUserTab.farms =>
              _farms.isEmpty && !_loading
                  ? _buildEmpty('Chưa có farm')
                  : _buildFarmList(),
          },
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

  Widget _buildEmpty(String message) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: Text(message)),
      ),
    );
  }

  Widget _buildPostList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((ctx, i) {
        return Column(
          children: [
            PostPersonal(post: _posts[i]),
            if (i < _posts.length - 1)
              Container(height: 3, color: Colors.grey.shade300),
          ],
        );
      }, childCount: _posts.length),
    );
  }

  Widget _buildVideoList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((ctx, i) {
        return Column(
          children: [
            VideoTile(video: _videos[i]),
            if (i < _videos.length - 1)
              Container(height: 3, color: Colors.grey.shade300),
          ],
        );
      }, childCount: _videos.length),
    );
  }

  Widget _buildFarmList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((ctx, i) {
        return Column(
          children: [
            FarmTile(farm: _farms[i]),
            if (i < _farms.length - 1)
              Container(height: 3, color: Colors.grey.shade300),
          ],
        );
      }, childCount: _farms.length),
    );
  }
}

class _SliverTabDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final OutsideUserTab currentTab;
  final VoidCallback onTapPosts, onTapVideos, onTapFarms;
  final post.Pagination? pagination;
  final List<post.PostModel> posts;
  final video.Pagination? videoPagination;

  _SliverTabDelegate({
    required this.height,
    required this.currentTab,
    required this.onTapPosts,
    required this.onTapVideos,
    required this.onTapFarms,
    required this.pagination,
    required this.posts,
    required this.videoPagination,
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
    final totalVideos = videoPagination?.total ?? 0;

    Widget buildTab(String label, bool isActive, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isActive ? primary : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: 60,
                color: isActive ? primary : Colors.transparent,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Row(
        children: [
          buildTab(
            'Bài viết($totalPosts)',
            currentTab == OutsideUserTab.posts,
            onTapPosts,
          ),
          buildTab('Video', currentTab == OutsideUserTab.videos, onTapVideos),
          buildTab(
            'Trang trại',
            currentTab == OutsideUserTab.farms,
            onTapFarms,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SliverTabDelegate old) {
    return old.currentTab != currentTab ||
        old.pagination != pagination ||
        old.videoPagination != videoPagination ||
        old.posts.length != posts.length;
  }
}
