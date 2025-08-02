import 'dart:convert';
import 'package:farmrole/env/env.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/Farm_Model.dart';
import 'package:farmrole/shared/types/Post_Model.dart' as post_model;
import 'package:farmrole/shared/types/User_Model.dart';
import 'package:farmrole/shared/types/Video_Model.dart' as video_model;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class PersonalService {
  static final String _baseUrl = Environment.config.baseUrl;

  Future<Map<String, dynamic>> fetchUserWithResources({
    required BuildContext context,
    required String userId,
    int page = 1,
    int videoLimit = 10,
    int farmLimit = 10,
    int postLimit = 10,
  }) async {
    final token = context.read<UserProvider>().user?.token;
    if (token == null) throw Exception('Chưa đăng nhập');

    final uri = Uri.parse(
      "$_baseUrl/users/$userId"
      "?page=$page"
      "&videoLimit=$videoLimit"
      "&farmLimit=$farmLimit"
      "&postLimit=$postLimit",
    );

    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    print('>>> fetchUserWithResources userId: $userId');
    print('>>> GET $uri → ${resp.statusCode}');
    print('>>> Response: ${resp.body}');

    if (resp.statusCode == 404) {
      throw Exception('Không tìm thấy user');
    }

    if (resp.statusCode != 200) {
      throw Exception('Lỗi lấy thông tin user: ${resp.body}');
    }

    final data = jsonDecode(resp.body);
    final userInfo = UserModel.fromJson(data['user']);
    final videos =
        (data['videos'] as List?)
            ?.map((e) => video_model.VideoModel.fromJson(e))
            .toList() ??
        [];
    final farms =
        (data['farms'] as List?)?.map((e) => FarmModel.fromJson(e)).toList() ??
        [];
    final posts =
        (data['posts'] as List?)
            ?.map((e) => post_model.PostModel.fromJson(e))
            .where((post) => post.status == true)
            .toList() ??
        [];
    print('>>> Posts count: ${posts.length}');
    return {
      'user': userInfo,
      'videos': videos,
      'farms': farms,
      'posts': posts,
      'pagination': post_model.Pagination(
        page: page,
        limit: postLimit,
        totalPages: 1,
        total: posts.length,
      ),
    };
  }

  Future<UserModel?> fetchUserInfoOnly({
    required BuildContext context,
    required String userId,
  }) async {
    final token = context.read<UserProvider>().user?.token;
    if (token == null) throw Exception('Chưa đăng nhập');

    final uri = Uri.parse("$_baseUrl/users/$userId").replace(
      queryParameters: {'videoLimit': '0', 'postLimit': '0', 'farmLimit': '99'},
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Response fetchUserInfoOnly: ${jsonDecode(response.body)}');
      print('User response: $data');
      print('Farms from API: ${data['farms']}');
      return UserModel.fromJson(data);
      // Nếu bạn muốn lấy danh sách farm riêng thì return thêm data['farms']
    } else {
      throw Exception('Failed to load user info');
    }
  }
}
