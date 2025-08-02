// import 'package:farmrole/modules/auth/services/Auth_Service.dart';
// import 'package:farmrole/modules/home/screens/community/Search_Video_Screen.dart';
// import 'package:farmrole/modules/home/widgets/Post/Chat_Private_Video_Button.dart';
// import 'package:farmrole/modules/home/widgets/Post/Video_Comment.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// import 'package:farmrole/modules/auth/services/Post_Service.dart';
// import 'package:farmrole/shared/types/Video_Model.dart';

// class ViewVideoHome extends StatefulWidget {
//   final String? uploadedById;
//   const ViewVideoHome({super.key, this.uploadedById});

//   @override
//   State<ViewVideoHome> createState() => _ViewVideoHomeState();
// }

// class _ViewVideoHomeState extends State<ViewVideoHome> {
//   List<VideoModel> videos = [];
//   bool isLoading = true;
//   final Map<int, dynamic> _controllers = {};
//   int currentIndex = 0;
//   int page = 1;
//   bool isLoadingMore = false;
//   bool hasMore = true;
//   final int limit = 10;
//   Map<int, bool> _isExpandedTitle = {};

//   @override
//   void initState() {
//     super.initState();
//     loadVideos();
//   }

//   Future<void> loadVideos({bool loadMore = false}) async {
//     if (isLoadingMore || (!hasMore && loadMore)) return;

//     if (!loadMore) {
//       setState(() => isLoading = true);
//       page = 1;
//       videos.clear();
//       _controllers.clear();
//     } else {
//       setState(() => isLoadingMore = true);
//     }

//     final res = await PostService().fetchLatestVideos(
//       context: context,
//       page: page,
//       limit: limit,
//     );

//     if (res != null && res.videos.isNotEmpty) {
//       List<VideoModel> newVideos = res.videos;

//       if (!loadMore && widget.uploadedById != null) {
//         final prioritized = newVideos.firstWhere(
//           (e) => e.uploadedById == widget.uploadedById,
//           orElse: () => newVideos.first,
//         );
//         newVideos.removeWhere((e) => e.id == prioritized.id);
//         newVideos.insert(0, prioritized);
//       }

//       setState(() {
//         videos.addAll(newVideos);
//         page++;
//         hasMore = res.videos.length >= limit;
//       });
//     } else {
//       setState(() => hasMore = false);
//     }

//     if (loadMore) {
//       setState(() => isLoadingMore = false);
//     } else {
//       setState(() => isLoading = false);
//       if (videos.isNotEmpty) {
//         _initializeController(0);
//         _playOnly(0);
//       }
//     }
//   }

//   bool _isYoutube(String url) =>
//       url.contains('youtube.com') || url.contains('youtu.be');

//   void _initializeController(int index) {
//     if (_controllers.containsKey(index)) return;
//     final url = videos[index].youtubeLink;

//     if (_isYoutube(url)) {
//       final videoId = YoutubePlayer.convertUrlToId(url);
//       if (videoId != null) {
//         _controllers[index] = YoutubePlayerController(
//           initialVideoId: videoId,
//           flags: const YoutubePlayerFlags(autoPlay: true),
//         );
//       }
//     } else {
//       final controller = VideoPlayerController.networkUrl(Uri.parse(url));
//       controller.initialize().then((_) {
//         if (mounted) setState(() {});
//       });
//       _controllers[index] = controller;
//     }
//   }

//   void _playOnly(int index) {
//     _controllers.forEach((i, ctrl) {
//       if (i == index) {
//         if (ctrl is YoutubePlayerController) ctrl.play();
//         if (ctrl is VideoPlayerController) ctrl.play();
//       } else {
//         if (ctrl is YoutubePlayerController) ctrl.pause();
//         if (ctrl is VideoPlayerController) ctrl.pause();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     for (final ctrl in _controllers.values) {
//       ctrl.pause();
//       ctrl.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     if (isLoading) return const Center(child: CircularProgressIndicator());
//     if (videos.isEmpty) return const Center(child: Text('Chưa có video nào'));

//     return PageView.builder(
//       scrollDirection: Axis.vertical,
//       itemCount: hasMore ? videos.length + 1 : videos.length,
//       onPageChanged: (index) {
//         setState(() {
//           currentIndex = index;
//           _initializeController(index);
//           _playOnly(index);
//         });
//         if (index >= videos.length - 2 && hasMore && !isLoadingMore) {
//           loadVideos(loadMore: true);
//         }
//       },
//       itemBuilder: (_, index) {
//         if (index >= videos.length) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         return Container(
//           width: double.infinity,
//           height: screenHeight,
//           color: Colors.black,
//           child: _buildVideo(index),
//         );
//       },
//     );
//   }

