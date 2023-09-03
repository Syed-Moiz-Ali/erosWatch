// ignore_for_file: must_be_immutable, depend_on_referenced_packages

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:eroswatch/components/api_service.dart';
import 'package:eroswatch/helper/videos.dart';
import 'package:eroswatch/model/Channels/channels_card.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

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
  String gifUrl = '';
  String nonLinearClickThroughUrl = '';
  late Future<List<Channels>> futureChannels;

  @override
  initState() {
    super.initState();
    apiService = APIChannels(params: "channels", type: widget.param);
    futureChannels = apiService.fetchWallpapers(1);
    fetchAndParseVastXml().then((_) => fetchChannels());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchChannels() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final List<Channels> newChannels =
          await apiService.fetchWallpapers(pageNumber);
      insertRandomAds(newChannels);

      setState(() {
        channels.addAll(newChannels);
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

  Future<void> fetchAndParseVastXml() async {
    try {
      final response = await http
          .get(Uri.parse('https://s.magsrv.com/splash.php?idzone=5067482'));
      if (response.statusCode == 200) {
        final xmlString = response.body;
        final document = XmlDocument.parse(xmlString);

        final gifElement =
            document.findAllElements('StaticResource').firstWhere(
                  (element) =>
                      element.getAttribute('creativeType') == 'image/gif',
                );

        final nonLinearElement =
            document.findAllElements('NonLinearClickThrough').first;
        // nonLinearClickThroughUrl = nonLinearElement
        //     .findAllElements('NonLinearClickThrough')
        //     .first
        //     .innerText;

        setState(() {
          gifUrl = gifElement.innerText.trim();
          nonLinearClickThroughUrl = nonLinearElement.innerText.trim();
        });

        // if (kDebugMode) {
        //   print('gifUrl; $gifUrl');
        // }
        // if (kDebugMode) {
        //   print('nonLinearClickThroughUrl; $nonLinearClickThroughUrl');
        // }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching and parsing VAST XML: $e');
      }
    }
  }

  void insertRandomAds(List<Channels> wallpapers) {
    const int numAdsToInsert = 6; // You can adjust this as needed

    for (int i = 0; i < numAdsToInsert; i++) {
      final int randomIndex = Random()
          .nextInt(wallpapers.length + 1); // +1 to allow inserting at the end
      // final bool newBool = Random().nextBool();

      wallpapers.insert(
        randomIndex,
        Channels(
          id: 'id$i',
          image: gifUrl,
          title: 'Ad',
        ),
      );
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        notification.metrics.extentAfter <= 1400) {
      fetchChannels();
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
              link: nonLinearClickThroughUrl,
              image: gifUrl,
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
