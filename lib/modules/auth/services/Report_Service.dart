import 'dart:convert';
import 'package:farmrole/env/env.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReportService {
  static final String _baseUrl = Environment.config.baseUrl;

  static Future<void> createReport({
    required String token,
    required String type,
    String? targetUser,
    String? targetPost,
    String? targetVideoFarm,
    required String reason,
  }) async {
    final uri = Uri.parse('$_baseUrl/reports');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = {
      'type': type,
      'reason': reason,
      'targetUser': type == 'USER' ? targetUser : null,
      'targetPost': type == 'POST' ? targetPost : null,
      'targetVideoFarm': type == 'VIDEO_FARM' ? targetVideoFarm : null,
    }..removeWhere((key, value) => value == null);

    debugPrint('BODY: ${jsonEncode(body)}');

    final res = await http.post(uri, headers: headers, body: jsonEncode(body));

    debugPrint('Response status: ${res.statusCode}');
    debugPrint('Response body: ${res.body}');

    if (res.statusCode != 200) {
      final error = jsonDecode(res.body);
      throw Exception(error['message'] ?? 'Báo cáo thất bại');
    }
  }
}
