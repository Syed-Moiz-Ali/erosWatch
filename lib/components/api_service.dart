import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eroswatch/helper/videos.dart';
import 'package:flutter/material.dart';

var headers = {
  "Access-Control-Allow-Origin": "*", // Required for CORS support to work
  "Access-Control-Allow-Credentials":
      '*', // Required for cookies, authorization headers with HTTPS
  "Access-Control-Allow-Headers":
      "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
  "Access-Control-Allow-Methods": "POST, OPTIONS, GET",
  'Accept': 'image/*', 'Accept-language': 'en'
};

class APIService {
  String params;
  String? newParamForStarAndChannel;
  String id;

  final String baseUrl = 'https://flutterspanlapp-api.vercel.app/api';
  final imgHeaders = {'Accept': 'image/*', 'Accept-language': 'en'};

  APIService({
    required this.params,
    this.newParamForStarAndChannel,
    this.id = '',
  });

  Future<List<Videos>> fetchWallpapers(int pageNo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final selectedDate = prefs.getString('selectedDate') ?? 'all';
    final selectedDuration = prefs.getString('selectedDuration') ?? 'all';
    final selectedQuality = prefs.getString('selectedQuality') ?? 'all';
    if (kDebugMode) {
      print('selectedDate $selectedDate');
    }
    if (kDebugMode) {
      print('selectedDuration $selectedDuration');
    }
    if (kDebugMode) {
      print('selectedQuality $selectedQuality');
    }
    final String url = id != ''
        ? '$baseUrl/${params}page=$pageNo/$newParamForStarAndChannel/q=$selectedQuality/d=$selectedDuration'
        : params == "popular"
            ? '$baseUrl/$params/page=$pageNo/q=$selectedQuality/d=$selectedDuration/p=$selectedDate'
            : params.contains('similar')
                ? '$baseUrl/$params'
                : '$baseUrl/$params/page=$pageNo/q=$selectedQuality/d=$selectedDuration';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        final List<Videos> wallpapers =
            data.map((item) => Videos.fromJson(item)).toList();

        if (kDebugMode) {
          print('Fetched ${wallpapers.length} wallpapers successfully.');
        }

        return wallpapers;
      } else {
        if (kDebugMode) {
          print(
              'Failed to load wallpapers. Status code: ${response.statusCode}');
        }
        throw Exception('Failed to load wallpapers');
      }
    } catch (e) {
      if (kDebugMode) {
        print('An error occurred while fetching wallpapers: $e');
      }
      throw Exception('Failed to load wallpapers');
    }
  }
}

class APIStarsDetailVids {
  String params;
  String? newParamForStarAndChannel;
  String? id;

  final String baseUrl = 'https://flutterspanlapp-api.vercel.app/api';
  final imgHeaders = {'Accept': 'image/*', 'Accept-language': 'en'};

  APIStarsDetailVids(
      {required this.params, this.newParamForStarAndChannel, this.id});

  Future<List<Videos>> fetchWallpapers(int pageNo) async {
    final String url =
        '$baseUrl${params}page=$pageNo/$newParamForStarAndChannel/q=all/d=all';

// api/search/keyword=:word/:categ/page=:page/q=:qualtiy/d=:duration/p=:date
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      final List<Videos> wallpapers =
          data.map((item) => Videos.fromJson(item)).toList();

      return wallpapers;
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}

class APISearchService {
  String params;
  String categ;

  final String baseUrl = 'https://flutterspanlapp-api.vercel.app/api';
  final imgHeaders = {'Accept': 'image/*', 'Accept-language': 'en'};
  APISearchService({this.params = '', this.categ = 'trending'});

  Future<List<Videos>> fetchWallpapers(int pageNo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final selectedDate = prefs.getString('selectedDate') ?? 'all';
    final selectedDuration = prefs.getString('selectedDuration') ?? 'all';
    final selectedQuality = prefs.getString('selectedQuality') ?? 'all';

    final String url =
        '$baseUrl/search/keyword=$params/$categ/page=$pageNo/q=$selectedQuality/d=$selectedDuration/p=$selectedDate';
// api/search/keyword=:word/:categ/page=:page/q=:qualtiy/d=:duration/p=:date
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      final List<Videos> wallpapers =
          data.map((item) => Videos.fromJson(item)).toList();

      return wallpapers;
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}

class APIStars {
  String params;

  final String baseUrl = 'https://flutterspanlapp-api.vercel.app/api';
  final imgHeaders = {'Accept': 'image/*', 'Accept-language': 'en'};
  APIStars({
    required this.params,
  });

  Future<List<Stars>> fetchWallpapers(int pageNo) async {
    final String url = '$baseUrl/$params/page=$pageNo';
// api/search/keyword=:word/:categ/page=:page/q=:qualtiy/d=:duration/p=:date
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      final List<Stars> wallpapers =
          data.map((item) => Stars.fromJson(item)).toList();

      return wallpapers;
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}

class APIChannels {
  String params;
  String type;

  final String baseUrl = 'https://flutterspanlapp-api.vercel.app/api';
  final imgHeaders = {'Accept': 'image/*', 'Accept-language': 'en'};
  APIChannels({required this.params, required this.type});

