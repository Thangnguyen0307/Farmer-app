import 'dart:convert';
import 'package:farmrole/shared/types/Chat_Room_Model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';

class ChatService {
  static const _baseUrl = 'https://api-ndolv2.nongdanonline.cc/chat';

  // 1. Lấy danh sách phòng đã tham gia
  static Future<List<ChatRoom>> getMyRooms(BuildContext context) async {
    final token = context.read<UserProvider>().user?.token;
    final uri = Uri.parse('$_baseUrl/rooms');
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) {
      throw Exception('Lấy rooms thất bại: ${res.body}');
    }
    final List<dynamic> data = jsonDecode(res.body);
    return data.map((j) {
      final users =
          (j['users'] as List).map((u) {
            return ChatUser(
              userId: u['userId'],
              fullName: u['fullName'],
              avatar: u['avatar'],
              online: u['online'],
            );
          }).toList();
      return ChatRoom(
        roomId: j['roomId'],
        roomName: j['roomName'],
        roomAvatar: j['roomAvatar'],
        mode: j['mode'],
        users: users,
      );
    }).toList();
  }

  // 2. Lấy lịch sử tin nhắn của 1 room (tùy backend có endpoint)
}
