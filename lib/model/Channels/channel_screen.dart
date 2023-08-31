// ignore_for_file: must_be_immutable

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:eroswatch/components/api_service.dart';
import 'package:eroswatch/helper/videos.dart';
import 'package:eroswatch/model/Channels/channels_card.dart';

class ChannelScreen extends StatefulWidget {
  String param;
  ChannelScreen({super.key, required this.param});

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  late APIChannels apiService;
  List<Channels> channels = [];
  bool isLoading = false;
  int pageNumber = 1;
  late Future<List<Channels>> futureStars;
  List<Channels> favoriteWallpapers = [];
  @override
  void initState() {
    super.initState();
    apiService = APIChannels(params: "channels", type: widget.param);
    futureStars = apiService.fetchWallpapers(1);
    fetchStars();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchStars() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final List<Channels> newStars =
          await apiService.fetchWallpapers(pageNumber);

      setState(() {
        channels.addAll(newStars);
        pageNumber++;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        print('Failed to load wallpapers: $e');
      }
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        notification.metrics.extentAfter <= 1400) {
      fetchStars();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Latest Wallpapers")),
      body: Stack(
        children: [
          const SizedBox(
              // height: 300,
              // width: double.infinity,
              ),
          NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: ChannelCard(
              content: channels,
            ),
          ),
          if (isLoading)
            // Loader widget displayed in the center of the screen
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
