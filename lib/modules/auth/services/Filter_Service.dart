import 'dart:convert';

import 'package:farmrole/env/env.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/Post_Model.dart';
import 'package:farmrole/shared/types/Video_Model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class FilterService {
  static final String _baseUrl = Environment.config.baseUrl;

  //Search post bang title
  Future<List<PostModel>> searchPosts({
    required BuildContext context,
    required String title,
    int page = 1,
    int limit = 10,
  }) async {
    final token = context.read<UserProvider>().user?.token;
    if (token == null) throw Exception('Chưa đăng nhập');
    final uri = Uri.parse(
      "$_baseUrl/post-feed/search?title=$title&page=$page&limit=$limit",
    );
    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    debugPrint('GET $uri → ${resp.statusCode}');
    debugPrint('Response body: ${resp.body}');
    if (resp.statusCode != 200) {
      throw Exception('Lỗi tìm kiếm bài viết: ${resp.body}');
    }
    final json = jsonDecode(resp.body);
    if (json['data'] is! List) {
      throw Exception('Sai định dạng dữ liệu trả về');
    }
    return (json['data'] as List)
        .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  //Lay top 10 tag
  Future<List<String>> fetchTopTags({required BuildContext context}) async {
    final token = context.read<UserProvider>().user?.token;
    if (token == null) throw Exception('Chưa đăng nhập');

    final uri = Uri.parse('$_baseUrl/post-feed/tags/top');
    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (resp.statusCode != 200) {
      throw Exception('Lỗi lấy danh sách tag: ${resp.body}');
    }

    final data = jsonDecode(resp.body);
    if (data is! List) throw Exception('Response tag không hợp lệ');

    return (data as List).map((e) => e['tag'].toString()).toList();
  }

  //search post bang tag
  Future<List<PostModel>> fetchPostsByTag({
    required BuildContext context,
    required String tag,
    required int page,
    required int limit,
  }) async {
    final token = context.read<UserProvider>().user?.token;
    if (token == null) throw Exception('Chưa đăng nhập');
    final uri = Uri.parse(
      "$_baseUrl/post-feed/tag/$tag?page=$page&limit=$limit",
    );
    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (resp.statusCode != 200) {
      throw Exception('Lỗi lấy bài viết theo tag: ${resp.body}');
    }
    final data = jsonDecode(resp.body);
    if (data is! Map || data['data'] is! List) {
      throw Exception('Dữ liệu trả về không hợp lệ');
    }
    return (data['data'] as List).map((e) => PostModel.fromJson(e)).toList();
  }

  //search video by title
  Future<VideoPaginationResponse?> searchVideos({
    required BuildContext context,
    required String title,
    int page = 1,
    int limit = 10,
  }) async {
    final token = context.read<UserProvider>().user?.token;
    if (token == null) {
      debugPrint('searchVideos: Không có token xác thực');
      return null;
    }

    final uri = Uri.parse('$_baseUrl/video-farm/search').replace(
      queryParameters: {
        'title': title,
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return VideoPaginationResponse.fromJson(data);
      } else {
        debugPrint(
          'searchVideos: Lỗi ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('searchVideos: Exception $e');
      return null;
    }
  }
}
