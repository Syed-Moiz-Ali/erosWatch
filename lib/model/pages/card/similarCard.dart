// ignore_for_file: file_names, library_private_types_in_public_api

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:eroswatch/helper/videos.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eroswatch/util/utils.dart';
import 'package:eroswatch/video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../components/api_service.dart';
import '../detail_screen.dart';

class SimilarCard extends StatefulWidget {
  final List<Videos> content;
  final String link;
  final String image;

  const SimilarCard({
    Key? key,
    required this.content,
    this.image = 'test',
    this.link = '',
  }) : super(key: key);

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<SimilarCard> {
  List<Videos> favorites = [];
  final ChromeSafariBrowser browser = ChromeSafariBrowser();
  // final Map<int, bool> _isPlayingMap =
  //     {};
  int _currentPlayingIndex = -1;
  bool changeOnTap = false;
  @override
  void initState() {
    super.initState();

    WallpaperStorage.getWallpapers().then((value) => loadFavorites());
  }

  text(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      // decoration: BoxDecoration(
      //   color: Colors.black45,
      //   borderRadius: BorderRadius.circular(3),
      // ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: Colors.black),
      ),
    );
  }

  void handleClickButton(String nonLinearClickThroughUrl) {
    launchUrl(
      Uri.parse(nonLinearClickThroughUrl.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredContent = widget.content
        .where((videos) => videos.title != '' && videos.title.isNotEmpty)
        .toList();
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4, // Set mainAxisSpacing to 0
        crossAxisSpacing: 4, // Set crossAxisSpacing to 0
        // childAspectRatio: 0.9,
        mainAxisExtent: 210,
      ),
      itemCount: filteredContent.length + 1,
      itemBuilder: (context, index) {
        if (index == filteredContent.length) {
          return const Row();
        }

        final Videos videos = filteredContent[index];
        final newImage = videos.image;
        // print(videos.preview);
        bool isPlaying = index == _currentPlayingIndex;
        return GestureDetector(
          onTap: () {
            if (!newImage.contains('spankbang')) {
              handleClickButton(widget.link);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(id: videos.id),
                ),
              ).then((_) {
                loadFavorites();
                Future.delayed(const Duration(seconds: 10), () {
                  setState(() {
                    changeOnTap = true;
                  });
                });
              });
            }
          },
          onHorizontalDragStart: (details) {
            setState(() {
              _currentPlayingIndex = index;
            });
          },
          onHorizontalDragEnd: (details) {
            setState(() {
              _currentPlayingIndex = index;
            });
          },
          onLongPress: () {
            toggleFavorite(videos);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      // color: Colors.blueAccent,
                      height: 150,
                      width: 210,
                      child: isPlaying
                          ? CustomVideoPlayer(
                              videoUrl: videos.preview,
                            )
                          : ImageComponent(
                              imagePath: newImage, title: videos.title),
                    ),
                    if (favorites.any((fav) => fav.id == videos.id))
                      Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: const Text(
                          "Library",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16.0,
                            wordSpacing: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      const SizedBox(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    text(videos.duration),
                    text(videos.time),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                  child: Text(
                    videos.title,
                    style: const TextStyle(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
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
    final jsonStringList = prefs.getStringList('favorites');
    setState(() {
      if (jsonStringList != null) {
        favorites = jsonStringList.map((jsonString) {
          final dynamic jsonData = jsonDecode(jsonString);
          return Videos.fromJson(jsonData);
        }).toList();
      } else {
        favorites = [];
      }
    });
    await WallpaperStorage.getWallpapers();
  }

  Future<void> addToFavorites(Videos item) async {
    Videos videos = item;
    favorites.add(item);
    await WallpaperStorage.storeWallpaper(videos);
  }

  Future<void> removeFromFavorites(id) async {
    await WallpaperStorage.removeWallpaper(id);
  }

  void showRemoveDialog(BuildContext context, Videos item) {
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

  void toggleFavorite(Videos item) {
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

class MyObject {
  final String name;
  final int age;

  MyObject(this.name, this.age);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
    };
  }

  factory MyObject.fromJson(Map<String, dynamic> json) {
    return MyObject(
      json['name'],
      json['age'],
    );
  }
}

class WallpaperStorage {
  static const String wallpaperKey = 'favorites';

  static Future<void> storeWallpaper(Videos videos) async {
    final prefs = await SharedPreferences.getInstance();
    final wallpaperList = await getWallpapers();

    wallpaperList.add(videos);

    await prefs.setStringList(
        wallpaperKey, wallpaperList.map((e) => jsonEncode(e)).toList());
  }

  static Future<List<Videos>> getWallpapers() async {
    final prefs = await SharedPreferences.getInstance();
    final wallpaperList = prefs.getStringList(wallpaperKey) ?? [];

    return wallpaperList.map((e) => Videos.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> removeWallpaper(String wallpaperId) async {
    final prefs = await SharedPreferences.getInstance();
    final wallpaperList = await getWallpapers();

    wallpaperList.removeWhere((videos) => videos.id == wallpaperId);

    await prefs.setStringList(
        wallpaperKey, wallpaperList.map((e) => jsonEncode(e)).toList());
  }
}
