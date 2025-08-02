import 'dart:convert';
import 'package:farmrole/app/AppInitializer.dart';
import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/services/Chat_Socket_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/User_Model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final authService = AuthService();

  Future<void> saveAndSetUser(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final accessToken = data['accessToken'];
    final refreshToken = data['refreshToken'];
    final userJson = data['user'];

    final user = UserModel.fromJson(
      userJson,
    ).copyWith(token: accessToken, refreshToken: refreshToken);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(user.toJson()));

    context.read<UserProvider>().setUser(user);
    ChatSocketService().connect(token: user.token!, userId: user.id);
    debugPrint(
      "User saved with accessToken: ${user.token}, refreshToken: ${user.refreshToken}",
    );
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result != null) {
      await saveAndSetUser(context, result);
      await AppInitializer.init(context);
      context.go('/home');
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Đăng nhập thất bại'),
              content: const Text('Sai email hoặc mật khẩu, vui lòng thử lại.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                ),
              ],
            ),
      );
    }
  }

  void _handleGoogleLogin() async {
    final result = await authService.loginWithGoogle();
    debugPrint("Google login result: $result");

    if (result != null) {
      await saveAndSetUser(context, result);
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng nhập Google thất bại")),
      );
    }
  }

  void _launchTermsUrl() async {
    final uri = Uri.parse('https://webadmin-dev.vercel.app/chinh-sach/bao-mat');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $uri';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                child: ClipOval(
                  child: Image.asset(
                    'lib/assets/image/LogoCut1.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Chào mừng bạn đến FARMTALK",
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(
                        "email",
                        Icons.email,
                        colorScheme,
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Nhập email'
                                  : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: _inputDecoration(
                        "mật khẩu",
                        Icons.lock,
                        colorScheme,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Nhập mật khẩu';
                        if (value != value.trim())
                          return 'Không được để khoảng trắng đầu/cuối';
                        if (value.length < 6) return 'Mật khẩu ≥ 6 ký tự';
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: colorScheme.primary.withOpacity(0.3),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  "Đăng nhập",
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: const Text(
                          "Quên mật khẩu?",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.underline,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Chưa có tài khoản?"),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: Text(
                            "Đăng ký",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    TextButton(
                      onPressed: _launchTermsUrl,
                      child: Text(
                        "Điều khoản & Chính sách bảo mật",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: colorScheme.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return InputDecoration(
      // Label và icon như cũ
      label: Padding(
        padding: const EdgeInsets.only(top: 0, left: 0),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Icon(icon, color: colorScheme.primary, size: 20),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.never,

      // Loại bỏ mọi đường kẻ, thay bằng bo góc
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: BorderSide.none,
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
