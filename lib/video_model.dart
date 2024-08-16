class YoutubeSearchResponse {
  final String videoId;
  final YoutubeSnippet snippet;

  YoutubeSearchResponse({
    required this.videoId,
    required this.snippet,
  });

  factory YoutubeSearchResponse.fromJson(Map<String, dynamic> json) {
    return YoutubeSearchResponse(
      videoId: "https://www.youtube.com/watch?v="+json['id']['videoId'], // Extract video ID from the response
      snippet: YoutubeSnippet.fromJson(json['snippet']),
    );
  }
}

class YoutubeSnippet {
  final String title;
  final String channelTitle;
  final YoutubeThumbnails thumbnails;

  YoutubeSnippet({
    required this.title,
    required this.channelTitle,
    required this.thumbnails,
  });

  factory YoutubeSnippet.fromJson(Map<String, dynamic> json) {
    return YoutubeSnippet(
      title: json['title'],
      channelTitle: json['channelTitle'],
      thumbnails: YoutubeThumbnails.fromJson(json['thumbnails']),
    );
  }
}

class YoutubeThumbnails {
  final YoutubeThumbnail high;

  YoutubeThumbnails({required this.high});

  factory YoutubeThumbnails.fromJson(Map<String, dynamic> json) {
    return YoutubeThumbnails(
      high: YoutubeThumbnail.fromJson(json['high']),
    );
  }
}

class YoutubeThumbnail {
  final String url;

  YoutubeThumbnail({required this.url});

  factory YoutubeThumbnail.fromJson(Map<String, dynamic> json) {
    return YoutubeThumbnail(
      url: json['url'],
    );
  }
}
