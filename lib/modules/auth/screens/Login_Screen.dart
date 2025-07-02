import 'dart:convert';
import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/User_Model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      context.go('/home');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Sai email hoặc mật khẩu")));
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                child: ClipOval(
                  child: Image.asset(
                    'lib/assets/image/garden.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Chào mừng bạn đến Farmer App",
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
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(
                        "Email",
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
                      decoration: _inputDecoration(
                        "Mật khẩu",
                        Icons.lock,
                        colorScheme,
                      ),
                      validator:
                          (value) =>
                              value == null || value.length < 6
                                  ? 'Mật khẩu ≥ 6 ký tự'
                                  : null,
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
                                : const Text("Đăng nhập"),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _handleGoogleLogin,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'lib/assets/image/google.png',
                              height: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Tiếp tục với Google",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
      labelText: label,
      prefixIcon: Icon(icon, color: colorScheme.primary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
