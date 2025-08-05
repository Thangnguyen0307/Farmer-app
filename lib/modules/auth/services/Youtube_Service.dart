import 'dart:convert';
import 'package:farmrole/env/env.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/Youtube_Channel_Model.dart';
import 'package:farmrole/shared/types/Youtube_Video_Model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class YoutubeService {
  static final String _baseUrl = Environment.config.baseUrl;

  static Future<List<YoutubeChannelModel>> fetchChannelsByCategory({
    required BuildContext context,
    required String categoryId,
    int page = 1,
    int limit = 10,
  }) async {
    final token = context.read<UserProvider>().user?.token;
    if (token == null) throw Exception("Bạn chưa đăng nhập");

    final uri = Uri.parse(
      "$_baseUrl/youtube/channels/category/$categoryId?page=$page&limit=$limit",
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List data = jsonData['data'];
      return data.map((e) => YoutubeChannelModel.fromJson(e)).toList();
    } else {
      print("Lỗi khi gọi API: ${response.statusCode}");
      print("Response body: ${response.body}");
      throw Exception("Failed to fetch channels");
    }
  }

  //fetch video tu channel
  static Future<List<YoutubeVideoModel>> fetchVideosByChannel({
    required BuildContext context,
    required String channelId,
    int page = 1,
    int limit = 10,
  }) async {
    final url =
        '$_baseUrl/youtube/videos/channel/$channelId?page=$page&limit=$limit';

    final token = context.read<UserProvider>().user?.token;

    final res = await http.get(
      Uri.parse(url),
      headers: {'accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final List list = data['data'];
      return list.map((e) => YoutubeVideoModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load videos');
    }
  }
}
