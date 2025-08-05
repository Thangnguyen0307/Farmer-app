import 'package:farmrole/modules/auth/services/Follow_Service.dart';
import 'package:flutter/material.dart';

class FollowButton extends StatefulWidget {
  final String targetUserId;
  final String token;
  final bool isFollowingInitial;

  const FollowButton({
    super.key,
    required this.targetUserId,
    required this.token,
    required this.isFollowingInitial,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late bool _isFollowing = widget.isFollowingInitial;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.isFollowingInitial;
  }

  Future<void> _toggleFollow() async {
    if (_isFollowing) {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('Xác nhận'),
              content: Text('Bạn có chắc muốn bỏ theo dõi người này không?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('HỦY'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('ĐỒNG Ý'),
                ),
              ],
            ),
      );

      if (confirm != true) return; // Nếu không xác nhận, thoát luôn
    }

    setState(() => _loading = true);
    bool success;
    if (_isFollowing) {
      success = await FollowService().unfollowUser(
        widget.targetUserId,
        widget.token,
      );
    } else {
      success = await FollowService().followUser(
        widget.targetUserId,
        widget.token,
      );
    }

    if (success) {
      setState(() => _isFollowing = !_isFollowing);
    }
    setState(() => _loading = false);
  }

  @override
  void didUpdateWidget(covariant FollowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFollowingInitial != widget.isFollowingInitial) {
      setState(() {
        _isFollowing = widget.isFollowingInitial;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton.icon(
      onPressed: _loading ? null : _toggleFollow,
      icon: Icon(
        _isFollowing ? Icons.favorite : Icons.favorite_border,
        color: _isFollowing ? Colors.redAccent : theme.colorScheme.primary,
        size: 20,
      ),
      label: Text(
        _isFollowing ? 'Đang theo dõi' : 'Theo dõi',
        style: TextStyle(
          color: _isFollowing ? Colors.redAccent : theme.colorScheme.primary,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size.zero,
      ),
    );
  }
}
