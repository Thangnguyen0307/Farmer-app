import 'dart:io';

import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/widgets/Upload_Image/Upload_Avatar.dart';
import 'package:farmrole/shared/types/User_Model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    _phoneController = TextEditingController(text: user.phone ?? "");
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final user = context.read<UserProvider>().user!;
    final success = await AuthService().updateUser(
      token: user.token!,
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      avatarPath: _avatarFile?.path,
    );

    if (success) {
      await AuthService().myProfile(context);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cập nhật thông tin thất bại"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>().user!;

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Text(
                  "Chỉnh sửa hồ sơ",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildAvatar(user),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: "Họ tên",
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Số điện thoại",
                          prefixIcon: Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveProfile,
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text(
                            "Lưu thay đổi",
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(UserModel user) {
    final image =
        _avatarFile != null
            ? FileImage(_avatarFile!)
            : (user.avatar != null && user.avatar!.isNotEmpty
                    ? NetworkImage(AuthService.getFullAvatarUrl(user.avatar!))
                    : const AssetImage("lib/assets/image/avatar.png"))
                as ImageProvider;

    return GestureDetector(
      onTap: () async {
        final picked = await _uploadAvatar.pickImageWithDialog(context);
        if (picked != null) {
          final compressed = await _uploadAvatar.compressImage(picked);
          if (compressed != null) {
            setState(() => _avatarFile = compressed);
            final success = await AuthService().uploadAvatarServer(
              compressed,
              user.token!,
              user,
              context,
            );
            if (success) {
              await AuthService().myProfile(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tải ảnh thành công")),
              );
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Tải ảnh thất bại")));
            }
          }
        }
      },
      child: CircleAvatar(radius: 50, backgroundImage: image),
    );
  }
}
