import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:youtube_short_video/video_model.dart';
import 'package:youtube_short_video/video_plye.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(YoutubeApp());
}

class YoutubeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Video List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: YoutubeVideoList(),
    );
  }
}

class YoutubeVideoList extends StatefulWidget {
  @override
  _YoutubeVideoListState createState() => _YoutubeVideoListState();
}

class _YoutubeVideoListState extends State<YoutubeVideoList> {
  static const _pageSize = 10;
  final PagingController<int, YoutubeSearchResponse> _pagingController =
      PagingController(firstPageKey: 1);
  String nextPageToken = '';

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await fetchVideos(nextPageToken);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        _pagingController.appendPage(newItems, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<List<YoutubeSearchResponse>> fetchVideos(String pageToken) async {
    final searchTerm = 'technology'; // Example fixed or dynamic search term
    final API = dotenv.env['API']; // add your youtube data v3 api key here
    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=$_pageSize&q=$searchTerm&type=video&videoDuration=short&key=$API&pageToken=$pageToken',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      log(data.toString());
      final items = data['items'] as List<dynamic>;
      nextPageToken = data['nextPageToken'] ?? '';
      return items.map((json) => YoutubeSearchResponse.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load videos');
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Videos'),
      ),
      body: PagedListView<int, YoutubeSearchResponse>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<YoutubeSearchResponse>(
          itemBuilder: (context, item, index) => VideoItemWidget(item: item),
        ),
      ),
    );
  }
}

// This widget will handle the video UI display
class VideoItemWidget extends StatelessWidget {
  final YoutubeSearchResponse item;

  const VideoItemWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerPage(
              videoId: item.videoId,
              videoTitle: item.snippet.title,
            ),
          ),
        );
      },
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: item.videoId,
              child: Image.network(
                item.snippet.thumbnails.high.url,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                height: 200,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.snippet.title,
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(item.snippet.channelTitle),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
