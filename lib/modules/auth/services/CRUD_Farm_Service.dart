import 'dart:convert';

import 'package:farmrole/modules/auth/state/Farm_Provider.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/Farm_Model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class CrudFarmService {
  static const String _baseUrl = "https://api-ndolv2.nongdanonline.vn";
  //lay thong tin farm cua toi
  Future<void> getmyFarm(BuildContext context) async {
    final currentUser = context.read<UserProvider>().user;
    final token = currentUser?.token;
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/farms/my"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final farm = data.map((e) => FarmModel.fromJson(e)).toList();
        context.read<FarmProvider>().setFarms(farm);
      } else if (response.statusCode == 404) {
        context.read<FarmProvider>().clearFarms();
      } else {
        throw Exception("Lỗi server: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Lỗi lấy farm của tôi: $e");
      rethrow;
    }
  }
}
