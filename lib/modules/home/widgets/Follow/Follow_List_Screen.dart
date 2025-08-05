import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/shared/types/Follow_Model.dart';
import 'package:flutter/material.dart';

class FollowListScreen extends StatelessWidget {
  final String title;
  final List<FollowUser> users;

  const FollowListScreen({super.key, required this.title, required this.users});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body:
          users.isEmpty
              ? const Center(child: Text('Không có người dùng nào.'))
              : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage:
                          user.avatar?.isNotEmpty == true
                              ? NetworkImage(
                                AuthService.getFullAvatarUrl(user.avatar!),
                              )
                              : null,
                      child:
                          user.avatar?.isNotEmpty == true
                              ? null
                              : const Icon(Icons.person, size: 24),
                    ),
                    title: Text(user.fullName),
                    onTap: () {
                      // TODO: mở profile người dùng nếu muốn
                    },
                  );
                },
              ),
    );
  }
}
