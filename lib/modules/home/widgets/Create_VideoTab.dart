import 'dart:io';

import 'package:farmrole/modules/auth/services/CRUD_Farm_Service.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/auth/state/Farm_Provider.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class VideoTab extends StatefulWidget {
  const VideoTab({Key? key}) : super(key: key);
  @override
  State<VideoTab> createState() => _VideoTabState();
}

class _VideoTabState extends State<VideoTab> {
  final TextEditingController _titleController = TextEditingController();
  File? _videoFile;
  String? _error;
  bool _uploading = false;

  String? _selectedFarmId;

  @override
  void initState() {
    super.initState();
    CrudFarmService().getmyFarm(context);
  }

  Future<void> _pickVideo() async {
    final picked = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );
    if (picked != null) {
      setState(() => _videoFile = File(picked.path));
    }
  }

  Future<void> _uploadVideo() async {
    final user = context.read<UserProvider>().user;
    if (_selectedFarmId == null ||
        _titleController.text.trim().isEmpty ||
        _videoFile == null) {
      setState(() => _error = 'Vui lòng điền đầy đủ thông tin');
      return;
    }
    setState(() {
      _uploading = true;
      _error = null;
    });
    try {
      await PostService.uploadVideoFarm(
        token: user!.token!,
        title: _titleController.text.trim(),
        farmId: _selectedFarmId!,
        videoFile: _videoFile!,
        context: context,
      );
      _titleController.clear();
      setState(() => _videoFile = null);
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text("Thành công"),
                  ],
                ),
                content: const Text(
                  "Video đã được tải lên.\nVui lòng chờ duyệt trước khi hiển thị.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("OK"),
                  ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final farms = context.watch<FarmProvider>().farms;
    final side = BorderSide(color: Colors.grey.shade400, width: 0.5);
    return farms.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trang trại',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    elevation: 1,
                    value: _selectedFarmId,
                    hint: const Text(
                      'Chọn trang trại',
                      style: TextStyle(color: Colors.grey),
                    ),
                    isExpanded: true,
                    items:
                        farms
                            .where((f) => f.status == 'active')
                            .map(
                              (f) => DropdownMenuItem(
                                value: f.id,
                                child: Text(
                                  f.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _selectedFarmId = v),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'Tiêu đề video',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                style: const TextStyle(
                  fontWeight: FontWeight.w200,
                  color: Color.fromARGB(255, 78, 78, 78),
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  hintText: 'Nhập tiêu đề...',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w100,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: side,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // — Chọn video —
              Text(
                'Video clip',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickVideo,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child:
                        _videoFile == null
                            ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 32,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Chọn video',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.videocam, color: Colors.grey),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _videoFile!.path.split('/').last,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _uploading ? null : _uploadVideo,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _uploading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Đăng video',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        );
  }
}
