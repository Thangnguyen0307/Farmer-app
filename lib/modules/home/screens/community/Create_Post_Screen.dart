import 'package:farmrole/modules/auth/services/Chat_Socket_Service.dart';
import 'package:farmrole/modules/auth/state/Chat_Notifier.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/widgets/Post/Create_PostTab.dart';
import 'package:farmrole/modules/home/widgets/video/Create_VideoTab.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final userId = context.read<UserProvider>().user!.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatNotifier = Provider.of<ChatNotifier>(context, listen: false);
      ChatSocketService().setNotifier(chatNotifier);
      chatNotifier.fetchTotalUnread(userId);
    });
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.index == 1 && _tabController.indexIsChanging) {
      final user = context.read<UserProvider>().user;
      final roles = user?.roles ?? [];

      if (!roles.contains('Farmer')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  title: const Text('Yêu cầu đăng ký vài trò Chủ vườn'),
                  content: const Text(
                    'Bạn cần vai trò Chủ vườn mới được tạo Video. Bạn có muốn đăng ký ngay bây giờ?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _tabController.animateTo(0);
                      },
                      child: const Text('Không'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        Future.delayed(const Duration(milliseconds: 200), () {
                          Navigator.of(context).pushNamed('/register-farmer');
                        });
                      },
                      child: const Text('Có'),
                    ),
                  ],
                ),
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: const Text(
          'Tạo nội dung mới',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/noti');
            },
            icon: Image.asset(
              'lib/assets/icon/Noti.png',
              width: 40,
              height: 40,
              color: Colors.white,
            ),
          ),
          Consumer<ChatNotifier>(
            builder: (context, notifier, _) {
              print("🎯 Widget rebuild với unread = ${notifier.totalUnread}");
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      context.push('/chat');
                    },
                    icon: Image.asset(
                      'lib/assets/icon2/chat.png',
                      width: 34,
                      height: 34,
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

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Material(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 2, color: primary),
              ),
              labelColor: primary,
              unselectedLabelColor: Colors.grey.shade600,
              tabs: const [Tab(text: 'Bài viết'), Tab(text: 'Video')],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [PostTab(), VideoTab()],
        ),
      ),
    );
  }
}
