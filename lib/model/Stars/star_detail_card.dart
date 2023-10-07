import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eroswatch/components/api/api_service.dart';
import 'package:eroswatch/helper/videos.dart';

class StarDetailCard extends StatefulWidget {
  final String id;
  const StarDetailCard({super.key, required this.id});

  @override
  State<StarDetailCard> createState() => _StarDetailCardState();
}

class _StarDetailCardState extends State<StarDetailCard> {
  late APIStarsDetails apiService = APIStarsDetails(
      params: "/starDetail/${widget.id}/page=1/trending/q=all/d=all");
  List<StarsDetails> starsDetails = [];
  // late Future<List<StarsDetails>> _starDetails;
  bool isLoading = false;
  String avatarImageUrl = 'avatarImageUrl';
  String starTitle = 'starTitle';
  String starViews = 'starViews';
  String starVideos = 'starVideos';
  String starAge = 'starAge';
  String starFrom = 'starFrom';
  String starColor = 'starColor';
  String starHair = 'starHair';
  String starHeight = 'starHeight';
  String starWeight = 'starWeight';
  @override
  void initState() {
    super.initState();
    // apiService.fetchWallpapers(1);
    fetchStars();
  }

  Future<void> fetchStars() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      final List<StarsDetails> newStars = await apiService.fetchWallpapers(1);

      setState(() {
        starsDetails.addAll(newStars);

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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
          itemCount: starsDetails.length + 1,
          itemBuilder: (context, index) {
            if (index == starsDetails.length) {
              return const Row();
            }
            final StarsDetails starDetail = starsDetails[index];
            return Column(
              children: [
                Card(
                  // decoration: BoxDecoration(color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            starDetail.starImg,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/avatar.png', // Provide your stock image path here
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(
                            //   starDetail.starTitle,
                            //   style: const TextStyle(
                            //     fontSize: 18.0,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Views: ${starDetail.starViews}'),
                                    Text('Videos: ${starDetail.starVideos}'),
                                    Text('Age: ${starDetail.starAge}'),
                                    Text('From: ${starDetail.starFrom}'),
                                  ],
                                ),
                                const SizedBox(width: 16.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Color: ${starDetail.starColor}'),
                                    Text('Hair: ${starDetail.starHair}'),
                                    Text('Height: ${starDetail.starHeight}'),
                                    Text('Weight: ${starDetail.starWeight}'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }
}
