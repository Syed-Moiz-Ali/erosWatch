import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eroswatch/Stars/star_card.dart';
import '../components/api_service.dart';
import '../helper/videos.dart';

class StarsScreen extends StatefulWidget {
  const StarsScreen({super.key});

  @override
  State<StarsScreen> createState() => _StarsScreenState();
}

class _StarsScreenState extends State<StarsScreen> {
  final APIStars apiService = APIStars(params: "stars");
  List<Stars> stars = [];
  bool isLoading = false;
  int pageNumber = 1;
  late Future<List<Stars>> futureStars;
  List<Stars> favoriteWallpapers = [];
  @override
  void initState() {
    super.initState();
    futureStars = apiService.fetchWallpapers(1);
    fetchStars();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchStars() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final List<Stars> newStars = await apiService.fetchWallpapers(pageNumber);

      setState(() {
        stars.addAll(newStars);
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
      fetchStars();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Latest Wallpapers")),
      body: Stack(
        children: [
          const SizedBox(
              // height: 300,
              // width: double.infinity,
              ),
          NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: StarCard(
              content: stars,
            ),
          ),
          if (isLoading)
            // Loader widget displayed in the center of the screen
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
