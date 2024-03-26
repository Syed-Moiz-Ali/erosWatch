// ignore_for_file: avoid_print, library_prefixes, depend_on_referenced_packages, use_build_context_synchronously

import 'dart:convert';
import 'package:eroswatch/helper/api_helper.dart';
import 'package:eroswatch/models/spankbang.dart' as spankbang;
import 'package:eroswatch/providers/modelProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eroswatch/helper/videos.dart';
import 'package:html/parser.dart' as htmlParser;

var headers = {
  "Access-Control-Allow-Origin": "*", // Required for CORS support to work
  "Access-Control-Allow-Credentials":
      '*', // Required for cookies, authorization headers with HTTPS
  "Access-Control-Allow-Headers":
      "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
  "Access-Control-Allow-Methods": "POST, OPTIONS, GET",
  'Accept': 'image/*', 'Accept-language': 'en'
};

// final firebaseDatabaseService = FirebaseDatabaseService();
// final getBaseURL = firebaseDatabaseService.getBaseUrl();
// String baseUrl = getBaseURL;
// Future<String> baseUrl() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   final baseUrl = prefs.getString('baseUrl');
//   return baseUrl!;
// }

class APIService {
  String params;
  String? newParamForStarAndChannel;
  String id;

  final imgHeaders = {'Accept': 'image/*', 'Accept-language': 'en'};

  APIService({
    required this.params,
    this.newParamForStarAndChannel,
    this.id = '',
  });

  fetchWallpapers(BuildContext context, int pageNo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final selectedDate = prefs.getString('selectedDate') ?? 'all';
    final selectedDuration = prefs.getString('selectedDuration') ?? 'all';
    final selectedQuality = prefs.getString('selectedQuality') ?? 'all';
    List allCoupon = [];

    final baseUrl = prefs.getString('baseUrl');
    if (kDebugMode) {
      print('selectedDate $selectedDate');
      print('selectedDuration $selectedDuration');
      print('selectedQuality $selectedQuality');
    }

    String queryParams = '';

    if (selectedDate != 'all' && params == "popular_videos") {
      if (queryParams == '') {
        queryParams += '/?';
      }
      queryParams += '&p=$selectedDate';
    }

    if (selectedQuality != 'all') {
      if (queryParams == '') {
        queryParams += '/?';
      }
      queryParams += '&q=$selectedQuality';
    }

    if (selectedDuration != 'all') {
      if (queryParams == '') {
        queryParams += '/?';
      }
      queryParams += '&d=$selectedDuration';
    }

    final String url =
        // id != ''
        //     ? '$baseUrl$params${pageNo != 1 ? '$pageNo' : ''}?$newParamForStarAndChannel$queryParams'
        //     : params == "popular_videos"
        //         ? '$baseUrl/$params${pageNo != 1 ? '/$pageNo' : ''}$queryParams'
        //         : params.contains('similar')
        //             ? '$baseUrl/${params.replaceAll('similar/', '')}'
        //             : '$baseUrl/$params${pageNo != 1 ? '/$pageNo' : ''}$queryParams';
        spankbang.SpankbangBaseUrls().buildUrl(baseUrl!, params, pageNo,
            newParamForStarAndChannel!, queryParams, id);
    print('urlis $url');
    allCoupon.clear();

    try {
      // await http.post(
      //   Uri.parse('$baseUrl/api/show_edition?id=0&data=ww'),
      //   headers: headers,
      // );

      // await http.post(
      //   Uri.parse('$baseUrl/1033103515'),
      //   headers: headers,
      //   body: jsonEncode({
      //     "site_version": "desktop",
      //     "site_branch": "master",
      //     "site_language": "en",
      //     "type": "ev",
      //     "url": url,
      //     "url_group": "most popular",
      //     "referral_url": "$baseUrl$params",
      //     "referral_domain": "spankbang.party",
      //     "event_category": "edition",
      //     "event_label": "show",
      //     "event_value": "WW",
      //     "experiment_id": "master",
      //     "request_time": 1703500294,
      //   }),
      // );

      // final response = await http.get(
      //   Uri.parse(url),
      //   headers: headers,
      // );
      // // print('response  is ${response.body}');
      // if (response.statusCode == 200) {
      //   final String html = response.body;
      //   final document = htmlParser.parse(html);
      //   // print('allCoupon is $allCoupon');

      //   final elements = document.querySelectorAll('.video-list > .video-item');
      //   allCoupon.addAll(elements.map((element) => {
      //         'title': element.querySelector('.n')?.text ?? '',
      //         'id': element.querySelector('.thumb')?.attributes['href'] ?? '',
      //         'image': element
      //                 .querySelector('.thumb > picture > img')
      //                 ?.attributes['data-src'] ??
      //             '',
      //         'preview': element
      //                 .querySelector('.thumb > picture > img')
      //                 ?.attributes['data-preview'] ??
      //             '',
      //         'duration': element.querySelector('.thumb > .t > .l')?.text ?? '',
      //         'quality': element.querySelector('.thumb > .t > .h')?.text ?? '',
      //         'time': element.querySelector('.stats > .v')?.text ?? '',
      //       }));

      //   final List<Videos> wallpapers =
      //       allCoupon.map((item) => Videos.fromMap(item)).toList();

      //   // if (kDebugMode) {
      //   //   print('Fetched ${wallpapers.length} wallpapers successfully.');
      //   //   print('Fetched ${wallpapers[0].title} wallpapers successfully.');
      //   // }
      //   final List<Videos> filteredWallpapers = wallpapers.skip(8).toList();
      //   return filteredWallpapers;
      // } else {
      //   if (kDebugMode) {
      //     print(
      //         'Failed to load wallpapers. Status code: ${response.statusCode}');
      //   }
      //   print('allCoupon is $allCoupon');
      //   throw Exception('Failed to load wallpapers');
      // }
      var provider = Provider.of<ModelProvider>(context, listen: false);
      print('baseURRRRRLLLLL is ${provider.baseUrl}');
      return ApiHelper.fetchData(
          url,
          // spankbang.Spankbang.parseVideoItems
          provider.model.parseVideoItems);
    } catch (e) {
      if (kDebugMode) {
        print('An error occurred while fetching wallpapers: $e');
      }
      throw Exception('Failed to load wallpapers $e');
    }
  }
}

