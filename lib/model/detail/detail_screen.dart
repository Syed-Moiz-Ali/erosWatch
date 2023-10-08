// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:eroswatch/components/api/api_service.dart';
import 'package:eroswatch/helper/videos.dart';
import 'package:eroswatch/Watch/video_player/main_video_player.dart';

class DetailScreen extends StatefulWidget {
  final String id;
  final String title;

  const DetailScreen({Key? key, required this.id, required this.title})
      : super(key: key);

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
        print('episode fetched sucessfully');
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

  String getStreamLink(Map<String, dynamic> streamUrls, String resolution) {
    final List<dynamic> urls = streamUrls[resolution] ?? [];

    if (urls.isEmpty) {
      // If the requested resolution is empty, try an alternative resolution
      final List<dynamic> alternativeUrls =
          streamUrls['m3u8_$resolution'] ?? [];
      if (alternativeUrls.isNotEmpty) {
        return alternativeUrls.join(',');
      }
    } else {}
    return urls.join(',');
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
        final episodeData = episodes[index];
        final streamUrls = episodeData.streamUrls;

        // Access other fields from episodeData
        // final String keywords = streamUrls['keywords'];
        final String thumbnail = streamUrls['thumbnail'];
        final String keywords = episodeData.keywords;

        final String link240p = getStreamLink(streamUrls, '240p');
        final String link360p = getStreamLink(streamUrls, '360p');
        final String link480p = getStreamLink(streamUrls, '480p');
        final String link720p = getStreamLink(streamUrls, '720p');
        final String link1080p = getStreamLink(streamUrls, '1080p');
        final String fourk = getStreamLink(streamUrls, '4k');
        final String main = getStreamLink(streamUrls, 'main');
        final String m3u8 = getStreamLink(streamUrls, 'm3u8');

        final videoUrls = VideoUrls(
          thumbnail: thumbnail,
          keywords: keywords,
          link240p: link240p,
          link360p: link360p,
          link480p: link480p,
          link720p: link720p,
          link1080p: link1080p,
          fourk: fourk,
          main: main,
          m3u8: m3u8,
        );
        return VideoPlayerScreen(
          videoUrls: videoUrls,
          id: widget.id,
          title: widget.title,
        );
      },
    ));
  }
}

          // VideoPlayerScreen(
          //   videoUrl: url,
          //   id: widget.id,
          //   title: title,
          //   // isFullScreen: _isFullScreen,
          //   // image: image,
          // );