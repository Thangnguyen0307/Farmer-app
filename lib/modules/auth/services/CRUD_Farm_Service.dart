import 'dart:convert';
import 'dart:io';
import 'package:farmrole/env/env.dart';
import 'package:farmrole/modules/auth/state/Farm_Provider.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/Farm_Model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

class CrudFarmService {
  static final String _baseUrl = Environment.config.baseUrl;
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

  //Ham register farm
  Future<Map<String, dynamic>?> createFarm(
    BuildContext context,
    Map<String, dynamic> farmData,
  ) async {
    final currentUser = context.read<UserProvider>().user;
    final token = currentUser?.token;

    if (token == null) {
      debugPrint("Không có access token");
      return null;
    }
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/farms"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(farmData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        debugPrint("Tạo farm thành công: $json");
        return json;
      } else {
        debugPrint(
          "Tạo farm thất bại: ${response.statusCode} - ${response.body}",
        );
        return null;
      }
    } catch (e) {
      debugPrint("Lỗi khi tạo farm: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchQuestions(
    BuildContext context,
  ) async {
    final currentUser = context.read<UserProvider>().user;
    final token = currentUser?.token;

    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/admin-questions?page=1&limit=40"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> jsonList = jsonData["data"] ?? [];

        return jsonList.cast<Map<String, dynamic>>();
      } else {
        debugPrint(
          "Lỗi fetch questions: ${response.statusCode} - ${response.body}",
        );
        return [];
      }
    } catch (e) {
      debugPrint("Lỗi fetch questions: $e");
      return [];
    }
  }

  // POST answer
  Future<bool> submitAnswers(
    BuildContext context,
    String farmId,
    List<Map<String, dynamic>> answers,
  ) async {
    final currentUser = context.read<UserProvider>().user;
    final token = currentUser?.token;

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/answers/batch"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"farmId": farmId, "answers": answers}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Gửi answers thành công");
        return true;
      } else {
        debugPrint(
          "Gửi answers thất bại: ${response.statusCode} - ${response.body}",
        );
        return false;
      }
    } catch (e) {
      debugPrint("Lỗi gửi answers: $e");
      return false;
    }
  }

  //upload anh farm
  Future<bool> uploadFarmImageAnswer({
    required BuildContext context,
    required String farmId,
    required File imageFile,
    String? description,
    bool isDefault = false,
  }) async {
    final currentUser = context.read<UserProvider>().user;
    final token = currentUser?.token;
    if (token == null) {
      debugPrint("Không có token khi upload ảnh farm.");
      return false;
    }
    try {
      final uri = Uri.parse("$_baseUrl/farm-pictures/$farmId");
      final request =
          http.MultipartRequest("POST", uri)
            ..headers['Authorization'] = 'Bearer $token'
            ..fields['description'] = description ?? ''
            ..fields['isDefault'] = isDefault.toString()
            ..files.add(
              await http.MultipartFile.fromPath('image', imageFile.path),
            );
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      if (response.statusCode == 201) {
        debugPrint("Tải ảnh farm thành công: $respStr");
        return true;
      } else {
        debugPrint("Lỗi upload farm image: ${response.statusCode} - $respStr");
        return false;
      }
    } catch (e) {
      debugPrint("Exception khi upload farm image: $e");
      return false;
    }
  }

  //upload ảnh farm có default
  static Future<void> uploadFarmImage({
    required String token,
    required String farmId,
    required File imageFile,
    String? description,
    bool isDefault = false,
  }) async {
    final uri = Uri.parse('$_baseUrl/farm-pictures/$farmId');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({'Authorization': 'Bearer $token'});

    // Thêm file ảnh
    final fileStream = http.MultipartFile.fromBytes(
      'image',
      await imageFile.readAsBytes(),
      filename: path.basename(imageFile.path),
    );
    request.files.add(fileStream);

    // Thêm các field khác
    request.fields['description'] = description ?? '';
    request.fields['isDefault'] = isDefault.toString();

    // Thực thi request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      print('Upload ảnh farm thành công');
    } else {
      print('Upload ảnh thất bại: ${response.statusCode} - ${response.body}');
      throw Exception('Lỗi upload ảnh: ${response.body}');
    }
  }

  //delete image
  static Future<void> deleteFarmImage({
    required String token,
    required String imageId,
  }) async {
    final url = Uri.parse('$_baseUrl/farm-pictures/$imageId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Xoá ảnh thất bại: ${response.statusCode}');
    }
  }

  //upload anh question
  Future<String?> uploadImageAnswer({
    required File file,
    required String farmId,
    required String questionId,
    required String token,
  }) async {
    final uri = Uri.parse("$_baseUrl/answers/upload-image");
    final request = http.MultipartRequest("POST", uri);
    request.headers['Authorization'] = "Bearer $token";
    request.fields['farmId'] = farmId;
    request.fields['questionId'] = questionId;
    request.files.add(await http.MultipartFile.fromPath('image', file.path));
    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final data = jsonDecode(respStr);
        return data['path'];
      } else {
        debugPrint("Upload thất bại: $respStr");
        return null;
      }
    } catch (e) {
      debugPrint("Lỗi upload answer image: $e");
      return null;
    }
  }

  //dang ki role farmer
  Future<void> upgradeToFarmer(BuildContext context) async {
    final user = context.read<UserProvider>().user!;
    final url = Uri.parse("$_baseUrl/users/register-farmer");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${user.token}',
      },
      body: jsonEncode({'role': 'Farmer'}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã trở thành Farmer thành công')),
      );
      // TODO: Cập nhật lại UserProvider.roles nếu muốn
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Thất bại: ${response.body}')));
    }
  }
}
