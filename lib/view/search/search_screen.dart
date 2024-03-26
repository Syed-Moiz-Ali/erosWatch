import 'package:eroswatch/models/spankbang.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eroswatch/components/api/api_service.dart';
import 'package:eroswatch/components/smallComponents/dropdown.dart';

import 'package:eroswatch/helper/videos.dart';

import '../card/card_screen.dart';

class Search extends StatefulWidget {
  final String searchText;
  final String categ;

  const Search({Key? key, required this.searchText, required this.categ})
      : super(key: key);

  @override
  State<Search> createState() => _MySearchState();
}

class Search2 extends StatefulWidget {
  final String searchText;
  final String categ;

  const Search2({Key? key, required this.searchText, required this.categ})
      : super(key: key);

  @override
  State<Search2> createState() => _MySearchState2();
}

class Search3 extends StatefulWidget {
  final String searchText;
  final String categ;

  const Search3({Key? key, required this.searchText, required this.categ})
      : super(key: key);

  @override
  State<Search3> createState() => _MySearchState3();
}

class _MySearchState extends State<Search> {
  List<VideoItem> wallpapers = [];
  late Future<List<VideoItem>> futureWallpapers;
  List<VideoItem> favoriteWallpapers = [];
  int pageNumber = 1;
  bool isLoading = false;
  List<String> favorites = [];

  late APISearchService apiService =
      APISearchService(params: widget.searchText, categ: widget.categ);

  @override
  void initState() {
    super.initState();
    // final APIService apiService = APIService(params: widget.passedData);
    setPageDefaults();
    futureWallpapers = apiService.fetchWallpapers(1);
    fetchWallpapers();
  }

  void setPageDefaults() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedDate', 'all');
    await prefs.setString('selectedDuration', 'all');
    await prefs.setString('selectedQuality', 'all');
  }

  Future<void> fetchWallpapers() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final List<VideoItem> newWallpapers =
          await apiService.fetchWallpapers(pageNumber);

      setState(() {
        wallpapers.addAll(newWallpapers);
        pageNumber++;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        print('Failed to load wallpapers: $e');
      }
    }
  }

  void fetchDataAndUpdateUI() async {
    setState(() {
      isLoading = true;
    });
    // Fetch new data from the API
    final newWallpapers = await apiService.fetchWallpapers(1);

    // Update the UI with new data
    setState(() {
      wallpapers =
          newWallpapers; // Assuming 'wallpapers' is the List you use to display the content
      isLoading = false;
    });
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      final metrics = notification.metrics;
      final maxScroll = metrics.maxScrollExtent;
      final currentScroll = metrics.pixels;
      if (maxScroll - currentScroll <= 1400) {
        // Reached the end of the current page, fetch next page
        fetchWallpapers();
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // final String categTitle =
    //     widget.searchText.replaceAll("wall/", "").replaceAll("-", " ");
    // int pageIndex = 0;
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: Stack(
          children: [
            CardScreen(
              content: wallpapers,
            ),
            if (isLoading)
              const Center(
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(),
                ),
              ),
            Positioned(
              left: 10,
              bottom: 15,
              child: DropDown(
                fetch: fetchDataAndUpdateUI,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _MySearchState2 extends State<Search2> {
  List<VideoItem> wallpapers = [];
  late Future<List<VideoItem>> futureWallpapers;
  List<VideoItem> favoriteWallpapers = [];
  int pageNumber = 1;
  bool isLoading = false;
  List<String> favorites = [];

  late APISearchService apiService =
      APISearchService(params: widget.searchText, categ: widget.categ);

  @override
  void initState() {
    super.initState();
    // final APIService apiService = APIService(params: widget.passedData);
    futureWallpapers = apiService.fetchWallpapers(1);
    fetchWallpapers();
  }

  Future<void> fetchWallpapers() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final List<VideoItem> newWallpapers =
          await apiService.fetchWallpapers(pageNumber);

      setState(() {
        wallpapers.addAll(newWallpapers);
        pageNumber++;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        print('Failed to load wallpapers: $e');
      }
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        notification.metrics.extentAfter <= 1400) {
      fetchWallpapers();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // final String categTitle =
    //     widget.searchText.replaceAll("wall/", "").replaceAll("-", " ");
    // int pageIndex = 0;
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: CardScreen(
          content: wallpapers,
        ),
      ),
    );
  }
}

class _MySearchState3 extends State<Search3> {
  List<VideoItem> wallpapers = [];
  late Future<List<VideoItem>> futureWallpapers;
  List<VideoItem> favoriteWallpapers = [];
  int pageNumber = 1;
  bool isLoading = false;
  List<String> favorites = [];

  late APISearchService apiService =
      APISearchService(params: widget.searchText, categ: widget.categ);

  @override
  void initState() {
    super.initState();
    // final APIService apiService = APIService(params: widget.passedData);
    futureWallpapers = apiService.fetchWallpapers(1);
    fetchWallpapers();
  }

  Future<void> fetchWallpapers() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final List<VideoItem> newWallpapers =
          await apiService.fetchWallpapers(pageNumber);

      setState(() {
        wallpapers.addAll(newWallpapers);
        pageNumber++;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        print('Failed to load wallpapers: $e');
      }
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification &&
        notification.metrics.extentAfter <= 1400) {
      fetchWallpapers();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // final String categTitle =
    //     widget.searchText.replaceAll("wall/", "").replaceAll("-", " ");
    // int pageIndex = 0;
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: CardScreen(
          content: wallpapers,
        ),
      ),
    );
  }
}
