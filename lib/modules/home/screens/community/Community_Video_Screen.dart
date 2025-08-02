import 'package:flutter/material.dart';
import 'package:farmrole/modules/home/widgets/video/Video_Tile.dart';
import 'package:farmrole/shared/types/Video_Model.dart';

class CommunityVideoScreen extends StatefulWidget {
  final List<VideoModel> videos;
  final String? initialVideoId;

  const CommunityVideoScreen({
    super.key,
    required this.videos,
    this.initialVideoId,
  });

  @override
  State<CommunityVideoScreen> createState() => _CommunityVideoScreenState();
}

class _CommunityVideoScreenState extends State<CommunityVideoScreen> {
  late ScrollController _scrollController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialVideoId != null) {
        final index = widget.videos.indexWhere(
          (v) => v.id == widget.initialVideoId,
        );
        if (index != -1) {
          _scrollController.animateTo(
            index * 350,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          currentIndex = index;
        }
      }
    });
  }

  void _onScroll() {
    final scrollOffset = _scrollController.offset;
    final estimatedIndex = (scrollOffset / 350).round();
    if (estimatedIndex != currentIndex) {
      setState(() {
        currentIndex = estimatedIndex;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Video Cộng Đồng',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black, size: 22),
            onPressed: () {
              // Search action nếu cần
            },
          ),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: widget.videos.length,
        itemBuilder: (context, index) {
          if ((index - currentIndex).abs() <= 1) {
            return VideoTile(video: widget.videos[index]);
          }
          return const SizedBox(height: 350);
        },
      ),
    );
  }
}
