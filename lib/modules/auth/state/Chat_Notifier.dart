import 'package:farmrole/shared/types/DB_Helper.dart';
import 'package:flutter/material.dart';

class ChatNotifier extends ChangeNotifier {
  int _totalUnread = 0;
  int get totalUnread => _totalUnread;

  Future<void> fetchTotalUnread(String userId) async {
    _totalUnread = await DBHelper().getTotalUnreadCount(userId);
    print('📥 Tổng unread cập nhật: $totalUnread');
    notifyListeners();
  }
}
