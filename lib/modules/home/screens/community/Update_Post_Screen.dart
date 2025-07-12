import 'dart:io';
import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:flutter/material.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/shared/types/Post_Model.dart';

class UpdatePostScreen extends StatefulWidget {
  final PostModel post;

  const UpdatePostScreen({super.key, required this.post});

  @override
  State<UpdatePostScreen> createState() => _UpdatePostScreenState();
}

class _UpdatePostScreenState extends State<UpdatePostScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  final TextEditingController _tagController = TextEditingController();
  late List<String> _existingImages;
  late List<String> _tags;

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
    _titleController = TextEditingController(text: widget.post.title);
    _descController = TextEditingController(text: widget.post.description);
    _tags = List<String>.from(widget.post.tags ?? []);
    _existingImages = List<String>.from(widget.post.images ?? []);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(3)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    );
  }

  void _addTag(String tag) {
    tag = tag.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
    }
    _tagController.clear();
  }

  void _showNetworkImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder:
          (ctx) => GestureDetector(
            onTap: () => Navigator.of(ctx).pop(),
            child: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: InteractiveViewer(
                  child: Image.network(AuthService.getFullAvatarUrl(url)),
                ),
              ),
            ),
          ),
    );
  }

  Future<void> _submitUpdate() async {
    try {
      final success = await PostService.updatePost(
        context: context,
        postId: widget.post.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        tags: _tags,
        existingImageUrls: _existingImages,
        imagesFiles: [], // không cho phép upload ảnh mới
      );

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật bài viết thành công')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cập nhật thất bại')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cập nhật bài viết")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: _inputDecoration("Tiêu đề"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: _inputDecoration("Nội dung"),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            Autocomplete<String>(
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return _allTagSuggestions.where(
                  (tag) => tag.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
                );
              },
              fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagController,
                        focusNode: focusNode,
                        decoration: _inputDecoration("Tag"),
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
            Wrap(
              spacing: 8,
              children:
                  _tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () => setState(() => _tags.remove(tag)),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 12),
            Text("Hình ảnh (${_existingImages.length}/5)"),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _existingImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final url = _existingImages[index];
                  return GestureDetector(
                    onTap: () => _showNetworkImage(context, url),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        AuthService.getFullAvatarUrl(url),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _submitUpdate,
              icon: const Icon(Icons.save),
              label: const Text("Lưu thay đổi"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
