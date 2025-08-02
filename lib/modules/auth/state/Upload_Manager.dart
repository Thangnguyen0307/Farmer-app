import 'package:farmrole/modules/home/widgets/noti/notification_helper.dart';
import 'package:farmrole/shared/types/Upload_Task_Model.dart';
import 'package:flutter/material.dart';

class UploadManager with ChangeNotifier {
  final List<UploadTaskModel> _uploads = [];

  List<UploadTaskModel> get uploads => _uploads;

  void addTask(UploadTaskModel task) {
    _uploads.add(task);
    notifyListeners();
  }

  void updateProgress(String id, double progress) {
    final task = _uploads.firstWhere(
      (e) => e.id == id,
      orElse: () => throw 'Task not found',
    );
    task.progress = progress;
    notifyListeners();
  }

  void completeTask(String id) {
    final task = _uploads.firstWhere((e) => e.id == id);
    task.isCompleted = true;
    notifyListeners();
    showUploadSuccessNotification(task.title);
  }

  void markAllCompletedAsSeen() {
    for (var task in _uploads) {
      if (task.isCompleted && !task.isSeen) {
        task.isSeen = true;
      }
    }
    notifyListeners();
  }

  void failTask(String id, String error) {
    final task = _uploads.firstWhere((e) => e.id == id);
    task.error = error;
    notifyListeners();
  }
}
