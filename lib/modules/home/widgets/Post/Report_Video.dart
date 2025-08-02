import 'package:farmrole/modules/auth/services/Report_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/Video_Model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportVideo extends StatelessWidget {
  final VideoModel video;
  final VoidCallback? onDeleted;

  const ReportVideo({Key? key, required this.video, this.onDeleted})
    : super(key: key);

  void _showReportDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Báo cáo bài viết'),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Nhập lý do báo cáo...',
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: Color.fromARGB(255, 192, 191, 191),
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập lý do báo cáo'),
                    ),
                  );
                  return;
                }

                Navigator.of(context, rootNavigator: true).pop();

                final rootContext =
                    Navigator.of(context, rootNavigator: true).context;

                await Future.delayed(const Duration(milliseconds: 100));
                await _reportPost(rootContext, reason);
              },
              child: const Text('Gửi'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _reportPost(BuildContext context, String reason) async {
    final user = context.read<UserProvider>().user;
    debugPrint('ReportPost - Reporting post.id: ${video.id}');
    try {
      await ReportService.createReport(
        token: user!.token!,
        type: 'VIDEO_FARM',
        targetVideoFarm: video.id,
        reason: reason,
      );

      if (context.mounted) {
        // Show dialog báo cáo thành công
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return AlertDialog(
              title: const Text('Đã gửi báo cáo'),
              content: const Text(
                'Cảm ơn bạn đã báo cáo, chúng tôi sẽ xem xét.',
              ),
              actions: [
                TextButton(
                  onPressed:
                      () => Navigator.of(context, rootNavigator: true).pop(),
                  child: const Text('Đóng'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
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
              child: Text('Báo cáo bài viết'),
            ),
          ],
      icon: const Icon(Icons.more_horiz, color: Colors.white),
    );
  }
}
