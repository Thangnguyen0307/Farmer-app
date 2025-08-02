import 'dart:convert';
import 'dart:io';
import 'package:farmrole/env/env.dart';
import 'package:farmrole/shared/types/Chat_Public_Model.dart';
import 'package:farmrole/shared/types/Chat_Room_Model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ChatService {
  static final String _baseUrl = Environment.config.baseUrl;

  // //Lấy danh sách phòng đã tham gia
  // static Future<List<ChatRoom>> getMyRooms(BuildContext context) async {
  //   final token = context.read<UserProvider>().user?.token;
  //   final uri = Uri.parse('$_baseUrl/chat/rooms/user');

  //   try {
  //     final res = await http.get(
  //       uri,
  //       headers: {'Authorization': 'Bearer $token'},
  //     );

  //     if (res.statusCode != 200) {
  //       throw Exception('Lấy rooms thất bại: ${res.body}');
  //     }

  //     final List<dynamic> data = jsonDecode(res.body);
  //     return data.map((j) {
  //       final users =
  //           (j['users'] as List).map((u) {
  //             return ChatUser(
  //               userId: u['userId'],
  //               fullName: u['fullName'],
  //               avatar: u['avatar'],
  //               online: u['online'],
  //             );
  //           }).toList();

  //       return ChatRoom(
  //         roomId: j['roomId'],
  //         roomName: j['roomName'],
  //         roomAvatar: j['roomAvatar'],
  //         mode: j['mode'],
  //         users: users,
  //       );
  //     }).toList();
  //   } catch (e) {
  //     throw Exception('Không thể kết nối tới server hoặc mất mạng');
  //   }
  // }

  //lay chi tiet 1 phong chat
  static Future<ChatRoom?> getRoomDetail(
    BuildContext context,
    String roomId,
  ) async {
    final token = context.read<UserProvider>().user?.token;
    if (token == null) {
      print('❌ Không có token');
      return null;
    }

    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/chat/room/$roomId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        final users =
            (data['users'] as List).map((u) {
              return ChatUser(
                userId: u['userId'],
                fullName: u['fullName'],
                avatar: u['avatar'],
                online: u['online'] ?? false,
              );
            }).toList();

        return ChatRoom(
          roomId: data['roomId'],
          roomName: data['roomName'] ?? 'Chat room',
          roomAvatar: data['roomAvatar'],
          mode: data['mode'],
          users: users,
        );
      } else {
        print('❌ Lỗi lấy chi tiết phòng: ${res.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception khi lấy chi tiết phòng: $e');
      return null;
    }
  }

  Future<ChatRoom?> getRoomInfo({
    required String? token,
    required String roomId,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/chat/room/$roomId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        final users =
            (data['users'] as List).map((u) {
              return ChatUser(
                userId: u['userId'],
                fullName: u['fullName'],
                avatar: u['avatar'],
                online: u['online'] ?? false,
              );
            }).toList();

        return ChatRoom(
          roomId: data['roomId'],
          roomName: data['roomName'] ?? 'Chat room',
          roomAvatar: data['roomAvatar'],
          mode: data['mode'],
          users: users,
        );
      } else {
        print('❌ Lỗi lấy chi tiết phòng: ${res.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception khi lấy chi tiết phòng: $e');
      return null;
    }
  }

  //lay phong public
  static Future<List<ChatRoom>?> getPublicRooms(BuildContext context) async {
    try {
      final token = context.read<UserProvider>().user?.token;
      final res = await http.get(
        Uri.parse('$_baseUrl/chat/rooms/public'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(res.body);
        return jsonData.map((e) => ChatRoom.fromPublicJson(e)).toList();
      }
      return null;
    } catch (e) {
      print('❌ Lỗi ChatService.getPublicRooms(): $e');
      return null;
    }
  }

  static Future<String?> uploadChatImage({
    required String roomId,
    required File imageFile,
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/chat/upload/$roomId');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    final mimeTypeData =
        lookupMimeType(imageFile.path)?.split('/') ?? ['image', 'jpeg'];

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
      ),
    );

    final response = await request.send();
    if (response.statusCode == 200) {
      final body = await http.Response.fromStream(response);
      final json = jsonDecode(body.body);
      return json['path']; // path là link ảnh
    } else {
      throw Exception('❌ Upload failed (${response.statusCode})');
    }
  }
}
