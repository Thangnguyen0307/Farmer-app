import 'package:farmrole/modules/auth/state/Video_Provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/shared/types/Video_Model.dart';
import 'package:farmrole/modules/home/widgets/Video_Item.dart';
import 'package:farmrole/modules/home/screens/home/Search_Screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showSearch = false;
  bool isLoading = true;
  List<VideoModel> videos = [];

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  Future<void> loadVideos() async {
    final res = await PostService().fetchLatestVideos(context: context);
    if (res != null && res['videos'] != null) {
      setState(() {
        videos =
            (res['videos'] as List)
                .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
                .toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.primary,
        title: Row(
          children: [
            Image.asset('lib/assets/image/appbar.png', height: 50, width: 50),
            const SizedBox(width: 8),
            Text(
              'FarmTalk',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            color: Colors.white,
            onPressed: () => setState(() => _showSearch = !_showSearch),
          ),
        ],
        bottom:
            _showSearch
                ? PreferredSize(
                  preferredSize: const Size.fromHeight(56),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm...',
                        fillColor: Colors.white,
                        filled: true,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) {
                        setState(() => _showSearch = false);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                )
                : null,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Video mới nhất',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,

                      // 1. Hiệu ứng “lò xo” khi kéo
                      physics: const BouncingScrollPhysics(),

                      // 2. Padding hai đầu thẩm mỹ
                      padding: const EdgeInsets.symmetric(horizontal: 8),

                      // 3. Cache trước một vài item để render nhanh
                      cacheExtent: 300,

                      itemCount: videos.length,
                      itemBuilder: (ctx, i) {
                        final v = videos[i];
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 12),
                          child: VideoItem(
                            youtubeLink: v.youtubeLink,
                            title: v.title,
                            onTap: () {
                              // Lưu state và chuyển sang Reels
                              context.read<VideoProvider>().setVideos(
                                videos,
                                i,
                              );
                              context.push('/reels');
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
