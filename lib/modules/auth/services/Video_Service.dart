import 'dart:io';
import 'package:farmrole/env/env.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class VideoService {
  static final String _baseUrl = Environment.config.baseUrl;

  static Future<String> uploadVideoInChunks({
    required String token,
    required File videoFile,
    required String farmId,
    required String title,
    required String thumbnailUrl,
    required void Function(double) onProgress,
  }) async {
    final videoId = const Uuid().v4();
    final originalFileName = videoFile.path.split('/').last;
    final bytes = await videoFile.length();
    final chunkSize = 1024 * 1024;
    final totalChunks = (bytes / chunkSize).ceil();
    final raf = await videoFile.open();
    try {
      for (int i = 0; i < totalChunks; i++) {
        final start = i * chunkSize;
        final end = (start + chunkSize > bytes) ? bytes : start + chunkSize;
        final length = end - start;

        await raf.setPosition(start);
        final chunk = await raf.read(length);

        final uri = Uri.parse('$_baseUrl/video-farm/upload-stream');
        final request =
            http.MultipartRequest('POST', uri)
              ..headers['Authorization'] = 'Bearer $token'
              ..fields['chunkIndex'] = i.toString()
              ..fields['totalChunks'] = totalChunks.toString()
              ..fields['originalFileName'] = originalFileName
              ..fields['videoId'] = videoId
              ..fields['farmId'] = farmId
              ..fields['title'] = title
              ..fields['thumbnailUrl'] = thumbnailUrl
              ..files.add(
                http.MultipartFile.fromBytes(
                  'file',
                  chunk,
                  filename: 'chunk_$i.mp4',
                ),
              );

        final response = await request.send();
        if (response.statusCode != 200) {
          final errorResponse = await response.stream.bytesToString();
          throw Exception('Upload thất bại ở chunk $i: $errorResponse');
        }
        onProgress(i / totalChunks);
      }
      onProgress(1.0);
    } finally {
      await raf.close();
    }
    return videoId;
  }
}
