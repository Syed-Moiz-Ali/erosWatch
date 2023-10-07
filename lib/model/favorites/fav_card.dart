// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:eroswatch/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eroswatch/model/Stars/star_card.dart';
import 'package:eroswatch/helper/videos.dart';
import 'package:eroswatch/model/Channels/channels_card.dart';
import 'package:eroswatch/model/card/card_screen.dart';

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
  List<Videos> favoriteVideos = [];
  List<Stars> favoriteStars = [];
  List<Channels> favoriteChannels = [];
  bool _showLoadingIndicator = true;
  late final database = ErosWatchDatabase(storageKey: widget.type);
  @override
  void initState() {
    super.initState();
    _loadData();
    _startTimer(); // Start the timer when the widget is created
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

  void _startTimer() {
    // Wait for 3 seconds and then update the loading indicator visibility
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _showLoadingIndicator = false; // Hide loading indicator
      });
    });
  }

  Future<void> _loadData() async {
    try {
      List<Videos> videoData;
      List<Stars> starData;
      List<Channels> channelData;
      if (widget.type == 'stars') {
        starData = await database.getAllStars();
        favoriteStars = starData;
      } else if (widget.type == 'channels') {
        channelData = await database.getAllChannels();
        favoriteChannels = channelData;
      } else {
        videoData = await database.getAllVideos();
        favoriteVideos = videoData;
      }
      setState(() {
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      onRefresh: () async {
        await _loadData();
      },
      child: Container(
        color: Colors.white,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.type == 'stars') {
      if (favoriteStars.isEmpty) {
        return const notFoundWdget();
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
                onPressed: _showFilterOptions,
                child: const Icon(Icons.filter_list),
              ),
            ),
          ],
        );
      }
    } else if (widget.type == 'channels') {
      if (favoriteChannels.isEmpty) {
        return const notFoundWdget();
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
                onPressed: _showFilterOptions,
                child: const Icon(Icons.filter_list),
              ),
            ),
          ],
        );
      }
    } else {
      if (favoriteVideos.isEmpty) {
        return const notFoundWdget();
      } else {
        return Stack(
          children: [
            CardScreen(
              content: _applyVideosFilter(favoriteVideos),
              fav: true,
            ),
            Positioned(
              bottom: 80.0,
              left: 25.0,
              child: FloatingActionButton(
                onPressed: _showFilterOptions,
                child: const Icon(Icons.filter_list),
              ),
            ),
          ],
        );
      }
    }
  }

  List<Videos> _applyVideosFilter(List<Videos> favorites) {
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

class notFoundWdget extends StatelessWidget {
  const notFoundWdget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "No Favorites Found",
        style: TextStyle(fontSize: 20, color: Colors.black),
      ),
    );
  }
}

enum FilterOption {
  newest,
  oldest,
  longest,
}
