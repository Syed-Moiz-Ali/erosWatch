import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eroswatch/components/api_service.dart';
import 'package:eroswatch/components/dropdown.dart';
import 'package:eroswatch/model/pages/pageconstant.dart';
import 'package:eroswatch/helper/videos.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart';

class PageScreen extends StatefulWidget {
  final String id;
  final String type;
  const PageScreen({super.key, this.id = '', this.type = ''});

  @override
  State<PageScreen> createState() => _MyPageSate();
}

class _MyPageSate extends State<PageScreen> {
  late final APIService apiService = APIService(
    params: widget.id != '' ? "starsVid${widget.id}" : widget.type,
    newParamForStarAndChannel: widget.type,
    id: widget.id,
  );
  List<Videos> wallpapers = [];
  late int pageNumber = 1;
  bool isLoading = false;
  String gifUrl = '';
  String nonLinearClickThroughUrl = '';
  bool showAd = false;
  bool isAdResetting = false;
  List<String> favorites = [];
  late final Key _key = UniqueKey();

  late Future<List<Videos>> futureWallpapers;
  List<Videos> favoriteWallpapers = [];

  void setPageDefaults() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedDate', 'all');
    await prefs.setString('selectedDuration', 'all');
    await prefs.setString('selectedQuality', 'all');
  }

  @override
  void initState() {
    super.initState();
    setPageDefaults();
    futureWallpapers = apiService.fetchWallpapers(pageNumber);
    fetchWallpapers();
    fetchAndParseVastXml();
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        showAd = true;
      });
    }).then((_) => Future.delayed(const Duration(minutes: 5), () {
          setState(() {
            showAd = true;
          });
        }));
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
          gifUrl = gifElement.innerText;
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

  void resetAd() {
    setState(() {
      showAd = true;
      isAdResetting = false; // Reset the flag
    });
  }

  // Function to handle the button click
  void handleClickButton(String nonLinearClickThroughUrl) {
    launchUrl(
      Uri.parse(nonLinearClickThroughUrl.trim()),
    );
    setState(() {
      showAd = false; // Set showAd to false when the button is clicked
    });

    // Start a timer to reset showAd to true after 5 minutes
    if (!isAdResetting) {
      Timer(const Duration(minutes: 20), resetAd);
      isAdResetting = true; // Set the flag to indicate the timer is active
    }
  }

  Future<void> fetchWallpapers() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final List<Videos> newWallpapers =
          await apiService.fetchWallpapers(pageNumber);
      insertRandomAds(newWallpapers); // Insert ad randomly

      setState(() {
        wallpapers.addAll(newWallpapers);
        if (kDebugMode) {
          print(pageNumber);
        }
        pageNumber++;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        print('Failed to load wallpapers: $e');
      } // Print the error message
      if (kDebugMode) {
        print('Failed to load wallpapers: $e');
      }
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      final metrics = notification.metrics;
      final maxScroll = metrics.maxScrollExtent;
      final currentScroll = metrics.pixels;
      if (maxScroll - currentScroll <= 1400) {
        // Reached the end of the current page, fetch next page
        fetchWallpapers();
      }
    }
    return false;
  }

  void fetchDataAndUpdateUI() async {
    setState(() {
      isLoading = true;
    });
    // Fetch new data from the API
    final newWallpapers = await apiService.fetchWallpapers(1);

    // Update the UI with new data
    setState(() {
      wallpapers =
          newWallpapers; // Assuming 'wallpapers' is the List you use to display the content
      isLoading = false;
    });
  }

  void insertRandomAds(List<Videos> wallpapers) {
    const int numAdsToInsert = 4; // You can adjust this as needed

    for (int i = 0; i < numAdsToInsert; i++) {
      final int randomIndex = Random()
          .nextInt(wallpapers.length + 1); // +1 to allow inserting at the end
      // final bool newBool = Random().nextBool();

      wallpapers.insert(
        randomIndex,
        Videos(
          id: 'id$i',
          image:
              'https://alterassumeaggravate.com/vxzhm5ur2?key=67878f8f4b7b02dba995a675709106f1',
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
    // final double screenWidth = MediaQuery.of(context).size.width;
    // double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;
    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: Stack(
        children: [
          PageConstant(
            fetchWallpapers: fetchWallpapers,
            content: wallpapers,
            isLoading: isLoading,
            key: _key,
          ),
          // if (isLoading)
          //   Center(
          //     child: Container(
          //       width: 50,
          //       height: 50,
          //       child: const CircularProgressIndicator(),
          //     ),
          //   ),
          Positioned(
            left: 10,
            bottom: 15,
            child: DropDown(
              fetch: fetchDataAndUpdateUI,
            ),
          ),
          if (showAd)
            GestureDetector(
              onTap: () {
                handleClickButton(nonLinearClickThroughUrl);
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black45,
                child: Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[400],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            gifUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Positioned(
                      //   top: 5,
                      //   right: 5,
                      //   child: Container(
                      //     color: Colors.black54,
                      //     width: 30,
                      //     height: 30,
                      //     child: Align(
                      //       alignment: Alignment.center, // Center the IconButton
                      //       child: IconButton(
                      //         icon: const Icon(
                      //           Icons.close,
                      //           size: 18,
                      //           color: Colors.white,
                      //         ),
                      //         onPressed: () {
                      //           setState(() {
                      //             showAd = false;
                      //           });
                      //         },
                      //       ),
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
