import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eroswatch/components/api_service.dart';
import 'package:eroswatch/components/dropdown.dart';
import 'package:eroswatch/model/pages/pageconstant.dart';
import 'package:eroswatch/helper/videos.dart';

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
      id: widget.id);
  List<Videos> wallpapers = [];
  late int pageNumber = 1;
  bool isLoading = false;
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
    const int numAdsToInsert = 6; // You can adjust this as needed

    List<String> adLinks = [
      'https://alterassumeaggravate.com/vxzhm5ur2?key=67878f8f4b7b02dba995a675709106f1',
      'https://alterassumeaggravate.com/k7idg1w309?key=4fd88d34214c0b3f55a623c70791caaa',
      // 'https://www.liquidfire.mobi/redirect?sl=16&t=dr&track=193280_291760&siteid=291760'
    ];
    for (int i = 0; i < numAdsToInsert; i++) {
      final int randomIndex = Random()
          .nextInt(wallpapers.length + 1); // +1 to allow inserting at the end
      // final bool newBool = Random().nextBool();
      final String randomAdLink = adLinks[Random().nextInt(adLinks.length)];
      if (kDebugMode) {
        print(randomAdLink);
      }
      wallpapers.insert(
        randomIndex,
        Videos(
          id: 'id$i',
          image: randomAdLink,
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
          )
        ],
      ),
    );
  }
}
