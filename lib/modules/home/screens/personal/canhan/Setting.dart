import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/services/Chat_Socket_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});
  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Xác nhận"),
            content: const Text("Bạn có chắc chắn muốn đăng xuất không?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Hủy"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Đăng xuất"),
              ),
            ],
          ),
    );
    if (confirm != true) return;
    final prefs = await SharedPreferences.getInstance();
    await AuthService().logout();
    ChatSocketService().disconnect();
    await prefs.remove('user');
    context.read<UserProvider>().clearUser();
    context.go('/');
  }

  ///xoa tài khoản
  void onDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Xác nhận xoá tài khoản'),
            content: Text('Bạn có chắc chắn muốn xoá tài khoản không?'),
            actions: [
              TextButton(
                child: Text('Hủy'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                child: Text('Xoá'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final success = await AuthService.deleteMyAccount(context);
      if (success && context.mounted) {
        context.read<UserProvider>().clearUser();
        ChatSocketService().disconnect();
        context.go('/');
      }
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
    final user = context.watch<UserProvider>().user;
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        context.go('/Outside');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          title: Text(
            "Cài đặt",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 1,
                shadowColor: Colors.black12,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    Divider(color: Colors.grey.shade200, height: 1),
                    _buildListItem(
                      context,
                      iconAsset: 'lib/assets/icon/person_Fill.png',
                      label: 'Hồ sơ cá nhân',
                      onTapCustom: () => context.push('/profile'),
                    ),
                    Divider(color: Colors.grey.shade200, height: 1),
                    _buildListItem(
                      context,
                      iconAsset: 'lib/assets/icon/Farm1.png',
                      label: 'Trang trại của tôi',
                      onTapCustom: () async {
                        final user = context.read<UserProvider>().user;
                        final roles = user?.roles ?? [];

                        if (!roles.contains('Farmer')) {
                          final result = await showDialog<bool>(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: const Text(
                                    'Yêu cầu đăng ký vài trò Chủ vườn',
                                  ),
                                  content: const Text(
                                    'Bạn cần vai trò Chủ vườn để quản lý trang trại. Bạn có muốn đăng ký ngay không?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text('Không'),
                                    ),
                                    ElevatedButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text('Đăng ký'),
                                    ),
                                  ],
                                ),
                          );
                          if (result == true) {
                            context.push('/register-farmer');
                          }
                        } else {
                          context.push('/manager');
                        }
                      },
                    ),
                    Divider(color: Colors.grey.shade200, height: 1),
                    _buildListItem(
                      context,
                      iconAsset: 'lib/assets/icon/Adr.png',
                      label: 'Địa chỉ',
                      onTapCustom: () => context.push('/address'),
                    ),
                    Divider(color: Colors.grey.shade200, height: 1),
                    _buildListItem(
                      context,
                      iconAsset: 'lib/assets/icon2/Policy.png',
                      label: 'Điều khoản & Chính sách bảo mật',
                      onTapCustom: _launchTermsUrl,
                    ),

                    Divider(color: Colors.grey.shade200, height: 1),

                    ListTile(
                      leading: Image.asset(
                        'lib/assets/icon2/DeleteUser.png',
                        width: 35,
                        height: 35,
                        color: Colors.red,
                      ),
                      title: Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          'Xóa tài khoản vĩnh viễn',
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.red,
                          ),
                        ),
                      ),

                      onTap: () => onDeleteAccount(context),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (user != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  icon: Image.asset(
                    'lib/assets/icon2/Logout.png',
                    width: 30,
                    height: 30,
                    color: Colors.white,
                  ),

                  label: const Text('Đăng xuất'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context, {
    required String iconAsset,
    required String label,
    VoidCallback? onTapCustom,
  }) {
    final theme = Theme.of(context);

    // Tuỳ chỉnh kích thước icon bên trong (nhưng khung bao ngoài vẫn cố định)
    double innerIconSize = 34;
    if (iconAsset.contains('lib/assets/icon/Adr.png')) {
      innerIconSize = 40;
    } else if (iconAsset.contains('lib/assets/icon2/Policy.png')) {
      innerIconSize = 26;
    }

    return ListTile(
      leading: SizedBox(
        width: 40, // Cố định khung để không đẩy label
        height: 40,
        child: Center(
          child: Image.asset(
            iconAsset,
            width: innerIconSize,
            height: innerIconSize,
            fit: BoxFit.contain,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      title: Text(
        label,
        style: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w300,
          color: const Color.fromARGB(255, 33, 33, 33),
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: onTapCustom,
    );
  }
}
