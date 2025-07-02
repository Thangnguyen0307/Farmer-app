import 'package:farmrole/modules/home/screens/Chat_Screen.dart';
import 'package:farmrole/modules/home/screens/MyFarm_Screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/widgets/AppDrawer.dart';
import 'package:farmrole/modules/home/widgets/Welcome_Card.dart';
import 'package:farmrole/modules/home/widgets/DashBoard_Card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> dashboardItems = [
    {
      "image": "lib/assets/image/Myfarm.png",
      "title": "Farm của tôi",
      "subtitle": "Quản lý Farm",
      "onTap": (BuildContext context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyFarmScreen()),
        );
      },
    },
    {
      "image": "lib/assets/image/AddFarm.png",
      "title": "Đăng kí Farm",
      "subtitle": "Đăng kí Farm mới",
      "onTap": (BuildContext context) {},
    },
    {
      "image": "lib/assets/image/CustomerFarm.png",
      "title": "Farm khách hàng",
      "subtitle": "Khách đã thuê",
      "onTap": (BuildContext context) {},
    },
    {
      "image": "lib/assets/image/BaoCao.png",
      "title": "Báo cáo",
      "subtitle": "Thống kê hoạt động",
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

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: theme.colorScheme.background,
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: theme.colorScheme.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
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
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset("lib/assets/image/appbar.png", height: 36),
                  const SizedBox(width: 8),
                  Text(
                    "FARMER",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.notifications_none, color: Colors.white),
                  const SizedBox(width: 16),
                  Builder(
                    builder:
                        (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              WelcomeCard(),
              const SizedBox(height: 6),
              const Text(
                'Online',
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
