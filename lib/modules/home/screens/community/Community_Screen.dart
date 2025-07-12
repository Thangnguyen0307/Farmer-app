import 'package:farmrole/modules/home/screens/community/Community_Reels_Video_Tab.dart';
import 'package:flutter/material.dart';
import 'package:farmrole/modules/home/screens/community/Community_Post_Tab.dart';
import 'package:go_router/go_router.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this)..addListener(() {
      setState(() {}); // rebuild khi đổi tab
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isVideo = _tabCtrl.index == 1;

    return Scaffold(
      backgroundColor: isVideo ? Colors.black : Colors.white,
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (ctx, scrolled) {
            if (isVideo) {
              return [
                SliverSafeArea(
                  top: true,
                  bottom: false,
                  sliver: SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      height: 48,
                      child: Container(
                        color: Colors.black,
                        child: TabBar(
                          controller: _tabCtrl,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          indicatorPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey,
                          tabs: const [
                            Tab(text: 'Bài viết'),
                            Tab(text: 'Video'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            }

            // Tab Bài viết: SliverAppBar + TabBar
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: scrolled ? 2 : 0,
                floating: true,
                snap: true,
                title: const Text(
                  'Cộng đồng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabCtrl,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      labelColor: primary,
                      unselectedLabelColor: Colors.grey.shade600,
                      tabs: const [Tab(text: 'Bài viết'), Tab(text: 'Video')],
                    ),
                  ),
                ),
                actions: [
                  Container(
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            context.push('/search');
                          },
                          icon: Icon(Icons.search, color: Colors.grey.shade700),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.home, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ];
          },
          body: TabBarView(
            controller: _tabCtrl,
            physics: const NeverScrollableScrollPhysics(),
            children: const [CommunityPostTab(), CommunityReelsVideoTab()],
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _TabBarDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate old) =>
      old.height != height || old.child != child;
}
