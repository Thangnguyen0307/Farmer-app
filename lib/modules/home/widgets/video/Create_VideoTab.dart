import 'dart:io';
import 'package:farmrole/modules/auth/services/CRUD_Farm_Service.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/auth/services/Video_Service.dart';
import 'package:farmrole/modules/auth/state/Farm_Provider.dart';
import 'package:farmrole/modules/auth/state/Upload_Manager.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/widgets/Upload_Image/Upload_Image_Post.dart';
import 'package:farmrole/modules/home/widgets/video/UploadStatusBar.dart';
import 'package:farmrole/shared/types/Farm_Model.dart';
import 'package:farmrole/shared/types/Upload_Task_Model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

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
  File? _thumbnailFile;
  String? _selectedFarmId;
  bool _isLoading = true;
  bool _isPickingVideo = false;
  bool isProcessing = false;

  final UploadImagePost _uploader = UploadImagePost();

  String _translateStatus(String status) {
    switch (status) {
      case 'active':
        return 'Đang hoạt động';
      case 'pending':
        return 'Đang chờ duyệt';
      case 'inactive':
        return 'Chưa hoạt động';
      default:
        return status;
    }
  }

  int getMaxDurationForRank(String? rank) {
    switch (rank) {
      case 'Hạt Giống Thần':
        return 1;
      case 'Chậu Cây Tiên':
        return 2;
      case 'Trang Trại Huyền Thoại':
        return 3;
      case 'Cánh Đồng Kỹ Sĩ':
        return 5;
      case 'Vườn Sạch Chiến Binh':
        return 7;
      default:
        return 10; // mặc định nếu rank không xác định
    }
  }

  @override
  void initState() {
    super.initState();
    CrudFarmService().getmyFarm(context).then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _pickVideo() async {
    if (_uploading) return;
    setState(() {
      _isPickingVideo = true;
    });
    final picker = ImagePicker();
    final user = context.read<UserProvider>().user;
    final picked = await showModalBottomSheet<XFile?>(
      context: context,
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.videocam),
                  title: const Text('Quay video'),
                  onTap: () async {
                    final recorded = await picker.pickVideo(
                      source: ImageSource.camera,
                      maxDuration: const Duration(minutes: 5),
                    );
                    Navigator.pop(context, recorded);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.video_library),
                  title: const Text('Chọn từ thư viện'),
                  onTap: () async {
                    final selected = await picker.pickVideo(
                      source: ImageSource.gallery,
                      maxDuration: const Duration(minutes: 5),
                    );
                    Navigator.pop(context, selected);
                  },
                ),
              ],
            ),
          ),
    );

    if (picked != null) {
      final file = File(picked.path);
      final isMp4 = picked.path.toLowerCase().endsWith(".mp4");

      if (!isMp4) {
        setState(() {
          _error = 'Chỉ hỗ trợ video định dạng .mp4';
          _videoFile = null;
        });
        return;
      }

      final videoDuration = await _getVideoDurationInSeconds(file.path);
      final maxDuration = getMaxDurationForRank(user?.rank) * 60;

      if (videoDuration > maxDuration) {
        setState(() {
          _error =
              'Hạng "${user?.rank}" chỉ được upload video tối đa ${maxDuration ~/ 60} phút.\nVideo bạn chọn dài ${(videoDuration / 60).toStringAsFixed(1)} phút.';
          _videoFile = null;
        });
        return;
      }

      setState(() {
        _videoFile = file;
        _error = null;
        _isPickingVideo = false;
      });
    } else {
      setState(() {
        _isPickingVideo = false;
      });
    }
  }

  //ham lay do dai video
  Future<int> _getVideoDurationInSeconds(String path) async {
    final videoPlayerController = VideoPlayerController.file(File(path));
    await videoPlayerController.initialize();
    final duration = videoPlayerController.value.duration;
    videoPlayerController.dispose();
    return duration.inSeconds;
  }

  Future<void> _uploadVideo() async {
    final user = context.read<UserProvider>().user;
    final farms = context.read<FarmProvider>().farms;
    final manager = context.read<UploadManager>();

    setState(() {
      _uploading = true;
    });

    if (_selectedFarmId == null ||
        _titleController.text.trim().isEmpty ||
        _videoFile == null) {
      setState(() => _error = 'Vui lòng điền đầy đủ thông tin');
      return;
    }

    FarmModel? selectedFarm;
    try {
      selectedFarm = farms.firstWhere((f) => f.id == _selectedFarmId);
    } catch (_) {
      selectedFarm = null;
    }

    if (selectedFarm == null) {
      setState(() => _error = 'Vui lòng chọn trang trại');
      return;
    }

    if (selectedFarm.status != 'active') {
      setState(() {
        _error =
            'Trang trại "${selectedFarm?.name}" hiện ${_translateStatus(selectedFarm!.status)}. Không thể đăng video.';
      });
      return;
    }

    // Tạo task mới
    final task = UploadTaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      farmId: _selectedFarmId!,
      videoFile: _videoFile!,
    );

    manager.addTask(task);

    try {
      final videoId = await VideoService.uploadVideoInChunks(
        token: user!.token!,
        title: task.title,
        farmId: task.farmId,
        videoFile: task.videoFile,
        thumbnailUrl: '',
        onProgress: (progress) {
          manager.updateProgress(task.id, progress);
        },
      );

      if (_thumbnailFile != null) {
        await PostService.uploadThumbnailForVideo(
          token: user.token!,
          videoId: videoId,
          thumbnailFile: _thumbnailFile!,
        );
      }

      manager.completeTask(task.id);
      print("Uploading thumbnail path: ${_thumbnailFile?.path}");

      if (mounted) {
        setState(() {
          _titleController.clear();
          _videoFile = null;
          _thumbnailFile = null;
          _error = null;
          _uploading = false;
        });

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
      manager.failTask(task.id, e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi upload video: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _uploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final farms = context.watch<FarmProvider>().farms;
    final side = BorderSide(color: Colors.grey.shade400, width: 0.5);
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (farms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber, size: 48, color: Colors.orange),
            const SizedBox(height: 12),
            const Text(
              'Bạn chưa có trang trại nào.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                context.push('/register-step1-farm');
              },
              child: const Text('Tạo trang trại'),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const UploadStatusBar(),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                    farms.isEmpty
                        ? [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              'Chưa có farm',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ]
                        : farms
                            .map(
                              (f) => DropdownMenuItem(
                                value: f.id,
                                child: Text(
                                  f.status == 'active'
                                      ? f.name
                                      : '${f.name} (${_translateStatus(f.status)})',
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
                    _isPickingVideo
                        ? const CircularProgressIndicator()
                        : _videoFile == null
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
          Opacity(
            opacity: _uploading ? 0.6 : 1.0, // mờ đi khi đang upload
            child: SizedBox(
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
          ),
        ],
      ),
    );
  }
}