class APIStarsDetailVids {
  String params;
  String? newParamForStarAndChannel;
  String? id;

  final imgHeaders = {'Accept': 'image/*', 'Accept-language': 'en'};

  APIStarsDetailVids(
      {required this.params, this.newParamForStarAndChannel, this.id});

  Future<List<Videos>> fetchWallpapers(int pageNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('baseUrl');
    final String url =
        '$baseUrl$params$pageNo/o=$newParamForStarAndChannel/q=all/d=all';

// api/search/keyword=:word/:categ/page=:page/q=:qualtiy/d=:duration/p=:date
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      // final data = jsonDecode(response.body) as List<dynamic>;
      // final List<Videos> wallpapers =
      //     data.map((item) => Videos.fromJson(item)).toList();
      final document = htmlParser.parse(response.body);
      final List<Map<String, String>> channelDetail = [];

      document.querySelectorAll('.top > .i > p').forEach((element) {
        final starViews = element.querySelector('span')?.text.substring(6);
        final starVideos = element
            .querySelector('span')
            ?.nextElementSibling
            ?.text
            .substring(7);
        final starTitle =
            document.querySelector('.top .p > img')?.attributes['alt'];
        final starAge = element
            .querySelector('span')
            ?.nextElementSibling
            ?.nextElementSibling
            ?.text
            .substring(5);
        final starFrom = element
            .querySelector('span')
            ?.nextElementSibling
            ?.nextElementSibling
            ?.nextElementSibling
            ?.text
            .substring(5);
        final starColor = element
            .querySelectorAll('span')
            .last
            .previousElementSibling
            ?.previousElementSibling
            ?.previousElementSibling
            ?.text
            .substring(10);
        final starHair = element
            .querySelectorAll('span')
            .last
            .previousElementSibling
            ?.previousElementSibling
            ?.text
            .substring(11);
        final starHeight = element
            .querySelectorAll('span')
            .last
            .previousElementSibling
            ?.text
            .substring(7);
        final starWeight =
            element.querySelectorAll('span').last.text.substring(7);
        final starImg =
            document.querySelector('.top .p > img')?.attributes['src'];

        channelDetail.add({
          'starTitle': starTitle ?? '',
          'starImg': starImg ?? '',
          'starViews': starViews ?? '',
          'starVideos': starVideos ?? '',
          'starAge': starAge ?? '',
          'starFrom': starFrom ?? '',
          'starColor': starColor ?? '',
          'starHair': starHair ?? '',
          'starHeight': starHeight ?? '',
          'starWeight': starWeight,
        });
      });

      // final data = jsonDecode(response.body) as List<dynamic>;
      final List<Videos> wallpapers =
          channelDetail.map((item) => Videos.fromJson(item)).toList();

      return wallpapers;
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}

class APISearchService {
  String params;
  String categ;

