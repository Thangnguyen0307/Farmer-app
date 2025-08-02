import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/home/screens/home/Video_Reels/Video_Info_Overlay.dart';
import 'package:farmrole/modules/home/screens/home/Video_Reels/Video_Player_View.dart';
import 'package:flutter/material.dart';
import 'package:farmrole/shared/types/Video_Model.dart';

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

  @override
  void initState() {
    super.initState();
    itemVideo = List.from(widget.videos);
    currentPage = 1;
    if (widget.initialVideoId != null) {
      final index = widget.videos.indexWhere(
        (v) => v.id == widget.initialVideoId,
      );
      if (index != -1) {
        currentIndex = index;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pageController.jumpToPage(index);
        });
      }
    }
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
        hasMore = response.items.length == 10; // Nếu đủ 10 thì vẫn còn
      });
    } else {
      setState(() => hasMore = false); // Không còn trang mới
    }

    setState(() => isLoadingMore = false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: itemVideo.length,
        onPageChanged: (index) {
          setState(() => currentIndex = index);

          if (index >= itemVideo.length - 2 && hasMore && !isLoadingMore) {
            _loadMoreVideos();
          }
        },
        itemBuilder: (context, index) {
          final video = itemVideo[index];
          return Stack(
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
