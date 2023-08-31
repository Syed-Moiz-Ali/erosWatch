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
import '../../../components/api_service.dart';
import '../detail_screen.dart';

class SimilarCard extends StatefulWidget {
  final List<Videos> content;

  const SimilarCard({Key? key, required this.content}) : super(key: key);

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
            // setState(() {
            //   if (_currentPlayingIndex == index) {
            //     _currentPlayingIndex = -1;
            //   } else {
            //     _currentPlayingIndex = index;
            //   }
            // });
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
                    if (favorites.contains(videos))
                      Container(
                        width: double.infinity,
                        height: 150,
                        color: Colors.black54,
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
    setState(() {
      final jsonString = prefs.getString('favorites');
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        favorites = jsonList.map((item) => Videos.fromJson(item)).toList();
      } else {
        favorites = [];
      }
    });
  }

  void addToFavorites(Videos item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites.add(item);
      final List<dynamic> jsonList =
          favorites.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      prefs.setString('favorites', jsonString);
    });
  }

  void removeFromFavorites(item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favorites.remove(item);
      final List<dynamic> jsonList =
          favorites.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      prefs.setString('favorites', jsonString);
    });
  }

  void showRemoveDialog(BuildContext context, String image) {
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
                removeFromFavorites(image);
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

  void toggleFavorite(image) {
    if (favorites.contains(image)) {
      // removeFromFavorites(image);
      showRemoveDialog(context, image);
      if (kDebugMode) {
        print("removed from favs");
      }
    } else {
      addToFavorites(image);
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