  final imgHeaders = {'Accept': 'image/*', 'Accept-language': 'en'};
  APISearchService({this.params = '', this.categ = 'trending'});

  fetchWallpapers(int pageNo) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final baseUrl = prefs.getString('baseUrl');
    final selectedDate = prefs.getString('selectedDate') ?? 'all';
    final selectedDuration = prefs.getString('selectedDuration') ?? 'all';
    final selectedQuality = prefs.getString('selectedQuality') ?? 'all';

    final String url =
        '$baseUrl/s/$params/$pageNo/?o=$categ&q=$selectedQuality&d=$selectedDuration&p=$selectedDate';
// api/search/keyword=:word/:categ/page=:page/q=:qualtiy/d=:duration/p=:date
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final document = htmlParser.parse(response.body);
      final List<Map<String, String>> videosList = [];

      document
          .querySelectorAll('.video-list-with-ads > .video-item')
          .forEach((element) {
        final title = element.querySelector('.n')?.text;
        final id = element.querySelector('.thumb')?.attributes['href'];
        final dataId = element.attributes['data-id'];
        final image = element
            .querySelector('.thumb > picture > img')
            ?.attributes['data-src'];
        final preview = element
            .querySelector('.thumb > picture > img')
            ?.attributes['data-preview'];
        final duration = element.querySelector('.thumb > .t > .l')?.text;
        final quality = element.querySelector('.thumb > .t > .h')?.text;
        final percentage = element.querySelector('.stats > .d')?.text;
        final views = element.querySelector('.stats > .v')?.text;
        final time = element.querySelector('.stats > .v')?.text;

        videosList.add({
          'title': title ?? '',
          'dataId': dataId ?? '',
          'id': id ?? '',
          'image': image ?? '',
          'preview': preview ?? '',
          'duration': duration ?? '',
          'quality': quality ?? '',
          'percentage': percentage ?? '',
          'views': views ?? '',
          'time': time ?? '',
        });
      });

      // final data = jsonDecode(response.body) as List<dynamic>;
      final List<Videos> wallpapers =
          videosList.map((item) => Videos.fromJson(item)).toList();

      return wallpapers;
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}

class APIStars {
  String params;

  final imgHeaders = {'Accept': 'image/*', 'Accept-language': 'en'};
  APIStars({
    required this.params,
  });

  Future<List<Stars>> fetchWallpapers(int pageNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('baseUrl');
    final String url = '$baseUrl/pornstars/$pageNo';
// api/search/keyword=:word/:categ/page=:page/q=:qualtiy/d=:duration/p=:date
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final document = htmlParser.parse(response.body);
      final List<Map<String, String>> starsList = [];

      document
          .querySelectorAll('#pornstars > .results > li')
          .forEach((element) {
        final image = element.querySelector('.image > img')?.attributes['src'];
        final starName = element.querySelector('.title')?.text;

        final id = element.querySelector('.title')?.attributes['href'];
        final views = element.querySelector('.image > .views')?.text;
        final videos = element.querySelector('.image > .videos')?.text;

        starsList.add({
          'starName': starName ?? '',
          'image': image ?? '',
          'id': id ?? '',
          'views': views ?? '',
          'videos': videos ?? '',
        });
      });
      // final data = jsonDecode(response.body) as List<dynamic>;
      final List<Stars> wallpapers =
          starsList.map((item) => Stars.fromJson(item)).toList();

      return wallpapers;
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}

class APIChannels {
  String params;
  String type;

  final imgHeaders = {'Accept': 'image/*', 'Accept-language': 'en'};
  APIChannels({required this.params, required this.type});

