import 'dart:convert';
import 'dart:io';
import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/Comment_Model.dart';
import 'package:farmrole/shared/types/Comment_Video_Model.dart';
import 'package:farmrole/shared/types/Post_Model.dart';
import 'package:farmrole/shared/types/Video_Model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:farmrole/shared/types/Post_Model.dart' as post_model;
import 'package:farmrole/shared/types/Video_Model.dart' as video_model;

class PostService {
  static const String _baseUrl = "https://api-ndolv2.nongdanonline.cc";

  Future<VideoPaginationResponse?> fetchLatestVideos({
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
        return VideoPaginationResponse.fromJson(data);
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

  //lấy video theo id (trang cá nhân + trang cá nhân người khác)
  Future<VideoPaginationResponse?> fetchVideosByUserId({
    required BuildContext context,
    required String userId,
    int page = 1,
    int limit = 10,
  }) async {
    final token = context.read<UserProvider>().user?.token;

    if (token == null) {
      debugPrint("Không có token xác thực");
      return null;
    }

    final url = Uri.parse(
      "$_baseUrl/video-farm/user/$userId?page=$page&limit=$limit",
    );

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
        return VideoPaginationResponse.fromJson(data);
      } else {
        debugPrint(
          "Lỗi khi lấy video user: ${response.statusCode} - ${response.body}",
        );
        return null;
      }
    } catch (e) {
      debugPrint("Lỗi kết nối video-farm/user: $e");
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
    final token = context.read<UserProvider>().user?.token;
    if (token == null) {
      throw Exception('Không có token xác thực');
    }

    final uri = Uri.parse('$_baseUrl/post-feed/user/$userId').replace(
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );

    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    debugPrint('GET $uri → ${resp.statusCode}');
    debugPrint('Response body: ${resp.body}');
    if (resp.statusCode == 204) {
      return {
        'posts': <PostModel>[],
        'pagination': video_model.Pagination(
          total: 0,
          page: page,
          limit: limit,
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
    final pagination = post_model.Pagination.fromJson(paginationJson);

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
    final pagination = post_model.Pagination.fromJson(jsonData['pagination']);

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

  //like post
  Future<bool> likePost({
    required BuildContext context,
    required String postId,
  }) async {
    try {
      final token = context.read<UserProvider>().user?.token;

      if (token == null || token.isEmpty) {
        throw Exception('Không có token xác thực');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/post-feed/$postId/like'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Like thành công: ${data['message']}');
        return true;
      } else {
        debugPrint('Like thất bại: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Lỗi likePost: $e');
      return false;
    }
  }

  //unlike post
  Future<bool> unlikePost({
    required BuildContext context,
    required String postId,
  }) async {
    try {
      final token = context.read<UserProvider>().user?.token;
      if (token == null || token.isEmpty) {
        throw Exception('Không có token xác thực');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/post-feed/$postId/unlike'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Bỏ like thành công: ${data['message']}');
        return true;
      } else {
        debugPrint(
          'Bỏ like thất bại: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Lỗi unlikePost: $e');
      return false;
    }
  }

  //cmt post
  Future<bool> commentPost({
    required BuildContext context,
    required String postId,
    required String comment,
  }) async {
    try {
      final token = context.read<UserProvider>().user?.token;

      if (token == null || token.isEmpty) {
        throw Exception('Không có token xác thực');
      }

      final uri = Uri.parse('$_baseUrl/comment-post/$postId/comment');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'comment': comment}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return true;
      } else {
        debugPrint('Lỗi comment: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Lỗi commentPost: $e');
      return false;
    }
  }

  //get comment
  Future<List<CommentModel>> getComments({
    required BuildContext context,
    required String postId,
  }) async {
    final token = context.read<UserProvider>().user?.token;
    if (token == null) throw Exception("Chưa đăng nhập");

    final uri = Uri.parse("$_baseUrl/comment-post/$postId/comments");

    final response = await http.get(
      uri,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );
    if (response.statusCode != 200) {
      throw Exception("Lỗi lấy comment: ${response.body}");
    }
    final data = jsonDecode(response.body);
    if (data is List && data.isNotEmpty) {
      return data.map((e) => CommentModel.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  //reply comment
  Future<bool> replyComment({
    required BuildContext context,
    required String postId,
    required int commentIndex,
    required String replyText,
  }) async {
    final token = context.read<UserProvider>().user?.token;

    if (token == null || token.isEmpty) {
      throw Exception('Không có token xác thực');
    }

    final uri = Uri.parse(
      '$_baseUrl/comment-post/$postId/comment/$commentIndex/reply',
    );

    try {
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'comment': replyText}),
      );

      if (response.statusCode == 200) {
        debugPrint("Reply thành công: ${response.body}");
        return true;
      } else {
        debugPrint("Reply thất bại: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Lỗi khi gửi reply: $e");
      return false;
    }
  }

  //upload video farm
  static Future<void> uploadVideoFarm({
    required String token,
    required String title,
    required String farmId,
    required File videoFile,
    required BuildContext context,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/video-farm/upload'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['title'] = title;
      request.fields['farmId'] = farmId;
      request.files.add(
        await http.MultipartFile.fromPath('video', videoFile.path),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tải video thành công')));
      } else {
        throw Exception(json['message'] ?? 'Đăng video thất bại');
      }
    } catch (e) {
      debugPrint('Lỗi upload video: $e');
      throw Exception('Lỗi upload video: $e');
    }
  }

  // Like video
  Future<bool> likeVideo({
    required BuildContext context,
    required String videoId,
  }) async {
    final token = context.read<UserProvider>().user?.token;
    if (token == null || token.isEmpty) {
      throw Exception('Không có token xác thực');
    }
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/video-like/$videoId/like'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        debugPrint('Like video thành công: ${response.body}');
        return true;
      } else {
        debugPrint('Lỗi like video: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Lỗi kết nối khi like video: $e');
      return false;
    }
  }

  // Unlike video
  Future<bool> unlikeVideo({
    required BuildContext context,
    required String videoId,
  }) async {
    final token = context.read<UserProvider>().user?.token;
    if (token == null || token.isEmpty) {
      throw Exception('Không có token xác thực');
    }
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/video-like/$videoId/unlike'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        debugPrint('Unlike video thành công: ${response.body}');
        return true;
      } else {
        debugPrint(
          'Lỗi unlike video: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Lỗi kết nối khi unlike video: $e');
      return false;
    }
  }

  Future<List<CommentVideoModel>> fetchVideoComments({
    required BuildContext context,
    required String videoId,
  }) async {
    final token = context.read<UserProvider>().user?.token;
    if (token == null) throw Exception('Chưa đăng nhập');
    final uri = Uri.parse("$_baseUrl/video-comment/$videoId/comments");
    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    debugPrint('GET $uri → ${resp.statusCode}');
    debugPrint('Response body: ${resp.body}');
    if (resp.statusCode != 200) {
      throw Exception('Lỗi lấy comment video: ${resp.body}');
    }
    final data = jsonDecode(resp.body);
    if (data is! List) {
      throw Exception('Unexpected response format for comments');
    }
    return (data as List)
        .map((e) => CommentVideoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  //reply video cmt
  Future<bool> replyVideoComment({
    required BuildContext context,
    required String videoId,
    required int commentIndex,
    required String replyText,
  }) async {
    final token = context.read<UserProvider>().user?.token;
    if (token == null || token.isEmpty) throw Exception('Chưa đăng nhập');

    final uri = Uri.parse(
      '$_baseUrl/video-comment/$videoId/comment/$commentIndex/reply',
    );

    final resp = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'comment': replyText}),
    );
    return resp.statusCode == 200;
  }

  // Thêm comment mới
  Future<bool> postVideoComment({
    required BuildContext context,
    required String videoId,
    required String comment,
  }) async {
    final token = context.read<UserProvider>().user?.token;
    if (token == null || token.isEmpty) {
      throw Exception('Chưa đăng nhập');
    }
    final uri = Uri.parse('$_baseUrl/video-comment/$videoId/comment');
    final resp = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'comment': comment}),
    );
    return resp.statusCode == 200;
  }

  static Future<bool> updatePost({
  required BuildContext context,
  required String postId,
  required String title,
  required String description,
  required List<String> tags,
  required List<String> existingImageUrls,
  required List<File> imagesFiles, // Không sử dụng nếu không có API upload ảnh
}) async {
  try {
    final token = context.read<UserProvider>().user?.token;
    if (token == null || token.isEmpty) {
      throw Exception("Token không hợp lệ");
    }

    final uri = Uri.parse('$_baseUrl/post-feed/$postId');
    final res = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "title": title,
        "description": description,
        "tags": tags,
        "images": existingImageUrls, // Chỉ gửi ảnh đã có
      }),
    );

    if (res.statusCode == 200) {
      return true;
    } else {
      debugPrint('Update failed: ${res.body}');
      return false;
    }
  } catch (e) {
    debugPrint('Update error: $e');
    return false;
  }
}

  //delete post
  static Future<bool> deletePost(BuildContext context, String postId) async {
    try {
      final token = context.read<UserProvider>().user?.token;
      final uri = Uri.parse('$_baseUrl/post-feed/$postId');

      final res = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) return true;

      debugPrint('Xoá thất bại: ${res.body}');
      return false;
    } catch (e) {
      debugPrint('Lỗi xoá bài viết: $e');
      return false;
    }
  }
}
