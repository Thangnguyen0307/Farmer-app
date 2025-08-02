import 'package:farmrole/modules/home/screens/chat/Chat_Screen.dart';
import 'package:farmrole/modules/home/screens/personal/farmManager/MyFarm_Screen.dart';
import 'package:farmrole/modules/home/screens/personal/farmManager/Register_Step1_Farm.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/widgets/AppDrawer.dart';
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
                  IconButton(
                    onPressed: () {
                      context.push('/chat');
                    },
                    icon: Image.asset(
                      'lib/assets/icon2/chat.png',
                      width: 34,
                      height: 34,
                      color: Colors.white,
                    ),
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
      ],
    );
  }
}
