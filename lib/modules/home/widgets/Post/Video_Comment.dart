import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:farmrole/modules/auth/services/Auth_Service.dart';
import 'package:farmrole/modules/auth/services/Post_Service.dart';
import 'package:farmrole/modules/auth/state/User_Provider.dart';
import 'package:farmrole/shared/types/Comment_Video_Model.dart';

void showVideoComments(BuildContext context, String videoId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => VideoCommentScreen(videoId: videoId),
  );
}

class VideoCommentScreen extends StatefulWidget {
  final String videoId;
  const VideoCommentScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  State<VideoCommentScreen> createState() => _VideoCommentScreenState();
}

class _VideoCommentScreenState extends State<VideoCommentScreen> {
  final _commentCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<CommentVideoModel> _comments = [];
  bool _loading = true, _posting = false;
  int? _replyIndex;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() => _loading = true);
    try {
      final list = await PostService().fetchVideoComments(
        context: context,
        videoId: widget.videoId,
      );
      setState(() => _comments = list);
    } catch (e) {
      debugPrint('Error load comments: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _posting = true);

    final ok =
        _replyIndex == null
            ? await PostService().postVideoComment(
              context: context,
              videoId: widget.videoId,
              comment: text,
            )
            : await PostService().replyVideoComment(
              context: context,
              videoId: widget.videoId,
              commentIndex: _replyIndex!,
              replyText: text,
            );

    if (ok) {
      _commentCtrl.clear();
      _replyIndex = null;
      await _loadComments();
      // scroll xuống cuối
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gửi bình luận thất bại')));
    }

    setState(() => _posting = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>().user;
    final primary = Theme.of(context).colorScheme.primary;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder:
          (_, controller) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                // Handle
                SafeArea(
                  top: true,
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: const Text(
                    'Bình luận',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                const Divider(
                  height: 0.5,
                  thickness: 1,
                  color: Color.fromARGB(255, 193, 192, 192),
                ),

                // Danh sách bình luận
                Expanded(
                  child:
                      _loading
                          ? const Center(child: CircularProgressIndicator())
                          : _comments.isEmpty
                          ? Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 64),
                              child: Text(
                                'Chưa có bình luận nào',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ),
                          )
                          : ListView.builder(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _comments.length,
                            itemBuilder: (_, i) {
                              final c = _comments[i];
                              return _buildCommentItem(c, i, primary);
                            },
                          ),
                ),

                const Divider(
                  height: 0.25,
                  color: Color.fromARGB(255, 216, 215, 215),
                ),
                // Banner trả lời (nếu đang reply)
                if (_replyIndex != null)
                  Container(
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Đang trả lời ${_comments[_replyIndex!].user.fullName}',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _replyIndex = null),
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ],
                    ),
                  ),

                AnimatedPadding(
                  duration: const Duration(milliseconds: 100),
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
                              controller: _commentCtrl,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w300,
                                ),
                                hintText:
                                    _replyIndex == null
                                        ? 'Viết bình luận...'
                                        : 'Viết trả lời...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                fillColor: Colors.grey.shade100,
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendComment(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _posting
                              ? const CircularProgressIndicator()
                              : IconButton(
                                icon: Icon(Icons.send, color: primary),
                                onPressed: _sendComment,
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildCommentItem(CommentVideoModel c, int idx, Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(
              AuthService.getFullAvatarUrl(c.user.avatar),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      c.user.fullName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _timeAgo(c.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _replyIndex = idx),
                      child: Text(
                        'Trả lời',
                        style: TextStyle(fontSize: 12, color: primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                //comment
                Text(
                  c.comment,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                //Replies
                if (c.replies.isNotEmpty)
                  ...c.replies.map((r) => _buildReplyItem(r)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyItem(CommentVideoModel r) {
    return Padding(
      padding: const EdgeInsets.only(left: 42, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage(
              AuthService.getFullAvatarUrl(r.user.avatar),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      r.user.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _timeAgo(r.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(r.comment, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }
}
