import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/services/Filter_Service.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/home/widgets/Ads/BannerAdWidget.dart';
import 'package:farmrole/modules/home/widgets/video/Report_List_Video.dart';
import 'package:farmrole/shared/types/Video_Model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  final ScrollController _scrollController = ScrollController();
  List<VideoModel> _videos = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 10;
  final List<NativeAd> _ads = [];
  final List<bool> _adsLoaded = [];
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<String> _topTags = [];
  String _selectedTag = ''; // rỗng = không chọn
  bool _showTagBar = false;

  @override
  void initState() {
    super.initState();
    _fetchVideos();
    //phan trang video
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchVideos();
      }
    });
    //phan trang video tag
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        if (_selectedTag.isNotEmpty) {
          _fetchVideosByTag(_selectedTag);
        } else if (_searchQuery.isNotEmpty) {
          _searchVideos();
        } else {
          _fetchVideos();
        }
      }
    });
  }

  //lay list video
  Future<void> _fetchVideos() async {
    setState(() => _isLoading = true);
    final postService = PostService();

    final response = await postService.fetchLatestVideos(
      context: context,
      page: _page,
      limit: _limit,
    );

    if (response != null && response.videos.isNotEmpty) {
      setState(() {
        _videos.addAll((response.videos).map((e) => e as VideoModel));
        _page++;
        if (response.videos.length < _limit) _hasMore = false;
        _ensureEnoughAds();
      });
    } else {
      setState(() => _hasMore = false);
    }

    setState(() => _isLoading = false);
  }

  //search video bằng title
  Future<void> _searchVideos() async {
    setState(() => _isLoading = true);
    final postService = PostService();
    final response =
        _searchQuery.isEmpty
            ? await postService.fetchLatestVideos(
              context: context,
              page: _page,
              limit: _limit,
            )
            : await FilterService().searchVideos(
              context: context,
              title: _searchQuery,
              page: _page,
              limit: _limit,
            );

    if (response != null && response.videos.isNotEmpty) {
      setState(() {
        _videos.addAll(response.videos.map((e) => e as VideoModel));
        _page++;
        if (response.videos.length < _limit) _hasMore = false;
        _ensureEnoughAds();
      });
    } else {
      if (_searchQuery.isEmpty) {
        setState(() => _hasMore = false);
      } else {
        setState(() {
          _videos.clear();
          _hasMore = false;
        });
      }
    }

    setState(() => _isLoading = false);
  }

  //load top 10 tag
  void _toggleTagFilter() async {
    setState(() => _showTagBar = !_showTagBar);
    if (_topTags.isEmpty && _showTagBar) {
      final tagsData = await PostService().fetchTopTags(context);
      if (tagsData != null) {
        setState(() {
          _topTags = tagsData.map((e) => e['tag'].toString()).toList();
        });
      }
    }
  }

  //loc video bằng tag
  Future<void> _fetchVideosByTag(String tag) async {
    setState(() => _isLoading = true);
    final postService = PostService();
    final response = await postService.fetchVideosByTag(
      context: context,
      tag: tag,
      page: _page,
      limit: _limit,
    );

    if (response != null && response.videos.isNotEmpty) {
      setState(() {
        _videos.addAll(response.videos.map((e) => e as VideoModel));
        _page++;
        if (response.videos.length < _limit) _hasMore = false;
        _ensureEnoughAds();
      });
    } else {
      setState(() => _hasMore = false);
    }

    setState(() => _isLoading = false);
  }

  //ads native
  void _ensureEnoughAds() {
    final expectedAdCount = (_videos.length ~/ 5);
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
            print('❌ NativeAd failed to load: $error');
          },
        ),
      )..load();

      _ads.add(ad);
      _adsLoaded.add(false);
    }
  }

  Widget _buildVideoItem(VideoModel video) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/community-videos',
          extra: {'videos': _videos, 'initialVideoId': video.id},
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail (full width, no border radius)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: AuthService.getFullAvatarUrl(video.thumbnail ?? ""),
                  fit: BoxFit.cover,
                  placeholder:
                      (_, __) => Container(
                        color: Colors.black26,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          strokeWidth: 1.5,
                        ),
                      ),
                  errorWidget:
                      (_, __, ___) => Container(
                        color: Colors.grey,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.white,
                        ),
                      ),
                ),
                if (video.thumbnail == null || video.thumbnail!.isEmpty)
                  const Center(
                    child: Icon(
                      Icons.play_arrow,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),

          // Info section
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 0, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 18,
                      backgroundImage:
                          video.avatar.isNotEmpty
                              ? NetworkImage(
                                AuthService.getFullAvatarUrl(video.avatar),
                              )
                              : null,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 12),

                    // Title
                    Expanded(
                      child: Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Nút 3 chấm
                    ReportListVideo(video: video),
                  ],
                ),

                const SizedBox(height: 2),

                // Tên và thời gian
                Padding(
                  padding: const EdgeInsets.only(
                    left: 48,
                    right: 30,
                  ), // căn dưới avatar
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          video.uploadedBy,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Text(
                        DateFormat(
                          'dd/MM/yyyy',
                        ).format(video.createdAt.toLocal()),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagBar() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _buildTagItem('#tatca', ''), // reset
          ..._topTags.map((tag) => _buildTagItem('#$tag', tag)),
        ],
      ),
    );
  }

  Widget _buildTagItem(String label, String tag) {
    final theme = Theme.of(context);
    final isSelected = _selectedTag == tag;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTag = tag;
          _videos.clear();
          _page = 1;
          _hasMore = true;
        });
        tag.isEmpty ? _fetchVideos() : _fetchVideosByTag(tag);
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? theme.colorScheme.primary : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalItemCount =
        _videos.length + (_videos.length ~/ 5) + (_hasMore ? 1 : 0);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        toolbarHeight: 56,
        titleSpacing: 0,
        title: Row(
          children: [
            // Search field
            Expanded(
              child: Container(
                height: 40,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200, // nền xám mờ
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    final q = value.trim();
                    setState(() {
                      _searchQuery = q;
                      _videos.clear();
                      _page = 1;
                      _hasMore = true;
                      _selectedTag = '';
                    });
                    _searchVideos();
                  },
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm video...',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    suffixIcon:
                        _searchController.text.isEmpty
                            ? null
                            : IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _videos.clear();
                                  _page = 1;
                                  _hasMore = true;
                                  _selectedTag = '';
                                });
                                _fetchVideos();
                              },
                            ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),

            // Filter icon
            IconButton(
              icon: Image.asset(
                'lib/assets/icon/Filter.png',
                width: 24,
                height: 24,
                color: Colors.grey.shade800,
              ),
              onPressed: _toggleTagFilter,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_showTagBar) _buildTagBar(),
          Expanded(
            child:
                _videos.isEmpty && !_isLoading
                    ? const Center(
                      child: Text("Không tìm thấy video bạn mong muốn"),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      itemCount: totalItemCount,
                      itemBuilder: (_, index) {
                        if (index >= _videos.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // Nếu là vị trí ad (sau mỗi 5 item)
                        if (index != 0 && index % 6 == 5) {
                          final adIndex = index ~/ 6;
                          if (_ads.length > adIndex && _adsLoaded[adIndex]) {
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              height: 350,
                              child: AdWidget(ad: _ads[adIndex]),
                            );
                          } else {
                            return const SizedBox(height: 350);
                          }
                        }

                        final videoIndex = index - (index ~/ 6);
                        final video = _videos[videoIndex];
                        return _buildVideoItem(video);
                      },
                    ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          child: SizedBox(
            height: 40,
            child: Center(child: const BannerAdWidget()),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final ad in _ads) {
      ad.dispose();
    }
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
