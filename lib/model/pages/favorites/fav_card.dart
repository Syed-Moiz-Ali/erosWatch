// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eroswatch/Stars/star_card.dart';
import 'package:eroswatch/helper/videos.dart';
import 'package:eroswatch/model/Channels/channels_card.dart';
import 'package:eroswatch/model/pages/card/card_screen.dart';

class FavCard extends StatefulWidget {
  Future<List<Videos>> getVideosWallpapers;
  Future<List<Stars>> getStarsWallpapers;
  Future<List<Channels>> getChannelsWallpapers;
  String type;

  FavCard({
    super.key,
    required this.getVideosWallpapers,
    required this.getStarsWallpapers,
    required this.getChannelsWallpapers,
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

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.type == 'stars'
          ? widget.getStarsWallpapers
          : widget.type == 'channels'
              ? widget.getChannelsWallpapers
              : widget.getVideosWallpapers,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Declare separate lists for different types

          if (widget.type == 'stars') {
            favoriteStars = snapshot.data! as List<Stars>;
          } else if (widget.type == 'channels') {
            favoriteChannels = snapshot.data! as List<Channels>;
          } else {
            favoriteVideos = snapshot.data! as List<Videos>;
          }

          return Container(
            color: Colors.white,
            child: Stack(
              children: [
                if (widget.type == 'stars')
                  StarCard(
                    content: _applyStarsFilter(favoriteStars),
                  )
                else if (widget.type == 'channels')
                  ChannelCard(
                    content: _applyChannelsFilter(favoriteChannels),
                  )
                else
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
            ),
          );
        } else if (snapshot.hasError) {
          if (kDebugMode) {
            print(snapshot.error);
          }
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          if (_showLoadingIndicator) {
            return const Center(
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return const Center(
              child: Text(
                "No Favorites Found",
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            );
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
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

enum FilterOption {
  newest,
  oldest,
  longest,
}
