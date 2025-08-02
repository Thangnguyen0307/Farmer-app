import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  final authService = AuthService();

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await authService.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _fullNameController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result != null) {
      showDialog(
        context: context,
        barrierDismissible: false, // Không cho đóng khi bấm ra ngoài
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                "Đăng ký thành công",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text(
                "Bạn đã đăng ký thành công!\n\n"
                "Vui lòng kiểm tra email và bấm vào liên kết xác nhận để kích hoạt tài khoản.\n"
                "Sau đó quay lại đăng nhập.",
                style: TextStyle(height: 1.5),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/');
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đăng ký thất bại")));
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Image.asset("lib/assets/image/LogoCut1.png", height: 200),

              const SizedBox(height: 16),
              Text(
                "Tạo tài khoản mới",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _fullNameController,
                      decoration: _inputDecoration(
                        "họ tên",
                        Icons.person,
                        colorScheme,
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'nhập họ tên'
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration(
                        "email",
                        Icons.email,
                        colorScheme,
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'nhập email'
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _inputDecoration(
                        "mật khẩu",
                        Icons.lock,
                        colorScheme,
                      ),
                      validator:
                          (value) =>
                              value == null || value.length < 6
                                  ? 'mật khẩu ≥ 6 ký tự'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    //comfirmPass
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: _inputDecoration(
                        "nhập lại mật khẩu",
                        Icons.lock,
                        colorScheme,
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'mật khẩu không khớp';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Nút đăng ký
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  "Đăng ký",
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 16),
                    // Quay lại đăng nhập
                    TextButton(
                      onPressed: () {
                        context.go('/');
                      },
                      child: Text(
                        "← Quay lại đăng nhập",
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
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
