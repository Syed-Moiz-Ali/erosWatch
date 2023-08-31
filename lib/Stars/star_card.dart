// import 'dart:html';
// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:eroswatch/Stars/star_container_screen.dart';
import 'package:eroswatch/helper/videos.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eroswatch/util/utils.dart';
import '../components/api_service.dart';

class StarCard extends StatefulWidget {
  final List<Stars> content;

  const StarCard({Key? key, required this.content}) : super(key: key);

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<StarCard> {
  final ChromeSafariBrowser browser = ChromeSafariBrowser();
  List<Stars> favorites = [];
  bool changeOnTap = true;
  // final Map<int, bool> _isPlayingMap =
  //     {};

  @override
  void initState() {
    super.initState();
    loadFavorites();
    // _isPlaying = false;
  }

  List<ImageData> imageList = [
    ImageData(
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTnSsLWVn6ZOrtsgl4lhc4C9DnRGk8ituA04w&usqp=CAU',
      title: 'Image 2',
    ),
  ];
  Random random = Random();
  late int randomIndex = random.nextInt(imageList.length);

// Access the randomly selected image and its corresponding URL
  late ImageData randomImage = imageList[randomIndex];
  late String demoimageUrl = randomImage.imageUrl;
  late String demotitle = randomImage.title;
  final demoImage =
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTnSsLWVn6ZOrtsgl4lhc4C9DnRGk8ituA04w&usqp=CAU";
  final demoVideo =
      "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4";

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
          onTap: () {
            if (changeOnTap) {
              launchAdsUrl(context, browser).then(
                (_) => setState(
                  () {
                    changeOnTap = false;
                  },
                ),
              );
            } else {
              Navigator.push(
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
                          imagePath: 'https:$newImage', title: "star"),
                    ),
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

  void loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonStringList = prefs.getStringList('favoriteStars');
    setState(() {
      if (jsonStringList != null) {
        favorites = jsonStringList
            .map((jsonString) {
              final dynamic jsonData = jsonDecode(jsonString);
              return Stars.fromJson(jsonData);
            })
            .cast<Stars>()
            .toList();
      } else {
        favorites = [];
      }
    });
    await WallpaperStorage.getWallpapers();
  }

  Future<void> addToFavorites(Stars item) async {
    Stars stars = item;
    favorites.add(item);
    await WallpaperStorage.storeWallpaper(stars);
  }

  Future<void> removeFromFavorites(id) async {
    await WallpaperStorage.removeWallpaper(id);
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
                removeFromFavorites(item.id).then(
                  (_) => loadFavorites(),
                );
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

  void toggleFavorite(Stars item) {
    if (favorites.any((fav) => fav.id == item.id)) {
      // removeFromFavorites(image);
      showRemoveDialog(context, item);
      if (kDebugMode) {
        print("removed from favs");
      }
    } else {
      addToFavorites(item).then(
        (_) => loadFavorites(),
      );
      if (kDebugMode) {
        print("added to favs");
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class WallpaperStorage {
  static const String wallpaperKey = 'favoriteStars';

  static Future<void> storeWallpaper(Stars stars) async {
    final prefs = await SharedPreferences.getInstance();
    final wallpaperList = await getWallpapers();

    wallpaperList.add(stars);

    await prefs.setStringList(
      wallpaperKey,
      wallpaperList
          .map(
            (e) => jsonEncode(e),
          )
          .toList(),
    );
  }

  static Future<List<Stars>> getWallpapers() async {
    final prefs = await SharedPreferences.getInstance();
    final wallpaperList = prefs.getStringList(wallpaperKey) ?? [];

    return wallpaperList
        .map(
          (e) => Stars.fromJson(
            jsonDecode(e),
          ),
        )
        .toList();
  }

  static Future<void> removeWallpaper(String wallpaperId) async {
    final prefs = await SharedPreferences.getInstance();
    final wallpaperList = await getWallpapers();

    wallpaperList.removeWhere((stars) => stars.id == wallpaperId);

    await prefs.setStringList(
      wallpaperKey,
      wallpaperList
          .map(
            (e) => jsonEncode(e),
          )
          .toList(),
    );
  }
}
