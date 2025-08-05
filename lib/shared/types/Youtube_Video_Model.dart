class YoutubeVideoModel {
  final String id;
  final String videoId;
  final String title;
  final String description;
  final String thumbnail;
  final DateTime publishedAt;
  final DateTime createdAt;
  final Channel channel;

  YoutubeVideoModel({
    required this.id,
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.publishedAt,
    required this.createdAt,
    required this.channel,
  });

  factory YoutubeVideoModel.fromJson(Map<String, dynamic> json) {
    return YoutubeVideoModel(
      id: json['_id'],
      videoId: json['videoId'],
      title: json['title'],
      description: json['description'],
      thumbnail: json['thumbnail'],
      publishedAt: DateTime.parse(json['publishedAt']),
      createdAt: DateTime.parse(json['createdAt']),
      channel: Channel.fromJson(json['channel']),
    );
  }
}

class Channel {
  final String id;
  final String channelId;
  final String title;
  final String category;

  Channel({
    required this.id,
    required this.channelId,
    required this.title,
    required this.category,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['_id'],
      channelId: json['channelId'],
      title: json['title'],
      category: json['category'] ?? '',
    );
  }
}

class PaginatedYoutubeVideoResponse {
  final List<YoutubeVideoModel> videos;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginatedYoutubeVideoResponse({
    required this.videos,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginatedYoutubeVideoResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedYoutubeVideoResponse(
      videos:
          (json['data'] as List)
              .map((e) => YoutubeVideoModel.fromJson(e))
              .toList(),
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
      totalPages: json['totalPages'],
    );
  }

  bool get hasNextPage => page < totalPages;
}
