import 'package:farmrole/modules/auth/state/Upload_Manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UploadStatusBar extends StatelessWidget {
  const UploadStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<UploadManager>();
    final tasks =
        manager.uploads
            .where((e) => !e.isCompleted && e.error == null)
            .toList();

    if (tasks.isEmpty) return const SizedBox.shrink();

    return Column(
      children:
          tasks.map((task) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Material(
                elevation: 1,
                borderRadius: BorderRadius.circular(6),
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.cloud_upload,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: task.progress,
                              minHeight: 6,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(task.progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
