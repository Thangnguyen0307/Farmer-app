import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/home/widgets/FarmerDivider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Xác nhận"),
            content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Hủy"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Đăng xuất"),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    await AuthService().logout();
    await prefs.remove('user');
    context.read<UserProvider>().clearUser();
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              context.push('/profile');
            },
            child: UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    (user != null &&
                            user.avatar != null &&
                            user.avatar!.isNotEmpty)
                        ? NetworkImage(
                          AuthService.getFullAvatarUrl(user.avatar!),
                        )
                        : const AssetImage('lib/assets/image/avatar.png')
                            as ImageProvider,
                onBackgroundImageError: (_, __) {},
              ),
              accountName: Text(
                user?.fullName ?? 'Người dùng',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(user?.email ?? 'Chưa đăng nhập'),
            ),
          ),

          ListTile(
            leading: Icon(
              Icons.person_outline,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Hồ sơ'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/profile');
            },
          ),
          FarmerDivider(),
          ListTile(
            leading: Icon(
              Icons.settings_outlined,
              color: theme.colorScheme.secondary,
            ),
            title: const Text('Cài đặt'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/setting');
            },
          ),

          const Spacer(),

          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Đăng xuất'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
