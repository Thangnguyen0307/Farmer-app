import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // Dữ liệu mẫu cho màn hình Community
  final List<Map<String, String>> _posts = [
    {
      'user': 'Alice',
      'content': 'Chào mọi người! Mình vừa thu hoạch xong vụ lúa.',
    },
    {'user': 'Bob', 'content': 'Ai có kinh nghiệm nuôi cá tra không?'},
    {
      'user': 'Carol',
      'content': 'Làm sao để phòng bệnh đạo ôn trên lúa hiệu quả?',
    },
    {
      'user': 'David',
      'content': 'Mình đang tìm nguồn giống ngô chất lượng cao.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cộng đồng'), centerTitle: true),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bài viết...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 12,
                ),
              ),
            ),
          ),

          // Danh sách bài đăng
          Expanded(
            child: ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text(post['user']![0]),
                    ),
                    title: Text(post['user']!),
                    subtitle: Text(post['content']!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
