// import 'dart:html';

// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:eroswatch/components/smallComponents/image_compoenent.dart';
import 'package:eroswatch/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:eroswatch/view/Stars/star_container_screen.dart';

import 'package:eroswatch/helper/videos.dart';

class ChannelCard extends StatefulWidget {
  final List<Channels> content;
  final String link;
  final String image;

  const ChannelCard({
    Key? key,
    required this.content,
    this.image = 'test',
    this.link = '',
  }) : super(key: key);

  @override
  _ChannelScreenState createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelCard> {
  List<Channels> favorites = [];

  final ChromeSafariBrowser browser = ChromeSafariBrowser();
  bool changeOnTap = true;
  var database;
  var historyDatabase;
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
        // print(newImage);
        // bool isPlaying = index == _currentPlayingIndex;

        return GestureDetector(
          onTap: () async {
            if (!newImage.contains('spankbang')) {
              handleClickButton(context, widget.link);
            } else {
              await historyDatabase.insertChannels(channel);
              await Navigator.push(
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
                          imagePath: newImage.contains('spankbang')
                              ? 'https:$newImage'
                              : newImage,
                          title: "channel"),
                    ),
                    if (newImage.contains('spankbang'))
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
                              child:
                                  favorites.any((fav) => fav.id == channel.id)
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

  void toggleFavorite(Channels item) {
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
      database = ErosWatchDatabase(storageKey: 'channels', context: context);
      historyDatabase =
          ErosWatchDatabase(storageKey: 'historychannels', context: context);
    });
    try {
      final favoritesList = await database.getAllChannels();
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

  Future<void> addToFavorites(Channels item) async {
    try {
      await database.insertChannels(item).then((_) => loadFavorites());
    } catch (e) {
      // Handle the error, e.g., show an error message
      if (kDebugMode) {
        print("Error adding to favorites: $e");
      }
    }
  }

  Future<void> removeFromFavorites(Channels item) async {
    try {
      await database.deleteChannel(item).then((_) => loadFavorites());
    } catch (e) {
      // Handle the error, e.g., show an error message
      if (kDebugMode) {
        print("Error removing from favorites: $e");
      }
    }
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
