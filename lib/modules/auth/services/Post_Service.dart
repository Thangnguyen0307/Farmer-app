import 'dart:convert';
import 'dart:io';
import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/Post_Model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class PostService {
  static const String _baseUrl = "https://api-ndolv2.nongdanonline.vn";

  Future<Map<String, dynamic>?> fetchLatestVideos({
    required BuildContext context,
    int page = 1,
    int limit = 10,
  }) async {
    final token = context.read<UserProvider>().user?.token;

    if (token == null) {
      debugPrint("Không có token xác thực");
      return null;
    }

    final url = Uri.parse("$_baseUrl/video-farm/new?page=$page&limit=$limit");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        debugPrint(
          "Lỗi khi lấy video: ${response.statusCode} - ${response.body}",
        );
        return null;
      }
    } catch (e) {
      debugPrint("Lỗi kết nối video-farm/new: $e");
      return null;
    }
  }

  //get bai viet theo id user
  Future<Map<String, dynamic>> fetchUserPosts({
    required BuildContext context,
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    // Lấy token từ Provider
    final token = context.read<UserProvider>().user?.token;
    if (token == null) {
      throw Exception('Không có token xác thực');
    }

    final uri = Uri.parse('$_baseUrl/post-feed/user/$userId').replace(
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );

    // Gửi request kèm header
    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    // Debug log
    debugPrint('GET $uri → ${resp.statusCode}');
    debugPrint('Response body: ${resp.body}');
    if (resp.statusCode == 204) {
      return {
        'posts': <PostModel>[],
        'pagination': Pagination(
          total: 0,
          page: page,
          limit: limit,
          totalPages: 0,
        ),
      };
    }
    if (resp.statusCode != 200) {
      throw Exception('Server error: ${resp.statusCode}');
    }
    final jsonData = jsonDecode(resp.body) as Map<String, dynamic>;
    final postsJson = jsonData['data'] as List<dynamic>;
    final paginationJson = jsonData['pagination'] as Map<String, dynamic>;
    final posts =
        postsJson
            .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
            .toList();
    final pagination = Pagination.fromJson(paginationJson);

    return {'posts': posts, 'pagination': pagination};
  }

  //get all post
  Future<Map<String, dynamic>> fetchAllPosts({
    required BuildContext context,
    int page = 1,
    int limit = 10,
  }) async {
    final user = context.read<UserProvider>().user;
    final token = user?.token;

    if (token == null || token.isEmpty) {
      throw Exception("Token không hợp lệ");
    }

    final uri = Uri.parse(
      '$_baseUrl/post-feed',
    ).replace(queryParameters: {'page': '$page', 'limit': '$limit'});

    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (resp.statusCode != 200) {
      throw Exception('Lỗi lấy danh sách bài viết: ${resp.body}');
    }

    final jsonData = jsonDecode(resp.body);
    final posts =
        (jsonData['data'] as List).map((e) => PostModel.fromJson(e)).toList();
    final pagination = Pagination.fromJson(jsonData['pagination']);

    return {'posts': posts, 'pagination': pagination};
  }

  //create post
  static Future<Map<String, dynamic>> createPost(
    Map<String, dynamic> postData,
    List<File>? images,
    BuildContext context,
  ) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String? token = userProvider.user?.token;
    String? userId = userProvider.user?.id;
    if (token == null || token.isEmpty || userId == null) {
      await AuthService().myProfile(context);
      token = userProvider.user?.token;
      userId = userProvider.user?.id;
      if (token == null || token.isEmpty || userId == null) {
        throw Exception('Không có access token hoặc userId hợp lệ');
      }
    }
    final uri = Uri.parse('$_baseUrl/post-feed');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = postData['title']?.toString() ?? '';
    request.fields['description'] = postData['description']?.toString() ?? '';
    // API nhận tags là chuỗi; nếu bạn muốn gửi nhiều tags, có thể join bằng dấu phẩy
    final tags = postData['tags'];
    if (tags is List<String>) {
      request.fields['tags'] = tags.join(',');
    } else {
      request.fields['tags'] = tags?.toString() ?? '';
    }
    if (images != null && images.isNotEmpty) {
      for (var i = 0; i < images.length && i < 5; i++) {
        //limit 5 images
        final file = images[i];
        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        final parts = mimeType.split('/');
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            file.path,
            contentType: MediaType(parts[0], parts[1]),
          ),
        );
      }
    }
    final streamedRes = await request.send();
    final resBody = await streamedRes.stream.bytesToString();
    if (streamedRes.statusCode == 200 || streamedRes.statusCode == 201) {
      return jsonDecode(resBody) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Tạo post thất bại [${streamedRes.statusCode}]: $resBody',
      );
    }
  }
}
