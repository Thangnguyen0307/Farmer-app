// import 'package:farmrole/modules/home/screens/community/Community_Reels_Detail_Screen.dart';
// import 'package:flutter/material.dart';
// import 'package:farmrole/modules/auth/services/Post_Service.dart';
// import 'package:farmrole/shared/types/Video_Model.dart';
// import 'video_item_preview.dart';

// class CommunityVideoTabScreen extends StatefulWidget {
//   const CommunityVideoTabScreen({Key? key}) : super(key: key);

//   @override
//   State<CommunityVideoTabScreen> createState() =>
//       _CommunityVideoTabScreenState();
// }

// class _CommunityVideoTabScreenState extends State<CommunityVideoTabScreen> {
//   List<VideoModel> videos = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadVideos();
//   }

//   Future<void> _loadVideos() async {
//     final res = await PostService().fetchLatestVideos(context: context);
//     if (res != null) {
//       setState(() {
//         videos = res.videos;
//         isLoading = false;
//       });
//     } else {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (videos.isEmpty) {
//       return const Center(child: Text('Chưa có video nào'));
//     }
//     return ListView.builder(
//       itemCount: videos.length,
//       itemBuilder: (ctx, i) {
//         return GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder:
//                     (_) => CommunityReelsDetailScreen(
//                       videos: videos,
//                       initialIndex: i,
//                     ),
//               ),
//             );
//           },
//           child: VideoItemPreview(video: videos[i]),
//         );
//       },
//     );
//   }
// }
