import 'package:farmrole/shared/types/Video_Model.dart';
import 'package:flutter/material.dart';

class VideoProvider with ChangeNotifier {
  List<VideoModel> _videos = [];
  int _initialIndex = 0;

  List<VideoModel> get videos => _videos;
  int get initialIndex => _initialIndex;

  void setVideos(List<VideoModel> v, int index) {
    _videos = v;
    _initialIndex = index;
    notifyListeners();
  }
}
