// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:eroswatch/models/spankbang.dart';
import 'package:eroswatch/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eroswatch/view/Stars/star_card.dart';
import 'package:eroswatch/helper/videos.dart';
import 'package:eroswatch/view/Channels/channels_card.dart';
import 'package:eroswatch/view/card/card_screen.dart';

class FavCard extends StatefulWidget {
  Future<List<Videos>>? getVideosWallpapers;
  Future<List<Stars>>? getStarsWallpapers;
  Future<List<Channels>>? getChannelsWallpapers;
  String type;

  FavCard({
    super.key,
    this.getVideosWallpapers,
    this.getStarsWallpapers,
    this.getChannelsWallpapers,
    required this.type,
  });

  @override
  State<FavCard> createState() => _FavCardState();
}

class _FavCardState extends State<FavCard> {
  FilterOption _currentFilter = FilterOption.newest; // Initial filter
  List<VideoItem> favoriteVideos = [];
  List<Stars> favoriteStars = [];
  List<Channels> favoriteChannels = [];
  bool _showLoadingIndicator = true;
  var database;
  @override
  void initState() {
    super.initState();

    _loadData();
    // _startTimer();
    // Timer.periodic(const Duration(seconds: 1), (timer) {
    //   _loadData();
    // });
  }

  // Future loadFavorites() async {
  //   final favVideo = await widget.getVideosWallpapers;
  //   final favStar = await widget.getStarsWallpapers;
  //   final favChannel = await widget.getChannelsWallpapers;

  //   setState(() {
  //     if (widget.type == 'stars') {
  //       favStars = favStar;
  //     } else if (widget.type == 'channels') {
  //       favChannels = favChannel;
  //     } else {
  //       favVideos = favVideo;
  //     }
  //   });

  //   return widget.type == 'stars'
  //       ? favStar
  //       : widget.type == 'channels'
  //           ? favChannel
  //           : favVideo;
  // }

  // void _startTimer() async {
  //   // Wait for 3 seconds and then update the loading indicator visibility
  //   await Timer(const Duration(seconds: 3), () {
  //     setState(() {
  //       _showLoadingIndicator = false; // Hide loading indicator
  //     });
  //   });
  // }

  Future<void> _loadData() async {
    setState(() {
      database = ErosWatchDatabase(storageKey: widget.type, context: context);
    });
    try {
      List<VideoItem> videoData;
      List<Stars> starData;
      List<Channels> channelData;

      starData = await database.getAllStars();
      channelData = await database.getAllChannels();
      videoData = await database.getAllVideos();
      setState(() {
        favoriteStars = starData;
        favoriteChannels = channelData;
        favoriteVideos = videoData;
        _showLoadingIndicator = false;
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error loading data: $error');
      }
      setState(() {
        _showLoadingIndicator = false;
      });
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _showLoadingIndicator == true
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : FutureBuilder(
            future: _loadData(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                // Show an error message if the future encounters an error
                return Center(
                  child: Text('Error loading data: ${snapshot.error}'),
                );
              } else {
                // Show the content once the future is complete
                return Container(
                  color: Colors.white,
                  child: _buildContent(),
                );
              }
            },
          );
  }

  Widget _buildContent() {
    if (widget.type == 'stars' || widget.type == 'historystars') {
      if (favoriteStars.isEmpty) {
        return NotFoundWdget(
          type: widget.type,
        );
      } else {
        return Stack(
          children: [
            StarCard(
              content: _applyStarsFilter(favoriteStars),
            ),
            Positioned(
              bottom: 80.0,
              left: 25.0,
              child: FloatingActionButton(
                heroTag: UniqueKey(),
                onPressed: _showFilterOptions,
                child: const Icon(Icons.filter_list),
              ),
            ),
          ],
        );
      }
    } else if (widget.type == 'channels' || widget.type == 'historychannels') {
      if (favoriteChannels.isEmpty) {
        return NotFoundWdget(
          type: widget.type,
        );
      } else {
        return Stack(
          children: [
            ChannelCard(
              content: _applyChannelsFilter(favoriteChannels),
            ),
            Positioned(
              bottom: 80.0,
              left: 25.0,
              child: FloatingActionButton(
                heroTag: UniqueKey(),
                onPressed: _showFilterOptions,
                child: const Icon(Icons.filter_list),
              ),
            ),
          ],
        );
      }
    } else {
      if (favoriteVideos.isEmpty) {
        return NotFoundWdget(
          type: widget.type,
        );
      } else {
        return Stack(
          children: [
            CardScreen(
              content: _applyVideosFilter(favoriteVideos),
              fav: widget.type.contains('istory') ? false : true,
            ),
            Positioned(
              bottom: 80.0,
              left: 25.0,
              child: FloatingActionButton(
                heroTag: UniqueKey(),
                onPressed: _showFilterOptions,
                child: const Icon(Icons.filter_list),
              ),
            ),
          ],
        );
      }
    }
  }

  List<VideoItem> _applyVideosFilter(List<VideoItem> favorites) {
    if (_currentFilter == FilterOption.oldest) {
      return favorites; // No need to modify the list for newest filter
    } else if (_currentFilter == FilterOption.longest) {
      favorites.sort((a, b) => b.duration.compareTo(a.duration));
      return favorites;
    } else {
      return List.from(
          favorites.reversed); // Reverse the list for oldest filter
    }
  }

  List<Stars> _applyStarsFilter(List<Stars> favorites) {
    if (_currentFilter == FilterOption.oldest) {
      return favorites; // No need to modify the list for newest filter
    } else {
      return List.from(
          favorites.reversed); // Reverse the list for oldest filter
    }
  }

  List<Channels> _applyChannelsFilter(List<Channels> favorites) {
    if (_currentFilter == FilterOption.oldest) {
      return favorites; // No need to modify the list for newest filter
    } else {
      return List.from(
          favorites.reversed); // Reverse the list for oldest filter
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterOption(
                text: 'Newest',
                option: FilterOption.newest,
                icon: Icons.unfold_more_sharp),
            _buildFilterOption(
                text: 'Oldest',
                option: FilterOption.oldest,
                icon: Icons.unfold_more_sharp),
            if (widget.type == 'stars' || widget.type == 'channels')
              // If widget.type is 'stars' or 'channels', don't show anything
              Container()
            else
              // Otherwise, show the _buildFilterOption widget
              _buildFilterOption(
                text: 'Longest',
                option: FilterOption.longest,
                icon: Icons.unfold_more_sharp,
              ),
          ],
        );
      },
    );
  }

  Widget _buildFilterOption(
      {required String text,
      required FilterOption option,
      required IconData icon}) {
    return InkWell(
      onTap: () {
        setState(() {
          _currentFilter = option;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color:
              _currentFilter == option ? Colors.grey[200] : Colors.transparent,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            size: 24,
            color: _currentFilter == option ? Colors.blue : Colors.grey[600],
          ),
          title: Text(
            text,
            style: TextStyle(
              color: _currentFilter == option ? Colors.blue : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class NotFoundWdget extends StatelessWidget {
  String type;
  NotFoundWdget({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        type.contains('history') ? "No History Found" : "No Favorites Found",
        style: const TextStyle(fontSize: 20, color: Colors.black),
      ),
    );
  }
}

enum FilterOption {
  newest,
  oldest,
  longest,
}
