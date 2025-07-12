import 'dart:convert';
import 'package:farmrole/app/AppInitializer.dart';
import 'package:farmrole/app/router.dart';
import 'package:farmrole/app/theme.dart';
import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/state/Farm_Provider.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/auth/state/Video_Provider.dart';
import 'package:farmrole/shared/types/User_Model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('user');
  UserModel? initialUser;

  if (userJson != null) {
    final userMap = jsonDecode(userJson);
    initialUser = UserModel.fromJson(userMap);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider()..setUser(initialUser),
        ),
        ChangeNotifierProvider(create: (_) => FarmProvider()),
        ChangeNotifierProvider(create: (_) => VideoProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      AppInitializer.init(context);
      final user = context.read<UserProvider>().user;
      if (user?.token != null) {
        AuthService().myProfile(context);
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Farmer App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