//   Widget _buildVideo(int index) {
//     _initializeController(index);
//     final controller = _controllers[index];
//     final video = videos[index];
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Stack(
//       children: [
//         Positioned.fill(
//           child:
//               controller == null
//                   ? const Center(child: CircularProgressIndicator())
//                   : controller is YoutubePlayerController
//                   ? YoutubePlayer(controller: controller)
//                   : controller.value.isInitialized
//                   ? FittedBox(
//                     fit: BoxFit.cover,
//                     child: SizedBox(
//                       width: controller.value.size.width,
//                       height: controller.value.size.height,
//                       child: VideoPlayer(controller),
//                     ),
//                   )
//                   : const Center(child: CircularProgressIndicator()),
//         ),

//         Positioned(
//           top: 40,
//           right: 16,
//           child: IconButton(
//             icon: const Icon(Icons.search, color: Colors.white, size: 28),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const SearchVideoScreen()),
//               );
//             },
//           ),
//         ),

//         Positioned(
//           bottom: 120,
//           right: 16,
//           child: Column(
//             children: [
//               IconButton(
//                 onPressed: () async {
//                   final success =
//                       video.yourLike
//                           ? await PostService().unlikeVideo(
//                             context: context,
//                             videoId: video.id,
//                           )
//                           : await PostService().likeVideo(
//                             context: context,
//                             videoId: video.id,
//                           );
//                   if (success) {
//                     setState(() {
//                       video.yourLike = !video.yourLike;
//                       video.likeCount += video.yourLike ? 1 : -1;
//                     });
//                   }
//                 },
//                 icon: Icon(
//                   video.yourLike ? Icons.favorite : Icons.favorite_border,
//                   color: video.yourLike ? Colors.red : Colors.white,
//                   size: 32,
//                 ),
//               ),
//               Text(
//                 '${video.likeCount}',
//                 style: const TextStyle(color: Colors.white),
//               ),
//               const SizedBox(height: 24),
//               IconButton(
//                 onPressed: () {
//                   showModalBottomSheet(
//                     context: context,
//                     isScrollControlled: true,
//                     backgroundColor: Colors.transparent,
//                     barrierColor: Colors.black38,
//                     builder: (_) {
//                       return VideoCommentScreen(videoId: video.id);
//                     },
//                   );
//                 },
//                 icon: const Icon(Icons.comment, color: Colors.white, size: 30),
//               ),
//               Text(
//                 '${video.commentCount}',
//                 style: const TextStyle(color: Colors.white),
//               ),
//               const SizedBox(height: 24),
//               ChatPrivateVideoButton(
//                 targetUserId: video.uploadedById,
//                 targetFullName: video.uploadedBy,
//               ),
//             ],
//           ),
//         ),

//         Positioned(
//           bottom: 80,
//           left: 16,
//           child: Row(
//             children: [
//               CircleAvatar(
//                 radius: 16,
//                 backgroundImage: NetworkImage(
//                   AuthService.getFullAvatarUrl(video.avatar),
//                 ),
//                 backgroundColor: Colors.grey.shade300,
//               ),
//               const SizedBox(width: 8),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     video.uploadedBy,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                       shadows: [Shadow(blurRadius: 4, color: Colors.black)],
//                     ),
//                   ),
//                   Text(
//                     video.farmName,
//                     style: const TextStyle(
//                       color: Colors.white70,
//                       fontSize: 12,
//                       shadows: [Shadow(blurRadius: 4, color: Colors.black)],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),

//         Positioned(bottom: 30, left: 16, right: 100, child: _buildTitle(index)),
//       ],
//     );
//   }

//   Widget _buildTitle(int index) {
//     final video = videos[index];
//     final isExpanded = _isExpandedTitle[index] ?? false;
//     final text =
//         isExpanded
//             ? video.title
//             : (video.title.length > 50
//                 ? '${video.title.substring(0, 50)}...'
//                 : video.title);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           text,
//           maxLines: isExpanded ? null : 2,
//           overflow: TextOverflow.ellipsis,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             shadows: [Shadow(color: Colors.black, blurRadius: 8)],
//           ),
//         ),
//         if (video.title.length > 50)
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 _isExpandedTitle[index] = !isExpanded;
//               });
//             },
//             child: Padding(
//               padding: const EdgeInsets.only(top: 4),
//               child: Text(
//                 isExpanded ? 'Thu gọn' : 'Xem thêm',
//                 style: TextStyle(
//                   color: Theme.of(context).colorScheme.primary,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
