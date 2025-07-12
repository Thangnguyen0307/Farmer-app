// import 'package:flutter/material.dart';
// import 'package:farmrole/modules/auth/services/Auth_Service.dart';
// import 'package:farmrole/modules/home/widgets/Post/Video_Comment.dart';
// import 'package:video_player/video_player.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// import 'package:farmrole/modules/auth/services/Post_Service.dart';
// import 'package:farmrole/shared/types/Video_Model.dart';

// class CommunityReelsDetailScreen extends StatefulWidget {
//   final List<VideoModel> videos;
//   final int initialIndex;
//   const CommunityReelsDetailScreen({
//     Key? key,
//     required this.videos,
//     required this.initialIndex,
//   }) : super(key: key);

//   @override
//   State<CommunityReelsDetailScreen> createState() =>
//       _CommunityReelsDetailScreenState();
// }

// class _CommunityReelsDetailScreenState
//     extends State<CommunityReelsDetailScreen> {
//   late PageController _pageCtrl;
//   final Map<int, dynamic> _controllers = {};
//   int currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _pageCtrl = PageController(initialPage: widget.initialIndex);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // Gọi sau frame đầu tiên để tránh build khi controller chưa sẵn sàng
//       setState(() {
//         currentIndex = widget.initialIndex;
//       });
//       _initializeController(currentIndex);
//       _playOnly(currentIndex);
//     });
//   }

//   bool _isYoutube(String url) =>
//       url.contains('youtube.com') || url.contains('youtu.be');

//   void _initializeController(int idx) {
//     if (_controllers.containsKey(idx)) return;
//     final video = widget.videos[idx];
//     final url = video.youtubeLink;

//     if (_isYoutube(url)) {
//       final vid = YoutubePlayer.convertUrlToId(url)!;
//       _controllers[idx] = YoutubePlayerController(
//         initialVideoId: vid,
//         flags: const YoutubePlayerFlags(autoPlay: false),
//       );
//     } else {
//       final ctrl =
//           VideoPlayerController.network(url)
//             ..initialize().then((_) {
//               if (mounted) setState(() {});
//             })
//             ..setLooping(true);
//       _controllers[idx] = ctrl;
//     }
//   }

//   void _playOnly(int idx) {
//     _controllers.forEach((i, ctrl) {
//       if (i == idx) {
//         if (ctrl is YoutubePlayerController) ctrl.play();
//         if (ctrl is VideoPlayerController && ctrl.value.isInitialized)
//           ctrl.play();
//       } else {
//         if (ctrl is YoutubePlayerController) ctrl.pause();
//         if (ctrl is VideoPlayerController) ctrl.pause();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     for (final ctrl in _controllers.values) {
//       if (ctrl is YoutubePlayerController)
//         ctrl
//           ..pause()
//           ..dispose();
//       if (ctrl is VideoPlayerController)
//         ctrl
//           ..pause()
//           ..dispose();
//     }
//     _pageCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PageView.builder(
//       controller: _pageCtrl,
//       scrollDirection: Axis.vertical,
//       itemCount: widget.videos.length,
//       onPageChanged: (idx) {
//         setState(() => currentIndex = idx);
//         _initializeController(idx);
//         _playOnly(idx);
//       },
//       itemBuilder: (_, idx) {
//         final video = widget.videos[idx];
//         final ctrl = _controllers[idx];

//         return Stack(
//           children: [
//             // video hoặc loader
//             Positioned.fill(
//               child:
//                   (ctrl == null)
//                       ? const Center(child: CircularProgressIndicator())
//                       : ctrl is YoutubePlayerController
//                       ? YoutubePlayer(controller: ctrl)
//                       : ctrl is VideoPlayerController &&
//                           ctrl.value.isInitialized
//                       ? GestureDetector(
//                         onTap: () {
//                           if (ctrl.value.isPlaying)
//                             ctrl.pause();
//                           else
//                             ctrl.play();
//                           setState(() {});
//                         },
//                         child: Center(
//                           child: AspectRatio(
//                             aspectRatio: ctrl.value.aspectRatio,
//                             child: VideoPlayer(ctrl),
//                           ),
//                         ),
//                       )
//                       : const Center(child: CircularProgressIndicator()),
//             ),

//             Positioned(
//               bottom: 100,
//               left: 16,
//               right: 80,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Avatar + uploader + farm
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 16,
//                         backgroundImage: NetworkImage(
//                           AuthService.getFullAvatarUrl(video.avatar),
//                         ),
//                         backgroundColor: Colors.grey.shade200,
//                       ),
//                       const SizedBox(width: 8),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             video.uploadedBy,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                             ),
//                           ),
//                           const SizedBox(height: 2),
//                           Text(
//                             video.farmName,
//                             style: const TextStyle(
//                               color: Colors.white70,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   // Title với maxLines + overflow
//                   Text(
//                     video.title,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Like / Comment / Chat (bên phải, đáy 60)
//             Positioned(
//               right: 12,
//               bottom: 60,
//               child: Column(
//                 children: [
//                   IconButton(
//                     icon: Icon(
//                       video.yourLike ? Icons.favorite : Icons.favorite_border,
//                       size: 32,
//                       color: video.yourLike ? Colors.red : Colors.white,
//                     ),
//                     onPressed: () async {
//                       final success =
//                           video.yourLike
//                               ? await PostService().unlikeVideo(
//                                 context: context,
//                                 videoId: video.id,
//                               )
//                               : await PostService().likeVideo(
//                                 context: context,
//                                 videoId: video.id,
//                               );
//                       if (success) {
//                         setState(() {
//                           widget.videos[idx] = video.copyWith(
//                             yourLike: !video.yourLike,
//                             likeCount:
//                                 video.yourLike
//                                     ? video.likeCount - 1
//                                     : video.likeCount + 1,
//                           );
//                         });
//                       }
//                     },
//                   ),
//                   Text(
//                     '${video.likeCount}',
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                   const SizedBox(height: 16),
//                   IconButton(
//                     icon: const Icon(
//                       Icons.comment,
//                       size: 30,
//                       color: Colors.white,
//                     ),
//                     onPressed: () {
//                       showModalBottomSheet(
//                         context: context,
//                         isScrollControlled: true,
//                         backgroundColor: Colors.transparent,
//                         barrierColor: Colors.black38,
//                         shape: const RoundedRectangleBorder(
//                           borderRadius: BorderRadius.vertical(
//                             top: Radius.circular(16),
//                           ),
//                         ),
//                         builder: (_) => VideoCommentScreen(videoId: video.id),
//                       );
//                     },
//                   ),
//                   Text(
//                     '${video.commentCount}',
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                   const SizedBox(height: 16),
//                   IconButton(
//                     icon: const Icon(Icons.send, size: 28, color: Colors.white),
//                     onPressed: () {
//                       // TODO: chat logic
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
