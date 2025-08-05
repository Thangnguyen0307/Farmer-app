import 'dart:convert';
import 'package:farmrole/env/env.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/Follow_Model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class FollowService {
  static final String _baseUrl = Environment.config.baseUrl;

  Future<bool> followUser(String userId, String? token) async {
    final url = Uri.parse('$_baseUrl/follow/$userId/follow');

    final response = await http.post(
      url,
      headers: {'accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      print('✅ Followed: ${jsonDecode(response.body)}');
      return true;
    } else {
      print('❌ Failed to follow: ${response.body}');
      return false;
    }
  }

  Future<bool> unfollowUser(String userId, String? token) async {
    final url = Uri.parse('$_baseUrl/follow/$userId/unfollow');

    final response = await http.delete(
      url,
      headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      print('✅ Unfollowed: ${jsonDecode(response.body)}');
      return true;
    } else {
      print('❌ Failed to unfollow: ${response.body}');
      return false;
    }
  }

  Future<List<FollowUser>> fetchFollowers({
    required BuildContext context,
    required String userId,
  }) async {
    final token = context.read<UserProvider>().user?.token;
    final uri = Uri.parse("$_baseUrl/follow/$userId/followers");

    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => FollowUser.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi khi tải danh sách người theo dõi');
    }
  }

  Future<List<FollowUser>> fetchFollowing({
    required BuildContext context,
    required String userId,
  }) async {
    final token = context.read<UserProvider>().user?.token;
    final uri = Uri.parse("$_baseUrl/follow/$userId/following");

    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => FollowUser.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi khi tải danh sách người đang theo dõi');
    }
  }
}
