import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static final List<_TabInfo> _tabs = [
    _TabInfo(
      path: '/home',
      iconPath: 'lib/assets/icon/home_White.png',
      activeIconPath: 'lib/assets/icon/home.png',
      label: 'Trang chủ',
    ),
    _TabInfo(
      path: '/community',
      iconPath: 'lib/assets/icon/community_White.png',
      activeIconPath: 'lib/assets/icon/community.png',
      label: 'Cộng đồng',
    ),
    _TabInfo(
      path: '/chat',
      iconPath: 'lib/assets/icon/chat_White.png',
      activeIconPath: 'lib/assets/icon/chat.png',
      label: 'Thông báo',
    ),
    _TabInfo(
      path: '/Outside',
      iconPath: 'lib/assets/icon/personal_White.png',
      activeIconPath: 'lib/assets/icon/personal.png',
      label: 'Cá nhân',
    ),
  ];

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    return _tabs.indexWhere((t) => loc.startsWith(t.path));
  }

  @override
  Widget build(BuildContext context) {
    final currentIdx = _currentIndex(context);
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      body: child,

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 55,
        width: 55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 13, 171, 32),
              Color.fromARGB(255, 2, 115, 25),
            ],
          ),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: IconButton(
          icon: const Icon(Icons.add, size: 28, color: Colors.white),
          onPressed: () => context.push('/create'),
        ),
      ),

      bottomNavigationBar: SizedBox(
        height: 80,
        child: ClipRRect(
          child: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 6,
            color: theme.colorScheme.primary,
            child: Row(
              children: [
                Expanded(child: _navBtn(context, 0, currentIdx)),
                Expanded(child: _navBtn(context, 1, currentIdx)),
                const SizedBox(width: 60), // chừa chỗ FAB
                Expanded(child: _navBtn(context, 2, currentIdx)),
                Expanded(child: _navBtn(context, 3, currentIdx)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navBtn(BuildContext ctx, int idx, int currentIdx) {
    final tab = _tabs[idx];
    final selected = idx == currentIdx;

    return InkWell(
      onTap: () {
        if (tab.path == '/community') {
          ctx.push('/community');
        } else {
          ctx.go(tab.path);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: SizedBox(
            height: 50, // hoặc thử tăng lên 48, 50
            width: 50,
            child: Image.asset(
              selected ? tab.activeIconPath : tab.iconPath,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class _TabInfo {
  final String path;
  final String iconPath;
  final String activeIconPath;
  final String label;

  const _TabInfo({
    required this.path,
    required this.iconPath,
    required this.activeIconPath,
    required this.label,
  });
}
