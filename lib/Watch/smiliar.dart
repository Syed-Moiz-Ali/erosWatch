// ignore_for_file: must_be_immutable, depend_on_referenced_packages

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eroswatch/Watch/video_tags.dart';

import 'package:eroswatch/components/api/api_service.dart';
import 'package:eroswatch/helper/videos.dart';

import 'package:eroswatch/view/card/similarCard.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class SimilarScreen extends StatefulWidget {
  String id;
  bool isFullScreen;
  SimilarScreen({super.key, required this.id, required this.isFullScreen});

  @override
  State<SimilarScreen> createState() => _SimilarScreenState();
}

class _SimilarScreenState extends State<SimilarScreen> {
  late final APIService apiService = APIService(params: 'similar${widget.id}');
  List<Videos> wallpapers = [];
  List<Videos> favoriteWallpapers = [];
  int pageNumber = 1;
  bool isLoading = false;
  List<String> favorites = [];
  String gifUrl = '';
  String nonLinearClickThroughUrl = '';
  // bool _isPlaying = false;
  int choiceIndex = 0;
  String text = '';
  @override
  void initState() {
    super.initState();

    fetchAndParseVastXml().then((_) => fetchWallpapers());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchWallpapers() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final List<Videos> newWallpapers =
          await apiService.fetchWallpapers(context, pageNumber);
      insertRandomAds(newWallpapers);
      setState(() {
        wallpapers.addAll(newWallpapers);
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

        if (kDebugMode) {
          print('gifUrl; $gifUrl');
        }
        if (kDebugMode) {
          print('nonLinearClickThroughUrl; $nonLinearClickThroughUrl');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching and parsing VAST XML: $e');
      }
    }
  }

  void insertRandomAds(List<Videos> wallpapers) {
    const int numAdsToInsert = 6; // You can adjust this as needed

    for (int i = 0; i < numAdsToInsert; i++) {
      final int randomIndex = Random()
          .nextInt(wallpapers.length + 1); // +1 to allow inserting at the end
      // final bool newBool = Random().nextBool();

      wallpapers.insert(
        randomIndex,
        Videos(
          id: 'id$i',
          image: gifUrl,
          title: 'Ad',
          preview: 'Ad Preview',
          duration: 'Ad Duration',
          quality: 'Ad Quality',
          time: 'Ad Time',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // if (widget.isFullScreen == false)
        Container(
          height: 40,
          decoration: const BoxDecoration(color: Colors.transparent),
          child: VideoTagsContainer(
            id: widget.id,
            choiceIndex: choiceIndex,
            text: text,
          ),
        ),

        SizedBox(
            height: 500, // Set a fixed height for the SimilarScreen
            child:

                // Videos item
                SimilarCard(
              content: wallpapers,
              link: nonLinearClickThroughUrl,
              image: gifUrl,
            ))
      ],
    );
  }
}
