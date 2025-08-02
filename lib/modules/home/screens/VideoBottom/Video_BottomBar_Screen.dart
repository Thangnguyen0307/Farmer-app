import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/home/screens/home/Video_Reels/Video_Info_Overlay.dart';
import 'package:farmrole/modules/home/screens/home/Video_Reels/Video_Player_View.dart';
import 'package:farmrole/shared/types/Video_Model.dart';

class VideoBottombarScreen extends StatefulWidget {
  const VideoBottombarScreen({super.key});

  @override
  State<VideoBottombarScreen> createState() => _VideoBottombarScreenState();
}

class _VideoBottombarScreenState extends State<VideoBottombarScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  int currentPage = 1;
  bool hasMore = true;
  bool isLoadingMore = false;
  List<VideoModel> itemVideo = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialVideos();
  }

  Future<void> _fetchInitialVideos() async {
    final response = await PostService().fetchLatestVideos(
      context: context,
      page: currentPage,
      limit: 10,
    );

    if (response != null && response.items.isNotEmpty) {
      setState(() {
        itemVideo = response.items;
        hasMore = response.items.length == 10;
      });
    } else {
      setState(() => hasMore = false);
    }
  }

  Future<void> _loadMoreVideos() async {
    if (isLoadingMore || !hasMore) return;

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
      });
    } else {
      setState(() => hasMore = false);
    }

    setState(() => isLoadingMore = false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        context.go('/home');
        break;
      case 2:
        context.go('/community');
        break;
      case 3:
        context.go('/Outside');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabButton('Video', 0),
            _buildTabButton('Trang chủ', 1),
            _buildTabButton('Bài viết', 2),
            _buildTabButton('Cá nhân', 3),
          ],
        ),
      ),
      body: _buildVideoTab(),
    );
  }

  Widget _buildTabButton(String label, int index) {
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          color: index == 0 ? Colors.white : Colors.white70,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildVideoTab() {
    return itemVideo.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : PageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemCount: itemVideo.length,
          onPageChanged: (index) {
            setState(() => currentIndex = index);

            if (index >= itemVideo.length - 2 && hasMore) {
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
              ],
            );
          },
        );
  }
}
