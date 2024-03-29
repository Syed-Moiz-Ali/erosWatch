// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:eroswatch/components/smallComponents/image_compoenent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:eroswatch/helper/videos.dart';
import 'package:eroswatch/util/utils.dart';
import 'package:eroswatch/Watch/video_player/mini_video_player.dart';

import '../detail/detail_screen.dart';

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

  var database;
  @override
  void initState() {
    super.initState();

    loadFavorites();
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
        final newImage = videos.image.trim();
        // print(videos.preview);
        bool isPlaying = index == _currentPlayingIndex;
        return GestureDetector(
          onTap: () {
            if (newImage.contains('gif')) {
              handleClickButton(context, widget.link);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    id: videos.id,
                    title: videos.title,
                  ),
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
                      child: isPlaying && !newImage.contains('gif')
                          ? CustomVideoPlayer(
                              videoUrl: videos.preview,
                              isShown: isPlaying && !newImage.contains('gif')
                                  ? true
                                  : false,
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

  void toggleFavorite(Videos item) {
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
      database = ErosWatchDatabase(storageKey: 'videos', context: context);
    });
    try {
      final favoritesList = await database.getAllVideos();
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

  Future<void> addToFavorites(Videos item) async {
    try {
      await database.insertVideo(item).then((_) => loadFavorites());
      loadFavorites();
    } catch (e) {
      // Handle the error, e.g., show an error message
      if (kDebugMode) {
        print("Error adding to favorites: $e");
      }
    }
  }

  Future<void> removeFromFavorites(Videos item) async {
    try {
      await database.deleteVideo(item).then((_) => loadFavorites());
    } catch (e) {
      // Handle the error, e.g., show an error message
      if (kDebugMode) {
        print("Error removing from favorites: $e");
      }
    }
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
