import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/services/Youtube_Service.dart';
import 'package:farmrole/modules/home/screens/home/Youtube/Youtube_Player_Screen.dart';
import 'package:farmrole/modules/home/widgets/Ads/BannerAdWidget.dart';
import 'package:farmrole/modules/home/widgets/video/Report_List_Video.dart';
import 'package:farmrole/shared/types/Youtube_Video_Model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

class CategoryVideoListScreen extends StatefulWidget {
  final String channelId;

  const CategoryVideoListScreen({super.key, required this.channelId});

  @override
  State<CategoryVideoListScreen> createState() =>
      _CategoryVideoListScreenState();
}

class _CategoryVideoListScreenState extends State<CategoryVideoListScreen> {
  final ScrollController _scrollController = ScrollController();
  List<YoutubeVideoModel> _videos = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 10;
  final List<NativeAd> _ads = [];
  final List<bool> _adsLoaded = [];

  @override
  void initState() {
    super.initState();
    _fetchVideos();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchVideos();
      }
    });
  }

  Future<void> _fetchVideos() async {
    setState(() => _isLoading = true);
    try {
      final result = await YoutubeService.fetchVideosByChannel(
        context: context,
        channelId: widget.channelId,
        page: _page,
        limit: _limit,
      );

      if (result.isNotEmpty) {
        setState(() {
          _videos.addAll(result);
          _page++;
          if (result.length < _limit) _hasMore = false;
          _ensureEnoughAds();
        });
      } else {
        setState(() => _hasMore = false);
      }
    } catch (e) {
      print('❌ Fetch failed: $e');
      setState(() => _hasMore = false);
    }

    setState(() => _isLoading = false);
  }

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
            setState(() => _adsLoaded[index] = true);
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

  bool _isAdIndex(int index) {
    return (index + 1) % 6 == 0;
  }

  int _getVideoIndex(int index) {
    return index - ((index + 1) ~/ 6);
  }

  Widget _buildVideoItem(YoutubeVideoModel video) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => YoutubePlayerScreen(videoId: video.videoId),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl:
                  (video.thumbnail != null && video.thumbnail.trim().isNotEmpty)
                      ? video.thumbnail
                      : 'https://i.ytimg.com/vi/${video.videoId}/mqdefault.jpg',
              fit: BoxFit.cover,
              placeholder:
                  (_, __) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
              errorWidget:
                  (_, __, ___) => const Icon(Icons.image_not_supported),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 0, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                        AuthService.getFullAvatarUrl(video.channel.title),
                      ),
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 12),
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
                  ],
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(left: 48, right: 30),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          video.channel.title,
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

  @override
  Widget build(BuildContext context) {
    int totalItemCount =
        _videos.length + (_videos.length ~/ 5) + (_hasMore ? 1 : 0);

    return Scaffold(
      appBar: AppBar(title: Text("Danh sách video channel"), centerTitle: true),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: totalItemCount,
        itemBuilder: (_, index) {
          if (_getVideoIndex(index) >= _videos.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (_isAdIndex(index)) {
            final adIndex = (index + 1) ~/ 6 - 1;
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

          final videoIndex = _getVideoIndex(index);
          final video = _videos[videoIndex];
          return _buildVideoItem(video);
        },
      ),
      bottomNavigationBar: const SafeArea(
        child: SizedBox(height: 40, child: BannerAdWidget()),
      ),
    );
  }

  @override
  void dispose() {
    for (final ad in _ads) {
      ad.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }
}
