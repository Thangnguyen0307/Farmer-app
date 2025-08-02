import 'package:farmrole/modules/auth/services/Report_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportUser extends StatelessWidget {
  final String targetUserId;

  const ReportUser({super.key, required this.targetUserId});

  void _showReportDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Lý do báo cáo người dùng'),
            content: TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Nhập lý do bạn muốn báo cáo người dùng này...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Color.fromARGB(255, 192, 191, 191),
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final reason = reasonController.text.trim();
                  if (reason.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập lý do')),
                    );
                    return;
                  }
                  Navigator.of(context).pop();
                  final rootContext = Navigator.of(context).context;
                  await Future.delayed(const Duration(milliseconds: 100));
                  await _reportUser(rootContext, reason);
                },
                child: const Text('Gửi'),
              ),
            ],
          ),
    );
  }

  Future<void> _reportUser(BuildContext context, String reason) async {
    final user = context.read<UserProvider>().user;
    try {
      await ReportService.createReport(
        token: user!.token!,
        type: 'USER',
        targetUser: targetUserId,
        reason: reason,
      );
      if (context.mounted) {
        Future.microtask(() {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Đã gửi báo cáo'),
                  content: const Text(
                    'Cảm ơn bạn đã báo cáo, chúng tôi sẽ xem xét.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
          );
        });
      }
    } catch (e) {
      if (context.mounted) {
        Future.microtask(() {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Lỗi'),
                  content: Text('Đã có lỗi xảy ra: $e'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
          );
        });
      }
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Đã gửi báo cáo'),
            content: const Text('Cảm ơn bạn đã báo cáo, chúng tôi sẽ xem xét.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'report') _showReportDialog(context);
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'report',
              child: Text('Báo cáo người dùng'),
            ),
          ],
      icon: const Icon(Icons.more_vert),
    );
  }
}
