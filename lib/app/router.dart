import 'package:farmrole/modules/auth/screens/Login_Screen.dart';
import 'package:farmrole/modules/auth/screens/Register_Screen.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/screens/Home_Screen.dart';
import 'package:farmrole/modules/home/screens/Profile_Screen.dart';
import 'package:farmrole/modules/home/screens/Splash_Screens.dart';
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
        return isLoggedIn ? HomeScreen() : const LoginScreen();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
  ],
);
