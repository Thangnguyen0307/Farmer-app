import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/User_Model.dart';
import 'package:farmrole/modules/home/widgets/Upload_Image/Upload_Avatar.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  File? _avatarFile;
  final _uploadAvatar = UploadAvatar();

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user!;
    _fullNameController = TextEditingController(text: user.fullName);
    _phoneController = TextEditingController(text: user.phone ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final fullName = _fullNameController.text.trim();
    if (fullName.length > 50) {
      _showError('Họ tên không được vượt quá 50 ký tự.');
      return;
    }
    final phone = _phoneController.text.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      _showError('Số điện thoại phải đủ 10 chữ số.');
      return;
    }

    final user = context.read<UserProvider>().user!;
    final success = await AuthService().updateUser(
      token: user.token!,
      fullName: fullName,
      phone: phone,
      avatarPath: _avatarFile?.path,
    );

    if (success) {
      await AuthService().myProfile(context);
      Navigator.of(context).pop();
    } else {
      _showSnack('Cập nhật thất bại', isError: true);
    }
  }

  void _showError(String msg) => showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
          title: const Text('Lỗi'),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
  );

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    final user = context.watch<UserProvider>().user!;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: color,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // 1. Avatar
            GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _avatarProvider(user),
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 2. Họ tên
            _buildField(
              controller: _fullNameController,
              hintText: 'Họ tên',
              icon: Icons.person,
              color: color,
            ),

            const SizedBox(height: 16),

            // 3. Số điện thoại
            _buildField(
              controller: _phoneController,
              hintText: 'Số điện thoại',
              icon: Icons.phone,
              color: color,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 32),

            // 4. Lưu thay đổi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Lưu thay đổi',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickAvatar() async {
    final picked = await _uploadAvatar.pickImageWithDialog(context);
    if (picked != null) {
      final compressed = await _uploadAvatar.compressImage(picked);
      if (compressed != null) {
        setState(() => _avatarFile = compressed);
        final user = context.read<UserProvider>().user!;
        final ok = await AuthService().uploadAvatarServer(
          compressed,
          user.token!,
          user,
          context,
        );
        _showSnack(
          ok ? 'Cập nhật ảnh thành công' : 'Tải ảnh thất bại',
          isError: !ok,
        );
        if (ok) await AuthService().myProfile(context);
      }
    }
  }

  ImageProvider _avatarProvider(UserModel user) {
    if (_avatarFile != null) return FileImage(_avatarFile!);
    if (user.avatar?.isNotEmpty == true) {
      return NetworkImage(AuthService.getFullAvatarUrl(user.avatar!));
    }
    return const AssetImage('lib/assets/icon/person_Fill.png');
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color color,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.nunito(
          fontWeight: FontWeight.w300,
          color: Colors.black45,
        ),
        prefixIcon: Icon(icon, color: color, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
      ),
    );
  }
}
