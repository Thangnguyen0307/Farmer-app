import 'package:farmrole/modules/auth/services/Chat_Socket_Service.dart';
import 'package:flutter/material.dart';

class AppInitializer {
  static void init(BuildContext context) {
    final socket = ChatSocketService();
    socket.connect(context);
  }
}
