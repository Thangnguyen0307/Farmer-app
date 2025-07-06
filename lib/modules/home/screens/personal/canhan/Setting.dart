import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          "Cài đặt",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 1,
              shadowColor: Colors.black12,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  Divider(color: Colors.grey.shade200, height: 1),
                  _buildListItem(
                    context,
                    icon: Icons.person_outline,
                    label: 'Hồ sơ cá nhân',
                    route: '/profile',
                  ),
                  Divider(color: Colors.grey.shade200, height: 1),
                  _buildListItem(
                    context,
                    icon: Icons.public_outlined,
                    label: 'Trang trại của tôi',
                    route: '/manager',
                  ),
                  Divider(color: Colors.grey.shade200, height: 1),
                ],
              ),
            ),
          ),
          const Spacer(),
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Đăng xuất'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        label,
        style: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w300,
          color: const Color.fromARGB(255, 33, 33, 33),
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: () => context.push(route),
    );
  }
}
