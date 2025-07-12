import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/widgets/Post/Create_PostTab.dart';
import 'package:farmrole/modules/home/widgets/Post/Create_VideoTab.dart';

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
                  title: const Text('Yêu cầu đăng ký Farmer'),
                  content: const Text(
                    'Bạn cần là thành viên Farmer mới được tạo Video. Bạn có muốn đăng ký ngay bây giờ?',
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
                        Navigator.of(context).pop();
                        // điều hướng tới screen đăng ký Farmer
                        Navigator.of(context).pushNamed('/register-farmer');
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
        title: const Text(
          'Tạo nội dung mới',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
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
