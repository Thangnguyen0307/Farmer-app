import 'package:farmrole/modules/home/screens/personal/canhan/Profile_Edit_Screen.dart';
import 'package:farmrole/modules/home/widgets/FarmerDivider.dart';
import 'package:farmrole/modules/home/widgets/InfoPanel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/auth/services/Auth_Service.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder(
      future: _loadProfile,
      builder: (context, snapshot) {
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

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(65),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.account_circle,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Thông tin cá nhân',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: theme.colorScheme.primary,
                  backgroundImage:
                      user.avatar != null && user.avatar!.isNotEmpty
                          ? NetworkImage(
                            AuthService.getFullAvatarUrl(user.avatar!),
                          )
                          : null,
                  child:
                      user.avatar == null || user.avatar!.isEmpty
                          ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 55,
                          )
                          : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.fullName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                InfoPanel(
                  children: [
                    _buildInfoTile(
                      "Số điện thoại",
                      user.phone ?? "Chưa cập nhật",
                      Icons.phone,
                    ),
                    const FarmerDivider(),

                    _buildInfoTile(
                      "Vai trò",
                      user.roles.join(', '),
                      Icons.badge_outlined,
                    ),

                    const FarmerDivider(),

                    _buildInfoTile(
                      "Trạng thái",
                      user.isActive == true ? "Hoạt động" : "Bị khóa",
                      Icons.verified_user,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text(
                    'Chỉnh sửa thông tin',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}
