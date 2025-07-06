import 'package:farmrole/modules/auth/screens/Login_Screen.dart';
import 'package:farmrole/modules/auth/screens/Register_Screen.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/screens/community/Community_Screen.dart';
import 'package:farmrole/modules/home/screens/community/Create_Post_Screen.dart';
import 'package:farmrole/modules/home/screens/home/Home_Screen.dart';
import 'package:farmrole/modules/home/screens/chat/Notifi_Screen.dart';
import 'package:farmrole/modules/home/screens/personal/canhan/Outside_personal.dart';
import 'package:farmrole/modules/home/screens/personal/canhan/Profile_Screen.dart';
import 'package:farmrole/modules/home/screens/Splash_Screens.dart';
import 'package:farmrole/modules/home/screens/personal/canhan/Setting.dart';
import 'package:farmrole/modules/home/screens/personal/farmManager/Manager_Farmer.dart';
import 'package:farmrole/modules/home/widgets/MainShell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/',
      builder: (context, state) {
        final isLoggedIn = context.read<UserProvider>().isLoggedIn;
        return isLoggedIn ? const RedirectToHome() : const LoginScreen();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/community',
          builder: (_, __) => const CommunityScreen(),
        ),
        GoRoute(path: '/noti', builder: (_, __) => const NotifiScreen()),
        GoRoute(
          path: '/Outside',
          builder: (_, __) => const OutsidePersonalScreen(),
        ),
      ],
    ),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/setting', builder: (_, __) => const Setting()),
    GoRoute(
      path: '/create',
      builder: (context, state) => const CreatePostScreen(),
    ),
    GoRoute(
      path: '/manager',
      builder: (context, state) => const ManagerFarmer(),
    ),
  ],
);

class RedirectToHome extends StatelessWidget {
  const RedirectToHome({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go('/home');
    });
    return const Scaffold(body: SizedBox.shrink());
  }
}
