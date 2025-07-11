import 'package:farmrole/modules/home/widgets/Post/Comment_Screen.dart';
import 'package:flutter/material.dart';

class CommentBottomSheet extends StatelessWidget {
  final String postId;
  const CommentBottomSheet({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7, // Chiếm 70% màn hình ban đầu
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Thanh kéo trên đầu
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Màn bình luận chính
              Expanded(
                child: CommentScreen(
                  postId: postId,
                  scrollController: scrollController,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
