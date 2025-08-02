import 'package:flutter/material.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/shared/types/User_Model.dart';
import 'package:farmrole/modules/auth/services/Auth_Service.dart';

class LikeUserListScreen extends StatefulWidget {
  final String postId;

  const LikeUserListScreen({super.key, required this.postId});

  @override
  State<LikeUserListScreen> createState() => _LikeUserListScreenState();
}

class _LikeUserListScreenState extends State<LikeUserListScreen> {
  List<UserModel> users = [];
  int page = 1;
  int totalPages = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    if (isLoading || page > totalPages) return;

    setState(() => isLoading = true);

    final res = await PostService().getPostLikes(
      context: context,
      postId: widget.postId,
      page: page,
      limit: 20,
    );

    final List<UserModel> fetchedUsers =
        (res['users'] as List).map((json) => UserModel.fromJson(json)).toList();

    setState(() {
      users.addAll(fetchedUsers);
      totalPages = res['totalPages'] ?? 1;
      page++;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Người đã thích bài viết')),
      body: ListView.builder(
        itemCount: users.length + 1,
        itemBuilder: (context, index) {
          if (index < users.length) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  AuthService.getFullAvatarUrl(user.avatar),
                ),
              ),
              title: Text(user.fullName),
            );
          }
          if (isLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (page <= totalPages) {
            fetchUsers();
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
