import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đăng ký thành công!")));
      context.go('/');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đăng ký thất bại")));
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

              Image.asset("lib/assets/image/garden.png", height: 100),

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
                                : const Text("Đăng ký"),
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
      labelText: label,
      prefixIcon: Icon(icon, color: colorScheme.primary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
