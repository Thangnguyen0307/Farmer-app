import 'package:flutter/material.dart';
import 'package:farmrole/modules/auth/services/Filter_Service.dart';
import 'package:farmrole/modules/home/widgets/Post/Post_Community.dart';
import 'package:farmrole/shared/types/Post_Model.dart';

class SearchPostScreen extends StatefulWidget {
  const SearchPostScreen({super.key});

  @override
  State<SearchPostScreen> createState() => _SearchPostScreenState();
}

class _SearchPostScreenState extends State<SearchPostScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  List<PostModel> results = [];
  List<String> tags = [];
  String keyword = '';
  String selectedTag = '';
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadTags();

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
              _scrollCtrl.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasMore) {
        _loadMore();
      }
    });
  }

  Future<void> _loadTags() async {
    try {
      final topTags = await FilterService().fetchTopTags(context: context);
      setState(() => tags = topTags);
    } catch (e) {
      debugPrint('Lỗi load tags: $e');
    }
  }

  Future<void> _refreshResults() async {
    setState(() {
      results.clear();
      page = 1;
      hasMore = true;
      isLoading = true;
    });

    try {
      List<PostModel> fetched =
          selectedTag.isNotEmpty
              ? await FilterService().fetchPostsByTag(
                context: context,
                tag: selectedTag,
                page: page,
                limit: 10,
              )
              : await FilterService().searchPosts(
                context: context,
                title: keyword,
                page: page,
                limit: 10,
              );

      setState(() {
        results = fetched;
        page++;
        isLoading = false;
        hasMore = fetched.length == 10;
      });
    } catch (e) {
      debugPrint('Lỗi tải bài viết: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (isLoading || (!hasMore)) return;

    setState(() => isLoading = true);

    try {
      List<PostModel> fetched =
          selectedTag.isNotEmpty
              ? await FilterService().fetchPostsByTag(
                context: context,
                tag: selectedTag,
                page: page,
                limit: 10,
              )
              : await FilterService().searchPosts(
                context: context,
                title: keyword,
                page: page,
                limit: 10,
              );

      setState(() {
        results.addAll(fetched);
        page++;
        isLoading = false;
        hasMore = fetched.length == 10;
      });
    } catch (e) {
      debugPrint('Lỗi loadMore: $e');
      setState(() => isLoading = false);
    }
  }

  void _onSearchSubmitted(String value) {
    keyword = value.trim();
    selectedTag = '';
    _refreshResults();
  }

  void _onTagSelected(String tag) {
    setState(() {
      selectedTag = tag == 'Tất cả' ? '' : tag;
      keyword = '';
      _searchCtrl.clear();
    });
    _refreshResults();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Search bar
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // 1) Icon quay lại
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(21),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              onSubmitted: _onSearchSubmitted,
                              textInputAction: TextInputAction.search,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm bài viết...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          if (_searchCtrl.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchCtrl.clear();
                                keyword = '';
                                _refreshResults();
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.grey.shade600,
                                size: 20,
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

          // Tags filter
          if (tags.isNotEmpty)
            SizedBox(
              height: 36,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children:
                      ['Tất cả', ...tags].map((t) {
                        final bool active =
                            (t == 'Tất cả' && selectedTag.isEmpty) ||
                            (t == selectedTag);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => _onTagSelected(t),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    active
                                        ? primary.withOpacity(0.15)
                                        : Colors.transparent,
                                border: Border.all(
                                  color:
                                      active ? primary : Colors.grey.shade300,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                t,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      active ? primary : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Kết quả
          Expanded(
            child:
                results.isEmpty && !isLoading
                    ? const Center(child: Text('Không tìm thấy kết quả nào'))
                    : ListView.builder(
                      controller: _scrollCtrl,
                      itemCount: results.length + (isLoading ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i < results.length) {
                          final post = results[i];
                          return Column(
                            children: [
                              PostCommunity(post: post),
                              const Divider(height: 1, color: Colors.grey),
                            ],
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    final bool isSelected =
        (tag == 'Tất cả' && selectedTag.isEmpty) || (tag == selectedTag);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(tag),
        selected: isSelected,
        onSelected: (_) => _onTagSelected(tag),
      ),
    );
  }
}
