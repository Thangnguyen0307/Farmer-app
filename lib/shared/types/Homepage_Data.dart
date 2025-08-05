import 'package:farmrole/shared/types/Chat_Room_Model.dart';
import 'package:farmrole/shared/types/Video_Model.dart';
import 'package:farmrole/shared/types/Post_Model.dart';
import 'package:farmrole/shared/types/Youtube_Catelogy_Model.dart';

class HomepageData {
  final List<VideoModel> videos;
  final List<PostModel> posts;
  final List<ChatRoom> publicRooms;
  final List<YoutubeCategoryModel> youtubeCategories;

  HomepageData({
    required this.videos,
    required this.posts,
    required this.publicRooms,
    required this.youtubeCategories,
  });

  factory HomepageData.fromJson(Map<String, dynamic> json) {
    return HomepageData(
      videos:
          (json['videos'] as List?)
              ?.map((v) => VideoModel.fromJson(v))
              .toList() ??
          [],
      posts:
          (json['posts'] as List?)
              ?.map((p) => PostModel.fromJson(p))
              .toList() ??
          [],
      publicRooms:
          (json['rooms'] as List?)
              ?.map((r) => ChatRoom.fromPublicJson(r))
              .toList() ??
          [],
      youtubeCategories:
          (json['youtubeCategories'] as List<dynamic>?)
              ?.map((e) => YoutubeCategoryModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
