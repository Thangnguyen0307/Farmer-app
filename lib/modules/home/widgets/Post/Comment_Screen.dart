import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/home/widgets/Post/Comment_Option_Menu.dart';
import 'package:farmrole/shared/types/Comment_Model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';

class CommentScreen extends StatefulWidget {
  final String postId;
  final ScrollController? scrollController;
  final VoidCallback? onCommentAdded;

  const CommentScreen({
    Key? key,
    required this.postId,
    this.scrollController,
    this.onCommentAdded,
  }) : super(key: key);
  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  List<CommentModel> comments = [];
  final TextEditingController _commentController = TextEditingController();
  bool isLoading = true;
  int? replyIndex;
  bool isSortNewest = true;

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    final data = await PostService().getComments(
      context: context,
      postId: widget.postId,
    );
    if (!mounted) return;
    setState(() {
      comments = data;
      isLoading = false;
    });
  }

  Future<void> sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    bool success;
    if (replyIndex != null) {
      success = await PostService().replyComment(
        context: context,
        postId: widget.postId,
        commentIndex: replyIndex!,
        replyText: text,
      );
    } else {
      success = await PostService().commentPost(
        context: context,
        postId: widget.postId,
        comment: text,
      );
    }

    if (success) {
      _commentController.clear();
      replyIndex = null;
      widget.onCommentAdded?.call();
      await fetchComments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>().user;
    final primary = Theme.of(context).colorScheme.primary;
    final displayComments =
        isSortNewest ? comments.reversed.toList() : comments;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : comments.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 64),
                        child: Text(
                          'Chưa có bình luận nào',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    )
                    : ListView.builder(
                      reverse: !isSortNewest,
                      controller: widget.scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: displayComments.length,
                      itemBuilder: (_, i) {
                        final c = displayComments[i];
                        final u = c.user;
                        print(
                          'UI index: $i, Server index: ${c.index}, Comment: ${c.comment}',
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar chính
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(
                                  AuthService.getFullAvatarUrl(u.avatar),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Nội dung comment
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Hàng tên – thời gian – nút Trả lời
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            u.fullName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        const SizedBox(width: 8),

                                        Text(
                                          timeAgo(c.createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: CommentOptionMenu(
                                            postId: widget.postId,
                                            commentIndex: c.index,
                                            isMyPost:
                                                user?.id == c.postAuthor.id,
                                            onDeleted: () => fetchComments(),
                                          ),
                                        ),

                                        const Spacer(),

                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              final realIndex = comments
                                                  .indexOf(displayComments[i]);
                                              replyIndex = realIndex;
                                              _commentController.clear();
                                            });
                                          },
                                          child: Text(
                                            'Trả lời',
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              color: primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 4),

                                    // Text comment
                                    Text(
                                      c.comment,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black54,
                                      ),
                                    ),

                                    // Replies (nếu có)
                                    if (c.replies.isNotEmpty)
                                      ...c.replies.map((r) {
                                        final ru = r.user;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Avatar reply
                                              CircleAvatar(
                                                radius: 14,
                                                backgroundImage: NetworkImage(
                                                  AuthService.getFullAvatarUrl(
                                                    ru.avatar,
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(width: 8),

                                              // Nội dung reply
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            ru.fullName,
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors
                                                                      .black87,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          timeAgo(r.createdAt),
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade600,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 28,
                                                          height: 28,
                                                          child: CommentOptionMenu(
                                                            postId:
                                                                widget.postId,
                                                            commentIndex:
                                                                c.index,
                                                            replyIndex: r.index,
                                                            isMyPost:
                                                                user?.id ==
                                                                comments[i]
                                                                    .postAuthor
                                                                    .id,
                                                            onDeleted:
                                                                () =>
                                                                    fetchComments(),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      r.comment,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
          //Banner "Đang trả lời"
          if (replyIndex != null)
            Container(
              width: double.infinity,
              color: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Đang trả lời ${comments[replyIndex!].user.fullName}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => replyIndex = null),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),
          const Divider(
            height: 0.25,
            color: Color.fromARGB(255, 216, 215, 215),
          ),
          AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SafeArea(
              top: false,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    if (user?.avatar != null)
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(
                          AuthService.getFullAvatarUrl(user!.avatar!),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          hintText: 'Viết bình luận...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w300,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => sendComment(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.send, color: primary),
                      onPressed: sendComment,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String timeAgo(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }
}
