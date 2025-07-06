import 'package:farmrole/app/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';

class OutsidePersonalScreen extends StatelessWidget {
  const OutsidePersonalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final gradient = LinearGradient(
      colors: [primary, theme.colorScheme.primaryContainer],
    );

    // Chọn ảnh đại diện
    final avatarProvider =
        (user?.avatar != null && user!.avatar!.isNotEmpty)
            ? NetworkImage(AuthService.getFullAvatarUrl(user.avatar!))
            : const AssetImage('lib/assets/image/avatar.png') as ImageProvider;

    final name = user?.fullName ?? 'Người dùng';
    final email = user?.email ?? 'Chưa đăng nhập';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Khám phá mở rộng',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: Colors.white,
            onPressed: () => context.push('/setting'),
            tooltip: 'Cài đặt',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: avatarProvider,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
