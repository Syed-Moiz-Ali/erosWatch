// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:eroswatch/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eroswatch/helper/videos.dart';

import 'package:eroswatch/model/pages/favorites/fav_card.dart';

class FavScreen extends StatefulWidget {
  const FavScreen({Key? key}) : super(key: key);

  @override
  _FavScreenState createState() => _FavScreenState();
}

class _FavScreenState extends State<FavScreen> {
  String _selectedType = 'videos';
  Key? _pageKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          FavCard(
            type: _selectedType,
            getChannelsWallpapers: channelsStorage.restoreData(),
            getStarsWallpapers: starsStorage.restoreData(),
            getVideosWallpapers: videosStorage.restoreData(),
            key: _pageKey,
          ),
          Positioned(
            bottom: 80.0,
            right: 25.0,
            child: FloatingActionButton(
              onPressed: _openMenu,
              child: const Icon(Icons.menu),
            ),
          ),
        ],
      ),
    );
  }

  final videosStorage = WallpaperStorage<Videos>(
    storageKey: 'favorites', // Use a unique key for each data type
    fromJson: (json) => Videos.fromJson(json),
    toJson: (data) => data.toJson(),
  );

  final starsStorage = WallpaperStorage<Stars>(
    storageKey: 'favoriteStars',
    fromJson: (json) => Stars.fromJson(json),
    toJson: (data) => data.toJson(),
  );

  final channelsStorage = WallpaperStorage<Channels>(
    storageKey: 'favoriteChannels',
    fromJson: (json) => Channels.fromJson(json),
    toJson: (data) => data.toJson(),
  );

  void _openMenu() {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTab(0, Icons.label_outline, 'Videos'),
              _buildTab(1, Icons.local_fire_department, 'Stars'),
              _buildTab(2, Icons.upcoming_outlined, 'Channels'),
            ],
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedType = value.toLowerCase();
          _pageKey = UniqueKey();
        });
        if (kDebugMode) {
          print('Selected option: ${value.toLowerCase()}');
        }
      }
    });
  }

  Widget _buildTab(int index, IconData icon, String title) {
    final isSelected = index == _selectedTabIndex;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = title.toLowerCase();
          Navigator.pop(context, title);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.transparent,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            size: 24,
            color: isSelected ? Colors.blue : Colors.grey[600],
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  int get _selectedTabIndex {
    switch (_selectedType) {
      case 'videos':
        return 0;
      case 'stars':
        return 1;
      case 'channels':
        return 2;
      default:
        return 0;
    }
  }
}
