import 'dart:io';

class UploadTaskModel {
  final String id;
  final String title;
  final File videoFile;
  final String farmId;
  double progress; // từ 0.0 đến 1.0
  bool isCompleted;
  String? error;
  bool isSeen;

  UploadTaskModel({
    required this.id,
    required this.title,
    required this.videoFile,
    required this.farmId,
    this.progress = 0.0,
    this.isCompleted = false,
    this.error,
    this.isSeen = false,
  });
}
