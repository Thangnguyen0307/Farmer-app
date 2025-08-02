import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/home/widgets/Post/Post_Community.dart';
import 'package:farmrole/shared/types/Post_Model.dart';
import 'package:flutter/material.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  PostModel? post;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPostDetail();
  }

  Future<void> fetchPostDetail() async {
    try {
      final res = await PostService().getPostDetailById(widget.postId, context);
      setState(() {
        post = res;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (post == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy bài viết')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết bài viết')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: PostCommunity(post: post!),
        ),
      ),
    );
  }
}
