// import 'dart:html';

// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eroswatch/Stars/star_container_screen.dart';
import 'package:eroswatch/components/api_service.dart';
import 'package:eroswatch/helper/videos.dart';
import 'package:eroswatch/util/utils.dart';

class ChannelCard extends StatefulWidget {
  final List<Channels> content;

  const ChannelCard({Key? key, required this.content}) : super(key: key);

  @override
  _ChannelScreenState createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelCard> {
  List<Channels> favorites = [];
  final ChromeSafariBrowser browser = ChromeSafariBrowser();
  int _currentPlayingIndex = -1;
  bool changeOnTap = true;
  @override
  void initState() {
    super.initState();
    loadFavorites();
    // _isPlaying = false;
  }

  final demoImage =
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTnSsLWVn6ZOrtsgl4lhc4C9DnRGk8ituA04w&usqp=CAU";
  final demoVideo =
      "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4";

  @override
  Widget build(BuildContext context) {
    final filteredContent =
        widget.content.where((videos) => videos.title.isNotEmpty).toList();
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        // childAspectRatio: 0.9,
        mainAxisExtent: 180,
      ),
      itemCount: filteredContent.length + 1,
      itemBuilder: (context, index) {
        if (index == filteredContent.length) {
          return const Row();
        }

        final Channels channel = filteredContent[index];
        final newImage = channel.image;
        // print(videos.preview);
        bool isPlaying = index == _currentPlayingIndex;
        if (kDebugMode) {
          print(isPlaying);
        }
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
                  builder: (context) => StarContainer(
                      passedData: channel.id, name: channel.title),
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
            borderRadius: BorderRadius.circular(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      // color: Colors.blueAccent,
                      // height: 150,
                      // width: double.infinity,
                      child: ImageComponent(
                          imagePath: 'https:$newImage', title: "channel"),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: GestureDetector(
                        onTap: () {
                          toggleFavorite(channel);
                        },
                        child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50000),
                              color: Colors.black45,
                            ),
                            child: favorites.any((fav) => fav.id == channel.id)
                                ? const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 15,
                                  )
                                : const Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 15,
                                  )),
                      ),
                    )
                  ],
                ),
                Text(
                  channel.title,
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
    final jsonStringList = prefs.getStringList('favoriteChannels');
    setState(() {
      if (jsonStringList != null) {
        favorites = jsonStringList
            .map((jsonString) {
              final dynamic jsonData = jsonDecode(jsonString);
              return Channels.fromJson(jsonData);
            })
            .cast<Channels>()
            .toList();
      } else {
        favorites = [];
      }
    });
    await WallpaperStorage.getWallpapers();
  }

  Future<void> addToFavorites(Channels item) async {
    Channels channels = item;
    favorites.add(item);
    await WallpaperStorage.storeWallpaper(channels);
  }

  Future<void> removeFromFavorites(id) async {
    await WallpaperStorage.removeWallpaper(id);
  }

  void showRemoveDialog(BuildContext context, Channels item) {
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

  void toggleFavorite(Channels item) {
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
  static const String wallpaperKey = 'favoriteChannels';

  static Future<void> storeWallpaper(Channels stars) async {
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

  static Future<List<Channels>> getWallpapers() async {
    final prefs = await SharedPreferences.getInstance();
    final wallpaperList = prefs.getStringList(wallpaperKey) ?? [];

    return wallpaperList
        .map(
          (e) => Channels.fromJson(
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
