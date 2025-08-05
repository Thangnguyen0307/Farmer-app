import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/home/screens/home/Youtube/Channel_Video_Screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmrole/shared/types/Youtube_Channel_Model.dart';
import 'package:farmrole/modules/auth/services/Youtube_Service.dart';

class YoutubeChannelListScreen extends StatefulWidget {
  final String categoryId;
  const YoutubeChannelListScreen({Key? key, required this.categoryId})
    : super(key: key);

  @override
  _YoutubeChannelListScreenState createState() =>
      _YoutubeChannelListScreenState();
}

class _YoutubeChannelListScreenState extends State<YoutubeChannelListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<YoutubeChannelModel> _channels = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 10;
  String? _categoryName;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    setState(() => _isLoading = true);
    try {
      final newItems = await YoutubeService.fetchChannelsByCategory(
        context: context,
        categoryId: widget.categoryId,
        page: _page,
        limit: _limit,
      );
      if (newItems.length < _limit) _hasMore = false;
      if (_categoryName == null && newItems.isNotEmpty) {
        _categoryName = newItems.first.category.name;
      }
      setState(() {
        _channels.addAll(newItems);
        _page++;
      });
    } catch (_) {
      // bạn có thể show lỗi khi cần
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Widget _buildChannelCard(YoutubeChannelModel channel) {
    final localTime = channel.createdAt.toLocal();
    final createdAt =
        "${localTime.day.toString().padLeft(2, '0')}/"
        "${localTime.month.toString().padLeft(2, '0')}/"
        "${localTime.year}";

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryVideoListScreen(channelId: channel.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh cover
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(0),
              ),
              child: Image.network(
                AuthService.getFullAvatarUrl(channel.imageThumbnail),
                width: double.infinity,
                height: 180,
                fit: BoxFit.fill,
                errorBuilder:
                    (_, __, ___) => Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image, size: 60, color: Colors.grey),
                      ),
                    ),
              ),
            ),

            // Tiêu đề & ngày đăng
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    createdAt,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _categoryName ?? 'Đang tải...';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: theme.colorScheme.primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _channels.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 3),
        itemBuilder: (context, index) {
          if (index >= _channels.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            );
          }
          return _buildChannelCard(_channels[index]);
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
