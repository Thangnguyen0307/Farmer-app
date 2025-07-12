import 'package:farmrole/modules/auth/services/Filter_Service.dart';
import 'package:farmrole/modules/home/widgets/Post/Video_Tile.dart';
import 'package:flutter/material.dart';
import 'package:farmrole/shared/types/Video_Model.dart';

class SearchVideoScreen extends StatefulWidget {
  const SearchVideoScreen({Key? key}) : super(key: key);
  @override
  State<SearchVideoScreen> createState() => _SearchVideoScreenState();
}

class _SearchVideoScreenState extends State<SearchVideoScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<VideoModel> _videos = [];
  int _page = 1, _limit = 10;
  bool _loading = false, _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_loading &&
        _hasMore &&
        _scrollCtrl.position.pixels >
            _scrollCtrl.position.maxScrollExtent - 200) {
      _searchVideos(loadMore: true);
    }
  }

  Future<void> _searchVideos({bool loadMore = false}) async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;
    if (_loading) return;

    setState(() {
      _loading = true;
      if (!loadMore) {
        _videos.clear();
        _page = 1;
        _hasMore = true;
      }
    });

    final res = await FilterService().searchVideos(
      context: context,
      title: query,
      page: _page,
      limit: _limit,
    );
    if (res != null) {
      setState(() {
        if (loadMore)
          _videos.addAll(res.videos);
        else
          _videos = res.videos;
        _hasMore = res.videos.length >= _limit;
        if (_hasMore) _page++;
      });
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ==== CUSTOM SEARCH BAR ====
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // search pill
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              textInputAction: TextInputAction.search,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm video...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                              ),
                              onSubmitted:
                                  (_) => _searchVideos(loadMore: false),
                            ),
                          ),

                          // clear button
                          if (_searchCtrl.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchCtrl.clear();
                                setState(() {
                                  _videos.clear();
                                  _hasMore = true;
                                });
                              },
                              child: Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==== VIDEO LIST ====
          Expanded(
            child:
                _videos.isEmpty && !_loading
                    ? const Center(child: Text('Chưa có kết quả'))
                    : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: _videos.length + (_hasMore ? 1 : 0),
                      itemBuilder: (_, idx) {
                        if (idx >= _videos.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return VideoTile(video: _videos[idx]);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
