// import 'dart:html';
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:eroswatch/components/smallComponents/image_compoenent.dart';
import 'package:eroswatch/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:eroswatch/view/Stars/star_container_screen.dart';
import 'package:eroswatch/helper/videos.dart';

class StarCard extends StatefulWidget {
  final List<Stars> content;
  final String link;
  final String image;
  const StarCard({
    Key? key,
    required this.content,
    this.image = 'test',
    this.link = '',
  }) : super(key: key);

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<StarCard> {
  final ChromeSafariBrowser browser = ChromeSafariBrowser();
  List<Stars> favorites = [];
  bool changeOnTap = true;
  // final Map<int, bool> _isPlayingMap =
  //     {};
  var database;
  var historyDatabase;
  @override
  void initState() {
    super.initState();

    loadFavorites();
    // _isPlaying = false;
  }

  void handleClickButton(
      BuildContext context, String nonLinearClickThroughUrl) {
    // launchUrl(
    //   Uri.parse(nonLinearClickThroughUrl.trim()),
    // );
    inVideoAddLaunch(context, browser, nonLinearClickThroughUrl);

    // Start a timer to reset showAd to true after 5 minutes
  }

  @override
  Widget build(BuildContext context) {
    final filteredContent = widget.content
        .where((stars) => stars.starName != '' && stars.starName.isNotEmpty)
        .toList();
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        // childAspectRatio: 0.9,
        mainAxisExtent: 340,
      ),
      itemCount: filteredContent.length + 1,
      itemBuilder: (context, index) {
        if (index == filteredContent.length) {
          return const Row();
        }

        final Stars stars = filteredContent[index];
        final newImage = stars.image;
        // print(stars.preview);

        return GestureDetector(
          onTap: () async {
            if (!newImage.contains('spankbang')) {
              handleClickButton(context, widget.link);
            } else {
              await historyDatabase.insertStars(stars);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      StarContainer(passedData: stars.id, name: stars.starName),
                ),
              ).then((result) {
                loadFavorites();
                Future.delayed(const Duration(seconds: 10), () {
                  setState(() {
                    changeOnTap = true;
                  });
                });
              });
            }
          },
          // onHorizontalDragStart: (details) {
          //   setState(() {
          //     _currentPlayingIndex = index;
          //   });
          // },
          // onHorizontalDragEnd: (details) {
          //   setState(() {
          //     _currentPlayingIndex = index;
          //   });
          // },
          // onLongPress: () {
          //   setState(() {
          //     if (_currentPlayingIndex == index) {
          //       _currentPlayingIndex = -1;
          //     } else {
          //       _currentPlayingIndex = index;
          //     }
          //   });
          // },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      // color: Colors.blueAccent,
                      // height: 150,
                      // width: double.infinity,
                      child: ImageComponent(
                          imagePath: newImage.contains('spankbang')
                              ? 'https:$newImage'
                              : newImage,
                          title: "star"),
                    ),
                    if (newImage.contains('spankbang'))
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: GestureDetector(
                          onTap: () {
                            toggleFavorite(stars);
                          },
                          child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50000),
                                color: Colors.black45,
                              ),
                              child: favorites.any((fav) => fav.id == stars.id)
                                  ? const Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                    )
                                  : const Icon(
                                      Icons.favorite,
                                      color: Colors.white,
                                    )),
                        ),
                      )
                  ],
                ),
                Text(
                  stars.starName,
                  style: const TextStyle(color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void toggleFavorite(Stars item) {
    if (favorites.any((fav) => fav.id == item.id)) {
      showRemoveDialog(context, item);
      if (kDebugMode) {
        print("removed from favs");
      }
    } else {
      addToFavorites(item);
      if (kDebugMode) {
        print("added to favs");
      }
    }
  }

  void loadFavorites() async {
    setState(() {
      database = ErosWatchDatabase(storageKey: 'stars', context: context);
      historyDatabase =
          ErosWatchDatabase(storageKey: 'historystars', context: context);
    });
    try {
      final favoritesList = await database.getAllStars();
      setState(() {
        favorites = favoritesList;
      });
    } catch (e) {
      // Handle the error, e.g., show an error message
      if (kDebugMode) {
        print("Error loading favorites: $e");
      }
    }
  }

  Future<void> addToFavorites(Stars item) async {
    try {
      await database.open();
      await database.insertStars(item).then((_) => loadFavorites());
    } catch (e) {
      // Handle the error, e.g., show an error message
      if (kDebugMode) {
        print("Error adding to favorites: $e");
      }
    }
  }

  Future<void> removeFromFavorites(Stars item) async {
    try {
      await database.deleteStar(item).then((_) => loadFavorites());
    } catch (e) {
      // Handle the error, e.g., show an error message
      if (kDebugMode) {
        print("Error removing from favorites: $e");
      }
    }
  }

  void showRemoveDialog(BuildContext context, Stars item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title:
              const Text("Warning..!!", style: TextStyle(color: Colors.blue)),
          content: const Text("Are you sure you want to remove this item?"),
          actions: [
            TextButton(
              onPressed: () {
                // Perform the remove action
                removeFromFavorites(item);
                Navigator.of(context)
                    .pop(true); // Return true to indicate remove
              },
              child: const Text("Remove", style: TextStyle(fontSize: 16.0)),
            ),
            TextButton(
              onPressed: () {
                // Cancel the remove action
                Navigator.of(context)
                    .pop(false); // Return false to indicate cancel
              },
              child: const Text("Cancel", style: TextStyle(fontSize: 16.0)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// class WallpaperStorage {
//   static const String wallpaperKey = 'favoriteStars';

//   static Future<void> storeWallpaper(Stars stars) async {
//     final prefs = await SharedPreferences.getInstance();
//     final wallpaperList = await getWallpapers();

//     wallpaperList.add(stars);

//     await prefs.setStringList(
//       wallpaperKey,
//       wallpaperList
//           .map(
//             (e) => jsonEncode(e),
//           )
//           .toList(),
//     );
//   }

//   static Future<List<Stars>> getWallpapers() async {
//     final prefs = await SharedPreferences.getInstance();
//     final wallpaperList = prefs.getStringList(wallpaperKey) ?? [];

//     return wallpaperList
//         .map(
//           (e) => Stars.fromJson(
//             jsonDecode(e),
//           ),
//         )
//         .toList();
//   }

//   static Future<void> removeWallpaper(String wallpaperId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final wallpaperList = await getWallpapers();

//     wallpaperList.removeWhere((stars) => stars.id == wallpaperId);

//     await prefs.setStringList(
//       wallpaperKey,
//       wallpaperList
//           .map(
//             (e) => jsonEncode(e),
//           )
//           .toList(),
//     );
//   }
// }
