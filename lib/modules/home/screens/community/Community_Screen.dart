import 'package:farmrole/modules/auth/services/Chat_Socket_Service.dart';
import 'package:farmrole/modules/auth/state/Chat_Notifier.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/screens/community/Community_Reels_Video_Tab.dart';
import 'package:farmrole/modules/home/widgets/Ads/BannerAdWidget.dart';
import 'package:flutter/material.dart';
import 'package:farmrole/modules/home/screens/community/Community_Post_Tab.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
    final userId = context.read<UserProvider>().user!.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatNotifier = Provider.of<ChatNotifier>(context, listen: false);
      ChatSocketService().setNotifier(chatNotifier);
      chatNotifier.fetchTotalUnread(userId);
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

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.canPop(context)) {
          return true; // pop như bình thường
        } else {
          context.go('/home');
          return false; // không pop, chỉ go
        }
      },
      child: Scaffold(
        backgroundColor: isVideo ? Colors.black : Colors.white,
        body: Column(
          children: [
            Expanded(
              child: DefaultTabController(
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
                        centerTitle: false,
                        titleSpacing: 0, // Giúp icon back sát lề trái hơn
                        title: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.grey.shade700,
                              ),
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  context.go('/home');
                                }
                              },
                            ),
                            const Text(
                              'Cộng đồng',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
                              tabs: const [
                                Tab(text: 'Bài viết'),
                                Tab(text: 'Video'),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          IconButton(
                            onPressed: () {
                              context.push('/search');
                            },
                            icon: Image.asset(
                              'lib/assets/icon/Search3.png',
                              width: 30,
                              height: 30,
                              color:
                                  Colors
                                      .grey
                                      .shade700, // Nếu ảnh là SVG hoặc PNG đơn sắc
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              context.push('/noti');
                            },
                            icon: Image.asset(
                              'lib/assets/icon/Noti.png',
                              width: 40,
                              height: 40,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Consumer<ChatNotifier>(
                            builder: (context, notifier, _) {
                              print(
                                "🎯 Widget rebuild với unread = ${notifier.totalUnread}",
                              );
                              return Stack(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      context.push(
                                        '/chat',
                                      ); // không reset gì cả
                                    },
                                    icon: Image.asset(
                                      'lib/assets/icon2/chat.png',
                                      width: 34,
                                      height: 34,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  if (notifier.totalUnread > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 20,
                                          minHeight: 20,
                                        ),
                                        child: Text(
                                          '${notifier.totalUnread}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabCtrl,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      CommunityPostTab(),
                      CommunityReelsVideoTab(),
                    ],
                  ),
                ),
              ),
            ),
            const BannerAdWidget(),
          ],
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
