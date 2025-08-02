import 'dart:convert';
import 'package:farmrole/env/env.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class CommentService {
  static final String _baseUrl = Environment.config.baseUrl;

  //xoa comment chính
  Future<void> hideComment({
    required BuildContext context,
    required String postId,
    required int commentIndex,
  }) async {
    final user = context.read<UserProvider>().user;
    final token = user?.token;

    if (token == null || token.isEmpty) {
      throw Exception('Bạn chưa đăng nhập.');
    }

    final url = Uri.parse(
      '$_baseUrl/comment-post/$postId/comment/$commentIndex',
    );
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    print("🧾 Sending delete comment request with index: $commentIndex");
    print("✅ Server response: ${response.statusCode}");

    if (response.statusCode != 200) {
      throw Exception('Ẩn bình luận thất bại');
    }
  }

  //xoa reply
  Future<void> hideReply({
    required BuildContext context,
    required String postId,
    required int commentIndex,
    required int replyIndex,
  }) async {
    final user = context.read<UserProvider>().user;
    final token = user?.token;

    if (token == null || token.isEmpty) {
      throw Exception('Bạn chưa đăng nhập.');
    }

    final url = Uri.parse(
      '$_baseUrl/comment-post/$postId/comment/$commentIndex/reply/$replyIndex',
    );
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Ẩn trả lời bình luận thất bại');
    }
  }
}
