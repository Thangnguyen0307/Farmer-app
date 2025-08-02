import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/User_Model.dart';
import 'package:farmrole/modules/home/screens/personal/canhan/Profile_Edit_Screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<void> _loadProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile = AuthService().myProfile(context);
  }

  void _goEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final background = theme.colorScheme.background;

    return FutureBuilder(
      future: _loadProfile,
      builder: (_, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = context.watch<UserProvider>().user;
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Không tìm thấy người dùng')),
          );
        }
        final roles = user.roles
            .map((role) {
              switch (role) {
                case 'Farmer':
                  return 'Chủ vườn';
                case 'Customer':
                  return 'Người yêu nông sản';
                default:
                  return role;
              }
            })
            .join(', ');

        return Scaffold(
          backgroundColor: background,
          appBar: AppBar(
            title: Text(
              'Thông tin cá nhân',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: primary,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.edit), onPressed: _goEdit),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 55,
                  backgroundImage:
                      user.avatar?.isNotEmpty == true
                          ? NetworkImage(
                            AuthService.getFullAvatarUrl(user.avatar!),
                          )
                          : const AssetImage('lib/assets/icon/person_Fill.png')
                              as ImageProvider,
                ),
                const SizedBox(height: 16),

                // Name & Email
                Text(
                  user.fullName,
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),

                // Info fields
                _infoField(
                  title: 'Số điện thoại',
                  value: user.phone ?? 'Chưa cập nhật',
                  icon: Icons.phone,
                  color: primary,
                ),
                const SizedBox(height: 12),
                _infoField(
                  title: 'Vai trò',
                  value: roles,
                  icon: Icons.badge_outlined,
                  color: primary,
                ),
                const SizedBox(height: 12),
                _infoField(
                  title: 'Trạng thái',
                  value: user.isActive == true ? 'Hoạt động' : 'Bị khóa',
                  icon: Icons.toggle_on,
                  color: primary,
                ),
                const SizedBox(height: 32),

                // Edit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _goEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Chỉnh sửa thông tin',
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
      },
    );
  }

  Widget _infoField({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