  Future<List<Channels>> fetchWallpapers(int pageNo) async {
    final String url = '$baseUrl/$params/$type/page=$pageNo';
// api/search/keyword=:word/:categ/page=:page/q=:qualtiy/d=:duration/p=:date
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      final List<Channels> wallpapers =
          data.map((item) => Channels.fromJson(item)).toList();

      return wallpapers;
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}

class APIStarsDetails {
  String params;

  final String baseUrl = 'https://flutterspanlapp-api.vercel.app/api';
  final imgHeaders = {'Accept': 'image/*', 'Accept-language': 'en'};
  APIStarsDetails({
    required this.params,
  });

  Future<List<StarsDetails>> fetchWallpapers(int pageNo) async {
    final String url = '$baseUrl/$params';
// api/search/keyword=:word/:categ/page=:page/q=:qualtiy/d=:duration/p=:date
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      final List<StarsDetails> wallpapers =
          data.map((item) => StarsDetails.fromJson(item)).toList();

      return wallpapers;
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}

class APIServiveForVideoTags {
  late String params;
  final String baseUrl = 'https://flutterspanlapp-api.vercel.app/api';
  final imgHeaders = {'Accept': 'image/*', 'Accept-language': 'en'};
  APIServiveForVideoTags({required this.params});

  Future<List<VideoTags>> fetchWallpapers() async {
    final String url = '$baseUrl/watch/tags$params';
    // print(url);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      final List<VideoTags> videoTags =
          data.map((item) => VideoTags.fromJson(item)).toList();

      return videoTags;
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}

class APIServiceDetailPage {
  late String params;
  final String baseUrl = 'https://flutterspanlapp-api.vercel.app/api';
  final imgHeaders = {'Accept': 'image/*', 'Accept-language': 'en'};
  APIServiceDetailPage({required this.params});

  Future<List<Episode>> fetchWallpapers() async {
    final String url = '$baseUrl/watch$params';
    // print(url);
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      final List<Episode> wallpapers =
          data.map((item) => Episode.fromJson(item)).toList();

      return wallpapers;
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}

class APITags {
  late String params;
  final String baseUrl = 'https://flutterspanlapp-api.vercel.app/api';
  final imgHeaders = {'Accept': 'image/*', 'Accept-language': 'en'};
  APITags({required this.params});

  Future<List<Tags>> fetchWallpapers() async {
    final String url = '$baseUrl/$params/tags';
    // print(url);
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      final List<Tags> wallpapers =
          data.map((item) => Tags.fromJson(item)).toList();

      return wallpapers;
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}

class ImageComponent extends StatelessWidget {
  final String imagePath;
  final String title;
  final String time;
  final String duration;

  const ImageComponent({
    Key? key,
    required this.imagePath,
    this.title = "test",
    this.time = '',
    this.duration = '',
  }) : super(key: key);

  text(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uniqueTag = UniqueKey().toString();

    // const errorImage =
    // //     'https://dicdn.bigfuck.tv/Qbc_5-9LHHJQijmVZSAKSkjuET8-WEVK52UdxGdxXGs/rs:fill:360:506/crop:0:0.90:no/enlarge:1/wm:1:nowe:0:0:1/Swmu:aHR0cHM6Ly9jZG42OTY5NjE2NC5haGFjZG4ubWUvcG9ybnN0YXJfYXZhdGFyX3dhdGVybWFyay5wbmc=/aHR0cHM6Ly9pY2RuMDUuYmlnZnVjay50di9wb3Juc3Rhci84NDAvMTU2YTQ4NjlkMDhlZTBiODY0ZDlmMGEwNWY3MmE4ZWIuanBn.webp';
    // const image =
    //     "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTnSsLWVn6ZOrtsgl4lhc4C9DnRGk8ituA04w&usqp=CAU";
    return Stack(
      children: [
        Hero(
          tag: uniqueTag,
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(title == 'channel' ? 1200000 : 8.0),
            child: CachedNetworkImage(
              imageUrl: imagePath,
              fit: BoxFit.cover,
              height: title == 'star'
                  ? 300
                  : title == 'channel'
                      ? 150
                      : double.infinity,
              width: title == 'channel' ? 150 : double.infinity,
              errorWidget: (context, url, error) => Stack(children: [
                Opacity(
                  opacity: 0.5,
                  child: Image.asset(
                    'assets/images/error_image.webp', // Replace with the path to your error image asset
                    height: title == 'star' ? 300 : 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const Center(
                  child: Icon(Icons.error),
                )
              ]),
              // color: Colors.blue38,
              placeholderFadeInDuration: const Duration(milliseconds: 700),
              useOldImageOnUrlChange: true,

              // errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
        // if (title != 'star' && title != 'channel')
        //   Positioned(
        //     bottom: 0,
        //     right: 0,
        //     left: 0,
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         text(duration),
        //         text(time),
        //       ],
        //     ),
        //   )
      ],
    );
  }

  Widget errorWidget(String alternativeImageUrl) {
    return Image.network(
      alternativeImageUrl,
      width: 200,
      height: 200,
    );
  }
}
