import 'package:farmrole/modules/auth/services/Chat_Socket_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppInitializer {
  static void init(BuildContext context) {
    final user = context.read<UserProvider>().user;
    if (user?.token != null) {
      final socket = ChatSocketService();
      socket.connect(context);
    } else {
      debugPrint('⚠️ Không khởi tạo socket vì chưa đăng nhập');
    }
  }
}