  Future<List<Channels>> fetchWallpapers(int pageNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('baseUrl');
    final String url = '$baseUrl/channels/$pageNo?o=$type';
// api/search/keyword=:word/:categ/page=:page/q=:qualtiy/d=:duration/p=:date
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final document = htmlParser.parse(response.body);
      final List<Map<String, String>> channelsList = [];

      document.querySelectorAll('.results > li').forEach((element) {
        final image = element.querySelector('.image > img')?.attributes['src'];
        final title = element.querySelector('.title')?.text;

        final id = element.querySelector('.image')?.attributes['href'];

        channelsList.add({
          'title': title ?? '',
          'id': id ?? '',
          'image': image ?? '',
        });
      });
      // final data = jsonDecode(response.body) as List<dynamic>;
      final List<Channels> wallpapers =
          channelsList.map((item) => Channels.fromJson(item)).toList();

      return wallpapers;
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}

class APIStarsDetails {
  String params;

  final imgHeaders = {'Accept': 'image/*', 'Accept-language': 'en'};
  APIStarsDetails({
    required this.params,
  });

  Future<List<StarsDetails>> fetchWallpapers(int pageNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('baseUrl');
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

  final imgHeaders = {'Accept': 'image/*', 'Accept-language': 'en'};
  APIServiveForVideoTags({required this.params});

  Future<List<VideoTags>> fetchWallpapers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('baseUrl');
    final String url = '$baseUrl$params';
    // print(url);
    print('urlis $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = htmlParser.parse(response.body);
      final List<Map<String, String>> videoTagsList = [];

      document.querySelectorAll('.left > .searches > a ').forEach((element) {
        final title = element.text;
        final id = element.attributes['href'];

        videoTagsList.add({
          'tagTitle': title,
          'tagId': id ?? '',
        });
      });

      print('videoTagsList is ${videoTagsList.toString()}');
      // final data = jsonDecode(response.body) as List<dynamic>;
      final List<VideoTags> videoTags =
          videoTagsList.map((item) => VideoTags.fromJson(item)).toList();

      return videoTags;
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}

class APIServiceDetailPage {
  late String params;

  final imgHeaders = {'Accept': 'image/*', 'Accept-language': 'en'};
  APIServiceDetailPage({required this.params});

  Future<List<Episode>> fetchWallpapers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('baseUrl');
    final String url = '$baseUrl$params';
    List<Map<String, dynamic>> episodes = [];

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final String html = response.body;
      final document = htmlParser.parse(html);

      final List<Map<String, dynamic>> episodesData = [];
      document.querySelectorAll('#container').forEach((element) {
        final watchingLink =
            element.querySelector('script[type="text/javascript"]')?.innerHtml;

        if (watchingLink != null) {
          final match =
              RegExp(r'var stream_data = ({.*?});').firstMatch(watchingLink);
          final match2 =
              RegExp(r"var live_keywords = '(.*?)';").firstMatch(watchingLink);

          if (match != null && match2 != null) {
            try {
              final jsonString = match.group(1)!.replaceAll("'", '"');
              final streamData = json.decode(jsonString);
              final keywords = match2.group(1)!;
              // print('streamData is $streamData');
              episodesData.add({
                'streamUrls': streamData,
                'keywords': keywords,
              });
            } catch (error) {
              print('Error parsing JSON: $error');
              // Handle the error accordingly
            }
          }
        }
      });

      episodes.addAll(episodesData);

      // print('Episodes data: $episodes');
      final List<Episode> wallpapers =
          episodes.map((item) => Episode.fromJson(item)).toList();
      return wallpapers;
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}

class APITags {
  dynamic params;

  final imgHeaders = {'Accept': 'image/*', 'Accept-language': 'en'};
  APITags({this.params});

  Future<List<Tags>> fetchWallpapers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('baseUrl');
    String url = '$baseUrl/tags';
    // print(url);

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final document = htmlParser.parse(response.body);
      final List<Map<String, String>> tagsList = [];

      document.querySelectorAll('#main_tags .list li').forEach((element) {
        final title = element.querySelector('a')?.text;
        final id = element.querySelector('a')?.attributes['href'];

        tagsList.add({
          'title': title ?? '',
          'id': id ?? '',
        });
      });
      // final data = jsonDecode(response.body) as List<dynamic>;
      final List<Tags> wallpapers =
          tagsList.map((item) => Tags.fromJson(item)).toList();

      return wallpapers;
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}
