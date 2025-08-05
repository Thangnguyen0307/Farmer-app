import 'dart:convert';

import 'package:farmrole/env/env.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/Homepage_Data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class HomeService {
  static final String _baseUrl = Environment.config.baseUrl;

  Future<HomepageData> fetchHomepageData(BuildContext context) async {
    final token = context.read<UserProvider>().user?.token;

    final response = await http.get(
      Uri.parse('$_baseUrl/homepage'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return HomepageData.fromJson(jsonData);
    } else {
      throw Exception('Lỗi khi lấy dữ liệu trang chủ: ${response.body}');
    }
  }
}
