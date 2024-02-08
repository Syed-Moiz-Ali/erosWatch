// ignore_for_file: use_build_context_synchronously, file_names, avoid_print

import 'package:flutter/material.dart';

import '../../../global/globalFunctions.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  List data = [];
  Future<void> fetchData() async {
    var baseUrl = 'https://txxx.com';
    // sharedPreferences.getString('baseUrl');
    try {
      final apiData = await ApiService.fetchData(context,
          '$baseUrl/api/json/videos2/14400/str/most-popular/60/..1.all..day.json');
      setState(() {
        data = apiData['videos']; // Update albums data
      });

      print('the apiData is $apiData');
    } catch (error) {
      // Handle API call errors
      print('Error fetching albums: $error');
      // You can show an alert using AlertService from previous code
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        var item = data[index];
        return Column(
          children: [
            Image.network(
              item['scr'],
              width: width,
              height: 200,
              fit: BoxFit.cover,
            ),
            // CustomVideoPlayer(
            //   isShown: true,
            //   videoUrl: videoUrl,
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item['duration'].toString()),
                Row(
                  children: [
                    Text(item['video_viewed'].toString()),
                    Text(item['rating'].toString()),
                    Text(item['post_date'].toString()),
                  ],
                )
              ],
            ),
            Text(item['title']),
          ],
        );
      },
    );
  }
}
