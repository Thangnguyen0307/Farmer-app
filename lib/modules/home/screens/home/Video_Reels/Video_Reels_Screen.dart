import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/home/screens/home/Video_Reels/Video_Info_Overlay.dart';
import 'package:farmrole/modules/home/screens/home/Video_Reels/Video_Player_View.dart';
import 'package:farmrole/modules/home/widgets/Ads/NativeAdVideoWidget.dart';
import 'package:farmrole/modules/home/widgets/Ads/NativeAdWidget.dart';
import 'package:flutter/material.dart';
import 'package:farmrole/shared/types/Video_Model.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class VideoReelsScreen extends StatefulWidget {
  final List<VideoModel> videos;
  final String? initialVideoId;

  const VideoReelsScreen({
    super.key,
    required this.videos,
    this.initialVideoId,
  });

  @override
  State<VideoReelsScreen> createState() => _VideoReelsScreenState();
}

class _VideoReelsScreenState extends State<VideoReelsScreen> {
  PageController _pageController = PageController();
  int currentIndex = 0;
  int currentPage = 1;
  bool hasMore = true;
  bool isLoadingMore = false;
  List<VideoModel> itemVideo = [];
  List<NativeAd> _ads = [];
  List<FeedItem> feedItems = [];

  @override
  void initState() {
    super.initState();
    itemVideo = List.from(widget.videos);
    currentPage = 1;
    buildFeedItems();
    if (widget.initialVideoId != null) {
      final index = feedItems.indexWhere(
        (item) =>
            item.type == FeedItemType.video &&
            item.video?.id == widget.initialVideoId,
      );
      if (index != -1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(index);
          }
        });
      }
    }
    final expectedAdCount = (itemVideo.length ~/ 5);
    preloadAds(expectedAdCount);
  }

  Future<void> _loadMoreVideos() async {
    setState(() => isLoadingMore = true);

    final response = await PostService().fetchLatestVideos(
      context: context,
      page: currentPage + 1,
      limit: 10,
    );

    if (response != null && response.items.isNotEmpty) {
      setState(() {
        itemVideo.addAll(response.items);
        currentPage++;
        hasMore = response.items.length == 10;
        final expectedAdCount = (itemVideo.length ~/ 5);
        preloadAds(expectedAdCount);
      });
    } else {
      setState(() => hasMore = false);
    }

    setState(() => isLoadingMore = false);
  }

  //load ads
  void preloadAds(int targetAdCount) {
    final adsToLoad = targetAdCount - _ads.length;
    for (int i = 0; i < adsToLoad; i++) {
      final ad = NativeAd(
        adUnitId: 'ca-app-pub-3940256099942544/2247696110',
        factoryId: 'native_ad_factory',
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            setState(() {
              buildFeedItems();
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            print('❌ Native ad failed: $error');
          },
        ),
      )..load();
      _ads.add(ad);
    }
  }

  void buildFeedItems() {
    feedItems.clear();
    int videoIndex = 0;
    int adIndex = 0;

    while (videoIndex < itemVideo.length) {
      feedItems.add(FeedItem.video(itemVideo[videoIndex]));
      videoIndex++;
      if (videoIndex % 5 == 0 && adIndex < _ads.length) {
        feedItems.add(FeedItem.ad(_ads[adIndex]));
        adIndex++;
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final ad in _ads) {
      ad.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: feedItems.length,
        onPageChanged: (index) {
          final item = feedItems[index];
          setState(() {
            if (item.type == FeedItemType.video) {
              currentIndex = index;
            } else {
              currentIndex = -1;
            }
          });

          if (index >= feedItems.length - 2 && hasMore && !isLoadingMore) {
            _loadMoreVideos();
          }
        },
        itemBuilder: (context, index) {
          final item = feedItems[index];

          if (item.type == FeedItemType.ad && item.ad != null) {
            return Stack(
              children: [
                Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: NativeAdWidget(ad: item.ad!),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            );
          }

          final video = item.video!;
          return Stack(
            key: ValueKey('video_$index'),
            children: [
              VideoPlayerView(
                videoUrl: video.youtubeLink,
                isPlaying: index == currentIndex,
              ),
              VideoInfoOverlay(video: video, index: index, videos: itemVideo),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

enum FeedItemType { video, ad }

class FeedItem {
  final FeedItemType type;
  final VideoModel? video;
  final NativeAd? ad;

  FeedItem.video(this.video) : type = FeedItemType.video, ad = null;

  FeedItem.ad(this.ad) : type = FeedItemType.ad, video = null;
}
