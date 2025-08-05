import 'package:farmrole/modules/home/widgets/Ads/NativeAdWidget.dart';
import 'package:flutter/material.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/home/widgets/Post/Post_Community.dart';
import 'package:farmrole/shared/types/Post_Model.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CommunityPostTab extends StatefulWidget {
  const CommunityPostTab({Key? key}) : super(key: key);
  @override
  State<CommunityPostTab> createState() => _CommunityPostTabState();
}

class _CommunityPostTabState extends State<CommunityPostTab> {
  final _service = PostService();

  List<PostModel> _posts = [];
  List<NativeAd> _ads = [];
  List<bool> _adsLoaded = [];
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
      _ensureEnoughAds();
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

  //load ads
  void _ensureEnoughAds() {
    final expectedAdCount = (_posts.length ~/ 5); // mỗi 5 post 1 ad
    final missing = expectedAdCount - _ads.length;
    for (int i = 0; i < missing; i++) {
      final index = _ads.length;
      final ad = NativeAd(
        adUnitId: 'ca-app-pub-3940256099942544/2247696110',
        factoryId: 'native_ad_factory',
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            setState(() {
              _adsLoaded[index] = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            print('❌ NativeAd preload failed: $error');
          },
        ),
      )..load();
      _ads.add(ad);
      _adsLoaded.add(false);
    }
  }

  @override
  void dispose() {
    for (final ad in _ads) {
      ad.dispose();
    }
    super.dispose();
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
                final isAdIndex = (i + 1) % 6 == 0;
                if (isAdIndex) {
                  final adIndex = (i + 1) ~/ 6 - 1;
                  if (adIndex < _ads.length && _adsLoaded[adIndex]) {
                    return Container(
                      key: ValueKey('ad_$i'),
                      height: 351,
                      child: NativeAdWidget(ad: _ads[adIndex]),
                    );
                  } else {
                    return const SizedBox(height: 351);
                  }
                }

                final actualIndex = i - (i ~/ 6);
                final post = _posts[actualIndex];
                return Column(
                  children: [
                    PostCommunity(post: post),
                    const Divider(height: 1, color: Colors.grey),
                  ],
                );
              }, childCount: _posts.length + (_posts.length ~/ 5)),
            ),
          if (_loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

          if (!_loading && _pag != null && _pag!.page >= _pag!.totalPages)
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}
