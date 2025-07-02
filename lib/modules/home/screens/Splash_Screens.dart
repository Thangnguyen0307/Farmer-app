import 'dart:convert';

import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/User_Model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final authService = AuthService();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');

    if (userString != null) {
      try {
        final userMap = json.decode(userString);
        final tempUser = UserModel.fromJson(userMap);
        final refreshToken = userMap['refreshToken'];

        debugPrint("==> Checking token: ${tempUser.token}");

        try {
          // Gọi thử với access token cũ
          final profile = await authService.getUserByToken(tempUser.token!);
          final newUser = profile.copyWith(token: tempUser.token);
          if (!mounted) return;
          context.read<UserProvider>().setUser(newUser);
          context.go('/home');
        } catch (e) {
          debugPrint("Access token hết hạn, đang thử refresh...");
          if (refreshToken == null) throw Exception("Không có refresh token");

          final newAccessToken = await authService.refreshAccessToken(context);
          if (newAccessToken == null) throw Exception("Refresh thất bại");

          final profile = await authService.getUserByToken(newAccessToken);
          final newUser = profile.copyWith(token: newAccessToken);
          context.read<UserProvider>().setUser(newUser);

          // Lưu lại user mới và token mới
          await prefs.setString(
            'user',
            jsonEncode({...newUser.toJson(), 'refreshToken': refreshToken}),
          );
          context.go('/home');
        }
      } catch (e) {
        debugPrint("Token lỗi hoặc không thể refresh: $e");
        await prefs.remove('user');
        context.go('/');
      }
    } else {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 60,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                backgroundImage: const AssetImage(
                  "lib/assets/image/avatar.png",
                ),
              ),
              const SizedBox(height: 24),

              // Tên app
              Text(
                "Farmer App",
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Đang khởi động ứng dụng...",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),

              const CircularProgressIndicator(), // Loading
            ],
          ),
        ),
      ),
    );
  }
}
