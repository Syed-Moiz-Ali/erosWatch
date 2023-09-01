import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eroswatch/Stars/star_card.dart';
import '../components/api_service.dart';
import '../helper/videos.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class StarsScreen extends StatefulWidget {
  const StarsScreen({super.key});

  @override
  State<StarsScreen> createState() => _StarsScreenState();
}

class _StarsScreenState extends State<StarsScreen> {
  final APIStars apiService = APIStars(params: "stars");
  List<Stars> stars = [];
  bool isLoading = false;
  int pageNumber = 1;
  String gifUrl = '';
  String nonLinearClickThroughUrl = '';
  late Future<List<Stars>> futureStars;
  List<Stars> favoriteWallpapers = [];
  @override
  initState() {
    super.initState();
    futureStars = apiService.fetchWallpapers(1);
    fetchAndParseVastXml().then((_) => fetchStars());
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
      final List<Stars> newStars = await apiService.fetchWallpapers(pageNumber);
      insertRandomAds(newStars);

      setState(() {
        stars.addAll(newStars);
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

        final nonLinearElement = document
            .findAllElements('NonLinear')
            .firstWhere(
              (element) =>
                  element.findAllElements('NonLinearClickThrough').isNotEmpty,
            );
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

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        notification.metrics.extentAfter <= 1400) {
      fetchStars();
    }
    return false;
  }

  void insertRandomAds(List<Stars> wallpapers) {
    const int numAdsToInsert = 8; // You can adjust this as needed

    for (int i = 0; i < numAdsToInsert; i++) {
      final int randomIndex = Random()
          .nextInt(wallpapers.length + 1); // +1 to allow inserting at the end
      // final bool newBool = Random().nextBool();

      wallpapers.insert(
        randomIndex,
        Stars(
          id: 'id$i',
          starName: 'Ad',
          image: gifUrl,
          views: 'Ad',
          videos: 'Ad',
        ),
      );
    }
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
            child: StarCard(
              content: stars,
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
