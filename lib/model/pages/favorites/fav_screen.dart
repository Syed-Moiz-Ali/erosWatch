// ignore_for_file: library_private_types_in_public_api

import 'package:eroswatch/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eroswatch/helper/videos.dart';

import 'package:eroswatch/model/pages/favorites/fav_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavScreen extends StatefulWidget {
  const FavScreen({Key? key}) : super(key: key);

  @override
  _FavScreenState createState() => _FavScreenState();
}

class _FavScreenState extends State<FavScreen> {
  String _selectedType = 'videos';
  Key? _pageKey = UniqueKey();
  late SharedPreferences prefs;
  late Future<void> initialization;

  late final WallpaperStorage<Videos> videosStorage;
  late final WallpaperStorage<Stars> starsStorage;
  late final WallpaperStorage<Channels> channelsStorage;
  @override
  void initState() {
    super.initState();
    initialization = initializing();
  }

  Future<void> initializing() async {
    final pref = await SharedPreferences.getInstance();

    setState(
      () {
        prefs = pref;
        videosStorage = WallpaperStorage<Videos>(
          storageKey: 'favorites',
          fromJson: (json) => Videos.fromJson(json),
          toJson: (data) => data.toJson(),
          prefs: prefs,
        );

        starsStorage = WallpaperStorage<Stars>(
          storageKey: 'favoriteStars',
          fromJson: (json) => Stars.fromJson(json),
          toJson: (data) => data.toJson(),
          prefs: prefs,
        );

        channelsStorage = WallpaperStorage<Channels>(
          storageKey: 'favoriteChannels',
          fromJson: (json) => Channels.fromJson(json),
          toJson: (data) => data.toJson(),
          prefs: prefs,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(),
            ),
          ); // Show a loading indicator while initializing
        } else if (snapshot.hasError) {
          return Center(
            child: SizedBox(
                height: 50, width: 50, child: Text('Error: ${snapshot.error}')),
          ); // Show an error message if initialization fails
        }

        // Initialization is completed, build the widget
        final channels = channelsStorage.getDataList();
        final stars = starsStorage.getDataList();
        final videos = videosStorage.getDataList();

        return Stack(
          children: [
            FutureBuilder(
              future: _getSelectedList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  ); // Show a loading indicator while loading data
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                        'Error: ${snapshot.error}'), // Show an error message if data loading fails
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No $_selectedType favorites found',
                      style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w600),
                    ),
                  );
                } else {
                  return FavCard(
                    type: _selectedType,
                    getChannelsWallpapers: channels,
                    getStarsWallpapers: stars,
                    getVideosWallpapers: videos,
                    key: _pageKey,
                  );
                }
              },
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
        );
      },
    );
  }

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

  Future<List<dynamic>> _getSelectedList() async {
    await initialization;
    if (_selectedType == 'channels') {
      return await channelsStorage.getDataList();
    } else if (_selectedType == 'stars') {
      return await starsStorage.getDataList();
    } else {
      return await videosStorage.getDataList();
    }
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
