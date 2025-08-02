import 'package:farmrole/env/env.dart';
import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'dart:convert';

class FarmerRegisterScreen extends StatefulWidget {
  const FarmerRegisterScreen({super.key});

  @override
  State<FarmerRegisterScreen> createState() => _FarmerRegisterScreenState();
}

class _FarmerRegisterScreenState extends State<FarmerRegisterScreen> {
  bool isLoading = false;

  static final String _baseUrl = Environment.config.baseUrl;

  Future<void> _registerFarmer(BuildContext context) async {
    final user = context.read<UserProvider>().user!;
    final url = Uri.parse("$_baseUrl/users/register-farmer");

    setState(() => isLoading = true);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${user.token}',
      },
      body: jsonEncode({'role': 'Farmer'}),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký thành công, bạn đã trở thành Farmer!'),
        ),
      );
      await AuthService().myProfile(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thành công, bạn đã trở thành Farmer!'),
          ),
        );
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi đăng ký: ${response.body}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký trở thành Farmer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chính sách khi trở thành Farmer',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('• Bạn cam kết cung cấp thông tin farm đúng sự thật.'),
            const Text('• Bạn có trách nhiệm bảo vệ nội dung, hình ảnh farm.'),
            const Text(
              '• Bạn đồng ý sử dụng hệ thống theo quy định của Nông Dân Online.',
            ),
            const Text(
              '• Bạn hiểu rõ các farm bạn tạo ra sẽ được công khai trên hệ thống.',
            ),
            const SizedBox(height: 24),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _registerFarmer(context),
                    icon: const Icon(Icons.check),
                    label: const Text('Đồng ý & Đăng ký'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
