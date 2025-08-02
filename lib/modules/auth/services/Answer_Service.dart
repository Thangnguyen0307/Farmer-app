import 'dart:convert';

import 'package:farmrole/env/env.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AnswerService {
  static final String _baseUrl = Environment.config.baseUrl;

  Future<List<Map<String, dynamic>>?> fetchAnswersByFarm(
    BuildContext context,
    String farmId,
  ) async {
    final token = context.read<UserProvider>().user?.token;
    if (token == null) {
      // Chưa đăng nhập
      return null;
    }

    final url = Uri.parse('$_baseUrl/answers/by-farm/$farmId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // Ép kiểu thành List<Map<String, dynamic>>
      return data.cast<Map<String, dynamic>>();
    } else {
      debugPrint(
        'Lấy câu trả lời farm lỗi: ${response.statusCode} ${response.body}',
      );
      return null;
    }
  }
}
