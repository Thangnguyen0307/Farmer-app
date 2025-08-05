import 'dart:async';
import 'dart:convert';
import 'package:farmrole/app/AppInitializer.dart';
import 'package:farmrole/app/router.dart';
import 'package:farmrole/app/theme.dart';
import 'package:farmrole/env/env.dart';
import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/services/Chat_Socket_Service.dart';
import 'package:farmrole/modules/auth/state/Address_Provider.dart';
import 'package:farmrole/modules/auth/state/Chat_Notifier.dart';
import 'package:farmrole/modules/auth/state/Farm_Provider.dart';
import 'package:farmrole/modules/auth/state/Upload_Manager.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/auth/state/Video_Provider.dart';
import 'package:farmrole/modules/home/screens/chat/Chat_Room_Screen.dart';
import 'package:farmrole/modules/home/widgets/noti/permisson.dart';
import 'package:farmrole/shared/types/User_Model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Thêm global navigator key để mở bottomsheet từ bất cứ đâu
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await requestNotificationPermission();
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('user');
  UserModel? initialUser;

  if (userJson != null) {
    final userMap = jsonDecode(userJson);
    initialUser = UserModel.fromJson(userMap);
  }

  Environment.setDev();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider()..setUser(initialUser),
        ),
        ChangeNotifierProvider(create: (_) => FarmProvider()),
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => UploadManager()),
        ChangeNotifierProvider(create: (_) => ChatNotifier()),
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
  late final StreamSubscription _statusSub;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        final chatNotifier = Provider.of<ChatNotifier>(context, listen: false);
        ChatSocketService().setNotifier(chatNotifier);
      }
    });

    // Lắng nghe trạng thái online/offline toàn app
    _statusSub = ChatSocketService().onlineStatus.listen((data) {
      debugPrint(
        '⚡ User ${data["userId"]} is now ${data["online"] ? "online" : "offline"}',
      );
    });

    // Lắng nghe roomReady toàn app, đẩy bottom sheet khi nhận được
    ChatSocketService().listenPrivateChat((room) {
      debugPrint('🟢 RoomReady global: ${room.roomId}');
      if (room.roomId.isNotEmpty) {
        navigatorKey.currentState?.push(
          PageRouteBuilder(
            opaque: false,
            barrierColor: Colors.transparent,
            pageBuilder: (_, __, ___) => ChatRoomScreen(roomId: room.roomId),
          ),
        );
      }
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (!_initialized) {
      await AppInitializer.init(context);
      final user = context.read<UserProvider>().user;
      if (user?.token != null) {
        AuthService().myProfile(context);
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _statusSub.cancel();
    ChatSocketService().clearPrivateChatListener();
    super.dispose();
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
