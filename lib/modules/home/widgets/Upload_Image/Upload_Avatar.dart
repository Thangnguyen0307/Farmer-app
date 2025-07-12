import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class UploadAvatar {
  final ImagePicker _imagePicker = ImagePicker();

  //chon anh tu thu vien
  Future<File?> pickImageGallery() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    return picked != null ? File(picked.path) : null;
  }

  //chup anh tu camera
  Future<File?> pickCamera() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.camera);
    return picked != null ? File(picked.path) : null;
  }

  //dialog chon gallery or camera
  Future<File?> pickImageWithDialog(BuildContext context) async {
    File? selectFile;
    await showModalBottomSheet<File?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (ctx) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text("Chụp ảnh"),
                  onTap: () async {
                    final picked = await pickCamera();
                    selectFile = picked;
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text("Chọn từ thư viện"),
                  onTap: () async {
                    final picked = await pickImageGallery();
                    selectFile = picked;
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Center(child: Text("Hủy")),
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
    );
    return selectFile;
  }

  //nen anh
  Future<File?> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(dir.path, "avatar_temp.jpg");
    int qua = 70;
    int minHeight = 1080;
    int minWidth = 1080;
    while (qua >= 20) {
      final compressFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: qua,
        minHeight: minHeight,
        minWidth: minWidth,
      );
      if (compressFile == null) return null;
      final sizeKb = await compressFile.length() / 2024;
      if (sizeKb <= 500) {
        return File(compressFile.path);
      }
      qua -= 10;
      minHeight -= 100;
      minWidth -= 100;
    }
    return null;
  }
}
