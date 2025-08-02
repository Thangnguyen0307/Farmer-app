import 'dart:io';
import 'dart:typed_data';

Future<List<Uint8List>> splitFileIntoChunks(
  File file, {
  int chunkSize = 1024 * 1024,
}) async {
  final bytes = await file.readAsBytes();
  final chunks = <Uint8List>[];

  for (int i = 0; i < bytes.length; i += chunkSize) {
    final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
    chunks.add(Uint8List.sublistView(bytes, i, end));
  }

  return chunks;
}
