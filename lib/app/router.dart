import 'package:farmrole/modules/auth/screens/Login_Screen.dart';
import 'package:farmrole/modules/auth/screens/Register_Screen.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/auth/state/Video_Provider.dart';
import 'package:farmrole/modules/home/screens/chat/Chat_Room_List_Screen.dart';
import 'package:farmrole/modules/home/screens/chat/Chat_Room_Screen.dart';
import 'package:farmrole/modules/home/screens/community/Community_Screen.dart';
import 'package:farmrole/modules/home/screens/community/Create_Post_Screen.dart';
import 'package:farmrole/modules/home/screens/community/Update_Post_Screen.dart';
import 'package:farmrole/modules/home/screens/home/FullScreen_Video_Page.dart';
import 'package:farmrole/modules/home/screens/community/Search_Post_Screen.dart';
import 'package:farmrole/modules/home/screens/home/Home_Screen.dart';
import 'package:farmrole/modules/home/screens/chat/Notifi_Screen.dart';
import 'package:farmrole/modules/home/screens/home/ReelsPageViewScreen.dart';
import 'package:farmrole/modules/home/screens/personal/canhan/Outside_personal.dart';
import 'package:farmrole/modules/home/screens/personal/canhan/Profile_Screen.dart';
import 'package:farmrole/modules/home/screens/Splash_Screens.dart';
import 'package:farmrole/modules/home/screens/personal/canhan/Setting.dart';
import 'package:farmrole/modules/home/screens/personal/farmManager/Manager_Farmer.dart';
import 'package:farmrole/modules/home/widgets/Post/Comment_Screen.dart';
import 'package:farmrole/modules/home/widgets/MainShell.dart';
import 'package:farmrole/shared/types/Post_Model.dart';
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

        GoRoute(path: '/chat', builder: (_, __) => ChatRoomListScreen()),

        GoRoute(
          path: '/Outside',
          builder: (_, __) => const OutsidePersonalScreen(),
        ),
      ],
    ),
    GoRoute(path: '/community', builder: (_, __) => const CommunityScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/setting', builder: (_, __) => const Setting()),
    GoRoute(
      path: '/create',
      builder: (context, state) => const CreatePostScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchPostScreen(),
    ),
    GoRoute(
      path: '/manager',
      builder: (context, state) => const ManagerFarmer(),
    ),
    GoRoute(
      path: '/update-post',
      builder: (context, state) {
        final post = state.extra as PostModel;
        return UpdatePostScreen(post: post);
      },
    ),
    GoRoute(
      path: '/chat/room/:roomId',
      builder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        return ChatRoomScreen(roomId: roomId);
      },
    ),
    GoRoute(
      path: '/reels',
      builder: (context, state) {
        final provider = context.watch<VideoProvider>();
        return ReelsScreen(
          videos: provider.videos,
          initialIndex: provider.initialIndex,
        );
      },
    ),
    GoRoute(
      path: '/comments/:postId',
      builder: (context, state) {
        final postId = state.pathParameters['postId']!;
        return CommentScreen(postId: postId);
      },
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
