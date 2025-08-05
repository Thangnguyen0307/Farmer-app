import 'package:farmrole/modules/auth/services/Chat_Socket_Service.dart';
import 'package:farmrole/modules/auth/state/Chat_Notifier.dart';
import 'package:farmrole/modules/home/screens/chat/Chat_Screen.dart';
import 'package:farmrole/modules/home/screens/personal/farmManager/MyFarm_Screen.dart';
import 'package:farmrole/modules/home/screens/personal/farmManager/Register_Step1_Farm.dart';
import 'package:farmrole/modules/home/widgets/Ads/BannerAdWidget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/widgets/Welcome_Card.dart';
import 'package:farmrole/modules/home/widgets/DashBoard_Card.dart';

class ManagerFarmer extends StatefulWidget {
  const ManagerFarmer({super.key});

  @override
  State<ManagerFarmer> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ManagerFarmer> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> dashboardItems = [
    {
      "image": "lib/assets/icon/Myfarm.png",
      "title": "Trang trại của tôi",
      "subtitle": "Quản lý trang trại",
      "onTap": (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyFarmScreen()),
        );
      },
    },
    {
      "image": "lib/assets/icon/Signup.png",
      "title": "Đăng kí trang trại",
      "subtitle": "Đăng kí trang trại mới",
      "onTap": (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RegisterStep1Farm()),
        );
      },
    },
    {
      "image": "lib/assets/icon/Customerfarm.png",
      "title": "khách hàng",
      "subtitle": "Khách đã thuê",
      "comingSoon": true,
      "onTap": (BuildContext context) {},
    },
    {
      "image": "lib/assets/icon/Report.png",
      "title": "Báo cáo",
      "subtitle": "Thống kê hoạt động",
      "comingSoon": true,
      "onTap": (BuildContext context) {},
    },
  ];

  @override
  void initState() {
    final userId = context.read<UserProvider>().user!.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatNotifier = Provider.of<ChatNotifier>(context, listen: false);
      ChatSocketService().setNotifier(chatNotifier);
      chatNotifier.fetchTotalUnread(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final theme = Theme.of(context);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final List<Widget> tabs = [
      _buildHomeTab(context, theme, user.fullName),
      const ChatScreen(),
    ];
    return WillPopScope(
      onWillPop: () async {
        context.go('/setting');
        return false;
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: IndexedStack(index: _currentIndex, children: tabs),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, ThemeData theme, String fullName) {
    return Column(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(10, 40, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        context.go('/setting');
                      }
                    },
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "Quản lí trang trại",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
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
                      print(
                        "🎯 Widget rebuild với unread = ${notifier.totalUnread}",
                      );
                      return Stack(
                        children: [
                          IconButton(
                            onPressed: () {
                              context.push('/chat'); // không reset gì cả
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
              ),
              const SizedBox(height: 15),
              WelcomeCard(),
              const SizedBox(height: 6),
              const Text(
                'Đã đến với trang trại',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              itemCount: dashboardItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                final item = dashboardItems[index];
                return DashboardCard(
                  imageAsset: item["image"] ?? "",
                  title: item["title"] ?? "",
                  subtitle: item["subtitle"] ?? "",
                  comingSoon: item["comingSoon"] ?? false,
                  onTap: () => item["onTap"](context),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        const BannerAdWidget(),
        const SizedBox(height: 8),
      ],
    );
  }
}
