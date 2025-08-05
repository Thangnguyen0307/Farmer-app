import 'package:farmrole/modules/auth/screens/Forgot_Password_Screen.dart';
import 'package:farmrole/modules/auth/screens/Login_Screen.dart';
import 'package:farmrole/modules/auth/screens/Register_Screen.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/auth/state/Video_Provider.dart';
import 'package:farmrole/modules/home/screens/VideoBottom/Video_BottomBar_Screen.dart';
import 'package:farmrole/modules/home/screens/chat/Chat_Room_List_Screen.dart';
import 'package:farmrole/modules/home/screens/chat/Chat_Room_Screen.dart';
import 'package:farmrole/modules/home/screens/community/Community_Screen.dart';
import 'package:farmrole/modules/home/screens/community/Create_Post_Screen.dart';
import 'package:farmrole/modules/home/screens/community/Outside_User_Personal.dart';
import 'package:farmrole/modules/home/screens/community/Update_Post_Screen.dart';
import 'package:farmrole/modules/home/screens/community/Search_Post_Screen.dart';
import 'package:farmrole/modules/home/screens/home/Youtube/Channel_Screen.dart';
import 'package:farmrole/modules/home/screens/home/Home_Screen.dart';
import 'package:farmrole/modules/home/screens/home/ReelsPageViewScreen.dart';
import 'package:farmrole/modules/home/screens/home/VideoListScreen.dart';
import 'package:farmrole/modules/home/screens/home/Video_Reels/Video_Reels_Screen.dart';
import 'package:farmrole/modules/home/screens/home/View_Video_Home.dart';
import 'package:farmrole/modules/home/screens/home/Youtube/Youtube_Player_Screen.dart';
import 'package:farmrole/modules/home/screens/home/noti/Noti_Screen.dart';
import 'package:farmrole/modules/home/screens/personal/canhan/Address_Screen.dart';
import 'package:farmrole/modules/home/screens/personal/canhan/Outside_personal.dart';
import 'package:farmrole/modules/home/screens/personal/canhan/Profile_Screen.dart';
import 'package:farmrole/modules/home/screens/Splash_Screens.dart';
import 'package:farmrole/modules/home/screens/personal/canhan/Setting.dart';
import 'package:farmrole/modules/home/screens/personal/farmManager/Manager_Farmer.dart';
import 'package:farmrole/modules/home/screens/personal/farmManager/MyFarm_Screen.dart';
import 'package:farmrole/modules/home/screens/personal/farmManager/Register_Step1_Farm.dart';
import 'package:farmrole/modules/home/widgets/Farmer_Register_Screens.dart';
import 'package:farmrole/modules/home/widgets/Post/Comment_Screen.dart';
import 'package:farmrole/modules/home/widgets/MainShell.dart';
import 'package:farmrole/modules/home/widgets/Post/Post_Detail.Screen.dart';
import 'package:farmrole/shared/types/Post_Model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final router = GoRouter(
  initialLocation: '/splash',
  navigatorKey: navigatorKey,
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
          path: '/Outside',
          builder: (_, __) => const OutsidePersonalScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (_, __) => ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/youtube-category-channel/:categoryId',
      name: 'youtube-category-channel',
      builder: (context, state) {
        final categoryId = state.pathParameters['categoryId']!;
        return YoutubeChannelListScreen(categoryId: categoryId);
      },
    ),
    GoRoute(
      path: '/video-list',
      name: 'videoList',
      builder: (context, state) => VideoListScreen(),
    ),
    GoRoute(
      path: '/youtube-player',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return YoutubePlayerScreen(videoId: extra['videoId']);
      },
    ),
    GoRoute(path: '/chat', builder: (_, __) => ChatRoomListScreen()),
    GoRoute(path: '/homehehe', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/community', builder: (_, __) => const CommunityScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/setting', builder: (_, __) => const Setting()),
    GoRoute(path: '/noti', builder: (_, __) => const NotiScreen()),
    // GoRoute(
    //   path: '/view-video-home',
    //   builder: (context, state) {
    //     final uploadedById = state.uri.queryParameters['uploadedById'];
    //     return ViewVideoHome(uploadedById: uploadedById);
    //   },
    // ),
    GoRoute(
      path: '/post-detail/:postId',
      builder: (context, state) {
        final postId = state.pathParameters['postId']!;
        return PostDetailScreen(postId: postId);
      },
    ),
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
      path: '/address',
      builder: (context, state) => const AddressScreen(),
    ),
    GoRoute(
      path: '/register-farmer',
      builder: (context, state) => const FarmerRegisterScreen(),
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
    GoRoute(
      path: '/profile/:userId',
      name: 'outsideProfile',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return OutsideUserPersonal(userId: userId);
      },
    ),
    GoRoute(
      path: '/my-farm',
      builder: (context, state) => const MyFarmScreen(),
    ),

    GoRoute(
      path: '/register-step1-farm',
      builder: (context, state) => const RegisterStep1Farm(),
    ),

    GoRoute(
      path: '/video-bottom-bar',
      builder: (context, state) => const VideoBottombarScreen(),
    ),

    // GoRoute(
    //   path: '/chat-bottom/:roomId',
    //   builder: (context, state) {
    //     final roomId = state.pathParameters['roomId']!;
    //     return ChatBottomSheetScreen(roomId: roomId);
    //   },
    // ),

    ///Reel khi bam vao thumbnail trang home
    GoRoute(
      path: '/community-videos',
      builder: (context, state) {
        final map = state.extra as Map<String, dynamic>;
        return VideoReelsScreen(
          videos: map['videos'],
          initialVideoId: map['initialVideoId'],
        );
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
