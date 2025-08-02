import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> showUploadSuccessNotification(String title) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'upload_channel', // ID kênh
        'Upload Notifications', // Tên kênh
        channelDescription: 'Thông báo khi upload hoàn tất',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000, // ID ngẫu nhiên
    'Hoàn tất upload',
    '$title đã upload thành công!',
    platformChannelSpecifics,
  );
}
