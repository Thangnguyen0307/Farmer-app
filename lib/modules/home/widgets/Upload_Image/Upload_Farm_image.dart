import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class UploadFarmImage {
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
    File? compressedFile;

    await showModalBottomSheet(
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
                    if (picked != null) {
                      compressedFile = await compressImage(picked);
                      Navigator.pop(context);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text("Chọn từ thư viện"),
                  onTap: () async {
                    final picked = await pickImageGallery();
                    if (picked != null) {
                      compressedFile = await compressImage(picked);
                      Navigator.pop(context);
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Center(child: Text("Hủy")),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );

    return compressedFile;
  }

  //nen anh
  Future<File?> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(dir.path, "avatar_temp.jpg");
    int qua = 70;

    while (qua >= 20) {
      final compressFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: qua,
      );
      if (compressFile == null) return null;
      final sizeKb = await compressFile.length() / 2024;
      if (sizeKb <= 2000) {
        return File(compressFile.path);
      }
      qua -= 10;
    }
    return null;
  }
}
