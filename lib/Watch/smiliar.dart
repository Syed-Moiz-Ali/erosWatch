// ignore_for_file: must_be_immutable

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eroswatch/Watch/video_tags.dart';

import 'package:eroswatch/components/api_service.dart';
import 'package:eroswatch/helper/videos.dart';

import 'package:eroswatch/model/pages/card/similarCard.dart';

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
  late Future<List<Videos>> futureWallpapers;
  List<Videos> favoriteWallpapers = [];
  int pageNumber = 1;
  bool isLoading = false;
  List<String> favorites = [];
  // bool _isPlaying = false;
  int choiceIndex = 0;
  String text = '';
  @override
  void initState() {
    super.initState();
    futureWallpapers = apiService.fetchWallpapers(1);
    fetchWallpapers();
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
          await apiService.fetchWallpapers(pageNumber);

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

  // void _onVerticalDragUpdate(DragUpdateDetails details) {
  //   // Check if the user has swiped down by comparing the vertical direction
  //   if (details.primaryDelta! > 6) {
  //     setState(() {
  //       widget.isFullScreen = false;
  //     });
  //   }
  // }

  // bool _onScrollNotification(ScrollNotification notification) {
  //   if (notification is ScrollEndNotification &&
  //       notification.metrics.extentAfter <= 1400) {
  //     fetchWallpapers();
  //   }
  //   return false;
  // }

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
        // if (widget.isFullScreen)
        // ListView.builder(
        //   padding: EdgeInsets.zero, // Set padding to zero

        //   itemCount: wallpapers.length + 1,
        //   itemBuilder: (context, index) {
        //     if (index == wallpapers.length) {
        //       // Loader widget displayed at the end of the horizontal list
        //       if (isLoading) {
        //         return const Center(
        //           child: CircularProgressIndicator(),
        //         );
        //       } else {
        //         return const SizedBox(
        //           width: 16,
        //           child: Text(
        //             'sjafhiohf',
        //             style: TextStyle(
        //               fontSize: 20,
        //             ),
        //           ),
        //         ); // Empty space
        //       }
        //     } else {
        //       // Videos item
        //       return SizedBox(
        //         width: 220,
        //         height: 200,
        //         child: SimilarCard(content: [wallpapers[index]]),
        //       );
        //     }
        //   },
        //   // onNotification: _onScrollNotification,
        // ),
        SizedBox(
            height: 500, // Set a fixed height for the SimilarScreen
            child:

                // Videos item
                SimilarCard(content: wallpapers))
      ],
    );
    //     Align(
    //   alignment:
    //       Alignment.bottomCenter, // Align the SimilarScreen to the bottom
    //   child: SizedBox(
    //     height: 200, // Set a fixed height for the SimilarScreen
    //     // color: Colors.black45, // Set the background color to black
    //     child: ListView.builder(
    //       padding: EdgeInsets.zero,
    //       scrollDirection: Axis.horizontal,
    //       itemCount: wallpapers.length + 1,
    //       itemBuilder: (context, index) {
    //         if (index == wallpapers.length) {
    //           // Loader widget displayed at the end of the horizontal list
    //           if (isLoading) {
    //             return const Center(
    //               child: CircularProgressIndicator(),
    //             );
    //           } else {
    //             return const SizedBox(width: 16); // Empty space
    //           }
    //         } else {
    //           // Videos item
    //           return SizedBox(
    //             width: 220,
    //             child: SimilarCard(content: [wallpapers[index]]),
    //           );
    //         }
    //       },
    //     ),
    //   ),
    // );
    // PageConstant(
    //     fetchWallpapers: fetchWallpapers,
    //     content: wallpapers,
    //     isLoading: isLoading);
  }
}
