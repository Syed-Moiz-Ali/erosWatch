// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:eroswatch/components/api_service.dart';
import 'package:eroswatch/helper/videos.dart';
import 'package:eroswatch/video_player/main_video_player.dart';

class DetailScreen extends StatefulWidget {
  final String id;

  const DetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late APIServiceDetailPage apiService;
  late APIServiveForVideoTags tagapiService;
  List<Episode> episodes = [];

  bool isLoading = false;
  late bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _isFullScreen = false;
    apiService = APIServiceDetailPage(params: widget.id);
    tagapiService = APIServiveForVideoTags(params: widget.id);
    fetchEpisodes();
  }

  Future<List<Episode>> fetchEpisodes() async {
    if (isLoading) return episodes;

    setState(() {
      isLoading = true;
    });

    try {
      final List<Episode> response = await apiService.fetchWallpapers();
      if (kDebugMode) {
        print(response);
      }

      setState(() {
        episodes.addAll(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (kDebugMode) {
        print('Failed to load video: $e');
      }
    }

    return episodes; // Return the episodes list after processing
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(_isFullScreen);
    }
    // const demoVideo =
    //     "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4";
    return Scaffold(
      body: ListView.builder(
        itemCount: episodes.length,
        itemBuilder: (context, index) {
          if (index == episodes.length) {
            return const SizedBox.shrink();
          }
          final Episode episode = episodes[index];
          final title = episode.name;
          final videoUrl = episode.contentUrl;
          return VideoPlayerScreen(
            videoUrl: videoUrl,
            id: widget.id,
            title: title,
            // isFullScreen: _isFullScreen,
            // image: image,
          );
        },
      ),
    );
  }
}
