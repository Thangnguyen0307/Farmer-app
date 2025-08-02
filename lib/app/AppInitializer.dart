import 'package:farmrole/modules/auth/services/Chat_Service.dart';
import 'package:farmrole/modules/auth/services/Chat_Socket_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/DB_Helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppInitializer {
  static Future<void> init(BuildContext context) async {
    final user = context.read<UserProvider>().user;
    if (user?.token != null) {
      final socket = ChatSocketService();
      socket.connect(token: user!.token!, userId: user.id);

      final rooms = await ChatService.getPublicRooms(context);
      if (rooms != null) {
        final db = DBHelper();
        for (var room in rooms) {
          final exist = await db.getRoomById(room.roomId, user.id);
          if (exist == null) {
            await db.insertRoomPublic(room, user.id);
            final saved = await DBHelper().getRoomById(room.roomId, user.id);
            print(
              '✅ Saved room: ${saved?.roomId} | users: ${saved?.users.length}',
            );
          }
        }
      }
    } else {
      debugPrint('⚠️ Không khởi tạo socket vì chưa đăng nhập');
    }
  }
}
