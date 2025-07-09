import 'package:flutter/material.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/home/widgets/Post/Post_Community.dart';
import 'package:farmrole/shared/types/Post_Model.dart';

class CommunityPostTab extends StatefulWidget {
  const CommunityPostTab({Key? key}) : super(key: key);
  @override
  State<CommunityPostTab> createState() => _CommunityPostTabState();
}

class _CommunityPostTabState extends State<CommunityPostTab> {
  final _service = PostService();

  List<PostModel> _posts = [];
  Pagination? _pag;
  bool _loading = false, _error = false;

  @override
  void initState() {
    super.initState();
    _loadPage(1);
  }

  Future<void> _loadPage(int page) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final r = await _service.fetchAllPosts(
        context: context,
        page: page,
        limit: 10,
      );
      setState(() {
        if (page == 1)
          _posts = r['posts'];
        else
          _posts.addAll(r['posts']);
        _pag = r['pagination'];
      });
    } catch (_) {
      setState(() => _error = true);
    } finally {
      setState(() => _loading = false);
    }
  }

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200 &&
        !_loading &&
        _pag != null &&
        _pag!.page < _pag!.totalPages) {
      _loadPage(_pag!.page + 1);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe scroll để phân trang
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (_error)
            SliverToBoxAdapter(
              child: Center(
                child: Text(
                  'Không thể tải bài viết',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            ),

          if (_posts.isEmpty && _loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

          if (_posts.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate((ctx, i) {
                return Column(
                  children: [
                    PostCommunity(post: _posts[i]),
                    const Divider(height: 1, color: Colors.grey),
                  ],
                );
              }, childCount: _posts.length),
            ),

          // Spinner ở cuối nếu đang load trang kế
          if (_loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

          // Spacer ở cuối nếu đã load hết
          if (!_loading && _pag != null && _pag!.page >= _pag!.totalPages)
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}
