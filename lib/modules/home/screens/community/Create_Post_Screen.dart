import 'dart:convert';
import 'dart:io';
import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/home/widgets/Upload_Image_Post.dart';

class CreatePostScreen extends StatefulWidget {
  final Map<String, dynamic>? post;
  const CreatePostScreen({Key? key, this.post}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _errorMessage;
  final List<File> _selectedImages = [];
  final UploadImagePost _uploader = UploadImagePost();
  bool isEditing = false;
  String? postId;

  // Tags management
  final TextEditingController _tagController = TextEditingController();
  final List<String> _selectedTags = [];
  final List<String> _allTagSuggestions = [
    'dưa chua',
    'trâu',
    'nuôi cá',
    'rau sạch',
    'thu hoạch',
    'cây ăn trái',
    'gia cầm',
    'hữu cơ',
    'thiết bị',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      isEditing = true;
      _titleController.text = widget.post!['title'] ?? '';
      _contentController.text = widget.post!['description'] ?? '';
      final tags = widget.post!['tags']?.toString().split(',') ?? [];
      _selectedTags.addAll(tags.where((t) => t.isNotEmpty));
      postId = widget.post!['id']?.toString();
      if (widget.post!['images'] != null) {
        _selectedImages.addAll(
          (widget.post!['images'] as List<dynamic>).map(
            (p) => File(p.toString()),
          ),
        );
      }
    }
  }

  //ham chon anh
  Future<void> _onAddImage() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tối đa 5 hình ảnh!')));
      return;
    }
    final file = await _uploader.pickImageWithDialog(context);
    if (file != null) setState(() => _selectedImages.add(file));
  }

  //ham remove anh
  void _removeImage(int idx) => setState(() => _selectedImages.removeAt(idx));

  void _showFullImage(BuildContext context, File imageFile) {
    showDialog(
      context: context,
      builder:
          (ctx) => GestureDetector(
            onTap: () => Navigator.of(ctx).pop(),
            child: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: Hero(
                  tag: imageFile.path,
                  child: InteractiveViewer(child: Image.file(imageFile)),
                ),
              ),
            ),
          ),
    );
  }

  //ham add tag
  void _addTag(String tag) {
    tag = tag.trim();
    if (tag.isEmpty || _selectedTags.contains(tag)) return;
    setState(() {
      _selectedTags.add(tag);
    });
    _tagController.clear();
  }

  Future<void> _savePost() async {
    final prefs = await SharedPreferences.getInstance();
    final postData = {
      'title': _titleController.text,
      'description': _contentController.text,
      'tags': _selectedTags.join(','),
      'timestamp': DateTime.now().toIso8601String(),
      'images': _selectedImages.map((f) => f.path).toList(),
    };
    await prefs.setString('lastPost', jsonEncode(postData));

    try {
      await PostService.createPost(
        postData,
        _selectedImages.isNotEmpty ? _selectedImages : null,
        context,
      );
      if (!mounted) return;
      GoRouter.of(context).push('/Outside', extra: postData);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    }
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    labelStyle: TextStyle(
      color: Colors.grey.shade600,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: Colors.grey.shade100.withOpacity(0.5),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.read<UserProvider>().user;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Tạo bài viết mới',
          style: const TextStyle(fontWeight: FontWeight.w400),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            height: 40,
            width: 80,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 5, 193, 90),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                if (_titleController.text.trim().isEmpty ||
                    _contentController.text.trim().isEmpty) {
                  setState(
                    () =>
                        _errorMessage =
                            'Tiêu đề và nội dung không được bỏ trống!',
                  );
                  return;
                }
                _savePost();
              },
              child: const Text(
                'Đăng',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      user?.avatar != null
                          ? NetworkImage(
                            AuthService.getFullAvatarUrl(user!.avatar!),
                          )
                          : null,
                  radius: 30,
                  child:
                      user?.avatar == null
                          ? const Icon(Icons.person, size: 30)
                          : null,
                ),
                const SizedBox(width: 12),
                Text(
                  user?.fullName ?? 'Người dùng',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: _inputDecoration('Tiêu đề'),
              style: const TextStyle(fontWeight: FontWeight.w200),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: _inputDecoration('Nội dung'),
              style: const TextStyle(fontWeight: FontWeight.w200),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            // Tags container
            Autocomplete<String>(
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty)
                  return const Iterable<String>.empty();
                return _allTagSuggestions.where(
                  (t) => t.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
                );
              },
              fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: _inputDecoration('Tag'),
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade800,
                        ),
                        onSubmitted: (v) => _addTag(v),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () => _addTag(controller.text),
                    ),
                  ],
                );
              },
              onSelected: (value) => _addTag(value),
            ),
            const SizedBox(height: 8),
            // Tag chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _selectedTags
                      .map(
                        (tag) => Chip(
                          label: Text(
                            tag,
                            style: TextStyle(color: Colors.grey.shade800),
                          ),
                          backgroundColor: Colors.grey.shade300.withOpacity(
                            0.6,
                          ),
                          deleteIcon: const Icon(Icons.close),
                          elevation: 0,
                          onDeleted:
                              () => setState(() => _selectedTags.remove(tag)),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Hình ảnh (${_selectedImages.length}/5)',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  if (i == _selectedImages.length) {
                    return GestureDetector(
                      onTap: _onAddImage,
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add_a_photo,
                            size: 28,
                            color: Colors.black38,
                          ),
                        ),
                      ),
                    );
                  }
                  final file = _selectedImages[i];
                  return GestureDetector(
                    onTap: () => _showFullImage(context, file),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            file,
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(i),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black45,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
