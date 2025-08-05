import 'package:farmrole/shared/types/DB_Helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotiScreen extends StatefulWidget {
  const NotiScreen({super.key});

  @override
  State<NotiScreen> createState() => _NotiScreenState();
}

class _NotiScreenState extends State<NotiScreen> {
  List<Map<String, dynamic>> notifications = [];

  String _formatTime(String isoTime) {
    try {
      final dateTime = DateTime.parse(isoTime);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final notis = await DBHelper().getAllNotifications();
    setState(() {
      notifications = notis;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final background = theme.colorScheme.background;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          'Thông báo',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body:
          notifications.isEmpty
              ? Center(
                child: Text(
                  'Chưa có thông báo nào',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 1),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 1),
                itemBuilder: (context, index) {
                  final noti = notifications[index];
                  final isUnread = noti['unread'] == 1;

                  return GestureDetector(
                    onTap: () async {
                      if (isUnread) {
                        await DBHelper().markNotificationAsRead(noti['id']);
                        setState(() {
                          final updatedNoti = Map<String, dynamic>.from(
                            notifications[index],
                          );
                          updatedNoti['unread'] = 0;

                          notifications = List<Map<String, dynamic>>.from(
                            notifications,
                          );
                          notifications[index] = updatedNoti;
                        });
                      }
                      // TODO: Nếu muốn mở chi tiết thì làm ở đây
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isUnread ? Colors.grey.shade100 : Colors.white,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isUnread
                                    ? Icons.notifications_active
                                    : Icons.notifications_none,
                                color: isUnread ? primary : Colors.grey,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      noti['title'] ?? '',
                                      style: GoogleFonts.nunito(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      noti['note'] ?? '',
                                      style: GoogleFonts.nunito(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              _formatTime(noti['createdAt']),
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
