import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/modules/home/widgets/Upload_Image/Upload_Image_Post.dart';

class PostTab extends StatefulWidget {
  const PostTab({super.key});

  @override
  State<PostTab> createState() => _PostTabState();
}

class _PostTabState extends State<PostTab> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  bool isLoading = false;
  String? _tagErrorMessage;
  final List<File> _selectedImages = [];
  final UploadImagePost _uploader = UploadImagePost();
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

  String? _errorMessage;

  InputDecoration _inputDecoration(String label) {
    final side = BorderSide(color: Colors.grey.shade400, width: 0.5);

    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: TextStyle(
        color: Colors.grey.shade800,
        fontWeight: FontWeight.w200,
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: side,
      ),

      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: side,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: side.copyWith(
          color: Theme.of(context).colorScheme.primary,
          width: 1.2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: side.copyWith(color: Colors.red.shade200),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: side.copyWith(color: Colors.red, width: 1),
      ),
    );
  }

  void _addTag(String tag) {
    tag = tag.trim();
    if (tag.isEmpty) return;
    if (_selectedTags.contains(tag)) {
      setState(() {
        _tagErrorMessage = 'Tag "$tag" đã tồn tại';
      });
      _tagController.clear();
      return;
    }
    setState(() {
      _selectedTags.add(tag);
      _tagErrorMessage = null;
    });
    _tagController.clear();
  }

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

  Future<void> _savePost() async {
    if (isLoading) return;
    setState(() => isLoading = true);

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
      prefs.remove('lastPost');
      setState(() {
        _titleController.clear();
        _contentController.clear();
        _tagController.clear();
        _selectedImages.clear();
        _selectedTags.clear();
        _errorMessage = null;
        isLoading = false;
      });
      if (!mounted) return;
      GoRouter.of(context).pushReplacement('/Outside', extra: postData);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>().user;

    return SingleChildScrollView(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'Người dùng',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (user?.rank != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${user!.rank}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ],
                      ),
                    if (user?.totalPoint != null)
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Điểm: ${user!.totalPoint}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            style: const TextStyle(
              fontWeight: FontWeight.w200,
              color: Color.fromARGB(255, 78, 78, 78),
            ),
            decoration: _inputDecoration('Tiêu đề'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            style: const TextStyle(
              fontWeight: FontWeight.w200,
              color: Color.fromARGB(255, 78, 78, 78),
            ),
            decoration: _inputDecoration('Nội dung'),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
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
            fieldViewBuilder: (context, _, focusNode, onSubmitted) {
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      style: const TextStyle(
                        fontWeight: FontWeight.w200,
                        color: Color.fromARGB(255, 78, 78, 78),
                      ),
                      focusNode: focusNode,
                      decoration: _inputDecoration('Tag'),
                      onSubmitted: _addTag,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () => _addTag(_tagController.text),
                  ),
                ],
              );
            },
            onSelected: _addTag,
          ),
          if (_tagErrorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _tagErrorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _selectedTags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.grey.shade300,
                        deleteIcon: const Icon(Icons.close),
                        onDeleted:
                            () => setState(() => _selectedTags.remove(tag)),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 24),
          Text('Hình ảnh (${_selectedImages.length}/5)'),
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
                            decoration: const BoxDecoration(
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
          const SizedBox(height: 16),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ),

          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : () {
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
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Đăng bài',
                          style: TextStyle(color: Colors.white),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
