import 'dart:convert';
import 'dart:io';
import 'package:farmrole/env/env.dart';
import 'package:farmrole/modules/auth/services/Chat_Socket_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/User_Model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final String _baseUrl = Environment.config.baseUrl;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '536559144445-vrcbs0hldc2oib9bvf63ktmkmp77nl43.apps.googleusercontent.com',
  );

  // login email va password
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse("$_baseUrl/auth/login");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email, "password": password}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Lỗi đăng nhập: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối khi đăng nhập: $e");
      return null;
    }
  }

  // Ham đăng ký tài khoản
  Future<Map<String, dynamic>?> register(
    String email,
    String password,
    String fullName,
  ) async {
    final url = Uri.parse("$_baseUrl/auth/register");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
          "fullName": fullName,
          "role": "Customer",
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print("Lỗi đăng ký: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối khi đăng ký: $e");
      return null;
    }
  }

  //ham logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');
    if (refreshToken == null) {
      return;
    }
    final response = await http.post(
      Uri.parse("$_baseUrl/auth/logout"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refreshToken": refreshToken}),
    );
    if (response.statusCode == 200) {
      print("Logout thành công từ server");
    } else {
      print("Lỗi khi logout: ${response.statusCode} - ${response.body}");
    }
    ChatSocketService().disconnect();
  }

  //hàm refresh token
  Future<String?> refreshAccessToken(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken == null) return null;

    final response = await http.post(
      Uri.parse("$_baseUrl/auth/refresh-token"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"refreshToken": refreshToken}),
    );

    if (response.statusCode == 200) {
      final newAccessToken = jsonDecode(response.body)['accessToken'];

      await prefs.setString('accessToken', newAccessToken);

      final userJson = prefs.getString('user');
      if (userJson != null) {
        final currentUser = UserModel.fromJson(jsonDecode(userJson));
        final updatedUser = currentUser.copyWith(token: newAccessToken);
        await prefs.setString('user', jsonEncode(updatedUser.toJson()));

        // Lấy UserProvider từ context đúng cách
        context.read<UserProvider>().setUser(updatedUser);
      }

      return newAccessToken;
    } else {
      debugPrint(
        "Refresh token lỗi: ${response.statusCode} - ${response.body}",
      );
      return null;
    }
  }

  // Đăng nhập Google và gửi token về server
  Future<Map<String, dynamic>?> loginWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      print('>>> ID Token: $idToken');

      if (idToken == null) {
        print(">>> idToken is null!");
        return null;
      }

      // Gửi token Google về backend của bạn
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/google-login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": idToken}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(
          "Lỗi Google login API: ${response.statusCode} - ${response.body}",
        );
        return null;
      }
    } catch (e) {
      print("Lỗi đăng nhập Google: $e");
      return null;
    }
  }

  //Quen mat khau
  static Future<bool> forgotPassword(String email) async {
    final uri = Uri.parse('$_baseUrl/auth/forgot-password');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (res.statusCode == 200) {
      return true;
    }
    return false;
  }

  //lay thong tin nguoi dung
  Future<void> myProfile(BuildContext context) async {
    final currentUser = context.read<UserProvider>().user;
    String? token = currentUser?.token;

    var response = await http.get(
      Uri.parse("$_baseUrl/users/my"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );
    if (response.statusCode == 401) {
      token = await refreshAccessToken(context);
      if (token != null) {
        response = await http.get(
          Uri.parse("$_baseUrl/users/my"),
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        );
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user');
        // if (context.mounted) context.go('/');
        return;
      }
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      var newUser = UserModel.fromJson(data['user']).copyWith(token: token);
      print('user JSON only: ${data['user']}');
      context.read<UserProvider>().setUser(newUser);

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('user', json.encode(newUser.toJson()));
    } else {
      debugPrint("Lỗi lấy profile: ${response.statusCode} - ${response.body}");
    }
  }

  //lay token
  Future<UserModel> getUserByToken(String token) async {
    final response = await http.get(
      Uri.parse("$_baseUrl/users/my"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return UserModel.fromJson(json['user']);
    } else {
      throw Exception("Token không hợp lệ");
    }
  }

  // Cập nhật thông tin người dùng
  Future<bool> updateUser({
    required String token,
    required String fullName,
    required String phone,
    String? avatarPath,
  }) async {
    final url = Uri.parse("$_baseUrl/users/update-profile");
    final request = http.MultipartRequest("PUT", url);
    request.headers['Authorization'] = "Bearer $token";

    request.fields['fullName'] = fullName;
    request.fields['phone'] = phone;

    if (avatarPath != null && avatarPath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('avatar', avatarPath),
      );
    }

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      debugPrint("Update profile response: $respStr");

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Lỗi cập nhật hồ sơ: $e");
      return false;
    }
  }

  //upload avatar len server
  Future<bool> uploadAvatarServer(
    File file,
    String token,
    UserModel user,
    BuildContext context,
  ) async {
    final uri = Uri.parse("$_baseUrl/users/update-avatar");
    final request = http.MultipartRequest("POST", uri);

    request.headers['Authorization'] = "Bearer $token";
    request.files.add(await http.MultipartFile.fromPath('avatar', file.path));

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint("Upload thất bại: $respStr");
        return false;
      }
    } catch (e) {
      debugPrint("Lỗi upload avatar: $e");
      return false;
    }
  }

  ///xoa tai khoan
  static Future<bool> deleteMyAccount(BuildContext context) async {
    final userProvider = context.read<UserProvider>();
    final token = userProvider.user?.token;

    if (token == null || token.isEmpty) {
      debugPrint('Không có token. Người dùng chưa đăng nhập.');
      return false;
    }
    final url = Uri.parse('$_baseUrl/auth/delete-my-user');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        debugPrint('✅ Xoá tài khoản thành công');
        return true;
      } else if (response.statusCode == 401) {
        debugPrint('❌ Token không hợp lệ hoặc đã hết hạn');
      } else {
        debugPrint('❌ Lỗi khi xoá tài khoản: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Lỗi kết nối: $e');
    }
    return false;
  }

  //ham lay avatar tu server
  static String getFullAvatarUrl(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) return '';
    if (avatarPath.startsWith('http')) return avatarPath;
    return '$_baseUrl$avatarPath';
  }
}
