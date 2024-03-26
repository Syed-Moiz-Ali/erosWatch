import 'dart:convert';
import 'dart:developer';

import 'package:html/dom.dart' as html;

class VideoItem {
  final String title;
  final String id;
  final String dataId;
  final String image;
  final String preview;
  final String duration;
  final String quality;
  final String percentage;
  final String views;
  final String time;

  VideoItem({
    this.title = '',
    this.id = '',
    this.dataId = '',
    this.image = '',
    this.preview = '',
    this.duration = '',
    this.quality = '',
    this.percentage = '',
    this.views = '',
    this.time = '',
  });
  // static List<VideoItem> fromDocument(html.Document document) {
  //   final elements =
  //       document.querySelectorAll('.video-list-with-ads > .video-item');

  //   return elements.map((element) => VideoItem.fromElement(element)).toList();
  // }

  factory VideoItem.fromElement(html.Element element) {
    final title = element.querySelector('.n')?.text ?? '';
    final id = element.querySelector('.thumb')?.attributes['href'] ?? '';
    final dataId = element.attributes['data-id'] ?? '';
    final image = element
            .querySelector('.thumb > picture > img')
            ?.attributes['data-src'] ??
        '';
    final preview = element
            .querySelector('.thumb > picture > img')
            ?.attributes['data-preview'] ??
        '';
    final duration = element.querySelector('.thumb > .t > .l')?.text ?? '';
    final quality = element.querySelector('.thumb > .t > .h')?.text ?? '';
    final percentage = element.querySelector('.stats > .d')?.text ?? '';
    final views = element.querySelector('.stats > .v')?.text ?? '';
    final time = element.querySelector('.stats > .v')?.text ?? '';

    return VideoItem(
      title: title,
      id: id,
      dataId: dataId,
      image: image,
      preview: preview,
      duration: duration,
      quality: quality,
      percentage: percentage,
      views: views,
      time: time,
    );
  }
  factory VideoItem.fromMap(Map<String, dynamic> map) {
    return VideoItem(
      id: map['id'],
      image: map['image'],
      title: map['title'],
      preview: map['preview'],
      duration: map['duration'],
      quality: map['quality'],
      time: map['time'],
    );
  }
  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'] ?? "",
      image: json['image'] ?? "",
      title: json['title'] ?? "",
      preview: json['preview'] ?? "",
      duration: json['duration'] ?? "",
      quality: json['quality'] ?? "",
      time: json['time'] ?? "",
    );
  }
  String toJsonString() {
    final Map<String, dynamic> jsonData = {
      'id': id,
      'image': image,
      'title': title,
      'preview': preview,
      'duration': duration,
      'quality': quality,
      'time': time,
    };

    return jsonEncode(jsonData);
  }
}

class Category {
  final String title;
  final String id;
  final String image;

  Category({
    required this.title,
    required this.id,
    required this.image,
  });
  // static List<Category> fromDocument(html.Document document) {
  //   final elements =
  //       document.querySelectorAll('#container > #browse > .categories > a');

  //   return elements.map((element) => Category.fromElement(element)).toList();
  // }

  factory Category.fromElement(html.Element element) {
    final title = element.querySelector('span')?.text ?? '';
    final id = element.attributes['href'] ?? '';
    final image = element.querySelector('img')?.attributes['src'] ?? '';

    return Category(
      title: title,
      id: id,
      image: image,
    );
  }
}

class Channel {
  final String image;
  final String title;
  final String id;

  Channel({
    required this.image,
    required this.title,
    required this.id,
  });
  // static List<Channels> fromDocument(html.Document document) {
  //   final elements = document.querySelectorAll('.results > li');

  //   return elements.map((element) => Channels.fromElement(element)).toList();
  // }

  factory Channel.fromElement(html.Element element) {
    final image =
        element.querySelector('.image > img')?.attributes['src'] ?? '';
    final title = element.querySelector('.title')?.text ?? '';
    final id = element.querySelector('.image')?.attributes['href'] ?? '';

    return Channel(
      image: image,
      title: title,
      id: id,
    );
  }
}

class ChannelDetails {
  final String channelTitle;
  final String channelImg;
  final String channelLink;
  final String parentChannelTitle;
  final String parentChannelLink;

  ChannelDetails({
    required this.channelTitle,
    required this.channelImg,
    required this.channelLink,
    required this.parentChannelTitle,
    required this.parentChannelLink,
  });

  // static List<ChannelDetails> fromDocument(html.Document document) {
  //   final elements =
  //       document.querySelectorAll('.video-list-with-ads > .video-item');

  //   return elements
  //       .map((element) => ChannelDetails.fromElement(element))
  //       .toList();
  // }

  factory ChannelDetails.fromElement(html.Element topElement) {
    final channelTitle =
        topElement.querySelector('.p > img')?.attributes['alt'] ?? '';
    final channelImg =
        topElement.querySelector('.p > img')?.attributes['src'] ?? '';
    final channelLink =
        topElement.querySelector('.i > h1 > a')?.attributes['href'] ?? '';
    final parentChannelTitle =
        topElement.querySelector('.i > .parent > a')?.text ?? '';
    final parentChannelLink =
        topElement.querySelector('.i > .parent > a')?.attributes['href'] ?? '';

    return ChannelDetails(
      channelTitle: channelTitle,
      channelImg: channelImg,
      channelLink: channelLink,
      parentChannelTitle: parentChannelTitle,
      parentChannelLink: parentChannelLink,
    );
  }
}

class Star {
  final String image;
  final String starName;
  final String id;
  final String views;
  final String videos;

  Star({
    required this.image,
    required this.starName,
    required this.id,
    required this.views,
    required this.videos,
  });

  // static List<Star> fromDocument(html.Document document) {
  //   final elements = document.querySelectorAll('#pornstars > .results > li');

  //   return elements.map((element) => Star.fromElement(element)).toList();
  // }

  factory Star.fromElement(html.Element element) {
    final image =
        element.querySelector(".image > img")?.attributes['src'] ?? '';
    final starName = element.querySelector(".title")?.text ?? '';
    final id = element.querySelector(".title")?.attributes['href'] ?? '';
    final views = element.querySelector(".image > .views")?.text ?? '';
    final videos = element.querySelector(".image > .videos")?.text ?? '';

    return Star(
      image: image,
      starName: starName,
      id: id,
      views: views,
      videos: videos,
    );
  }
}

class StarDetail {
  final String title;
  final String img;
  final String views;
  final String videos;
  final String age;
  final String from;
  final String color;
  final String hair;
  final String height;
  final String weight;

  StarDetail({
    required this.title,
    required this.img,
    required this.views,
    required this.videos,
    required this.age,
    required this.from,
    required this.color,
    required this.hair,
    required this.height,
    required this.weight,
  });

  // static List<StarDetail> fromDocument(html.Document document) {
  //   final elements = document.querySelectorAll('body');

  //   return elements.map((element) => StarDetail.fromElement(element)).toList();
  // }

  factory StarDetail.fromElement(html.Element element) {
    final title =
        element.querySelector(".top > .p > img")?.attributes['alt'] ?? '';
    final img =
        element.querySelector(".top > .p > img")?.attributes['src'] ?? '';
    final views = element
            .querySelector(".top > .i > p > span:nth-child(1)")
            ?.text
            .replaceFirst("Views:", "") ??
        '';
    final videos = element
            .querySelector(".top > .i > p > span:nth-child(2)")
            ?.text
            .replaceFirst("Videos:", "") ??
        '';
    final age = element
            .querySelector(".top > .i > p > span:nth-child(3)")
            ?.text
            .replaceFirst("Age:", "") ??
        '';
    final from = element
            .querySelector(".top > .i > p > span:nth-child(4)")
            ?.text
            .replaceFirst("From:", "") ??
        '';
    final color = element
            .querySelector(".top > .i > p > span:nth-child(5)")
            ?.text
            .replaceFirst("Color:", "") ??
        '';
    final hair = element
            .querySelector(".top > .i > p > span:nth-child(6)")
            ?.text
            .replaceFirst("Hair:", "") ??
        '';
    final height = element
            .querySelector(".top > .i > p > span:nth-child(7)")
            ?.text
            .replaceFirst("Height:", "") ??
        '';
    final weight = element
            .querySelector(".top > .i > p > span:nth-child(8)")
            ?.text
            .replaceFirst("Weight:", "") ??
        '';

    return StarDetail(
      title: title,
      img: img,
      views: views,
      videos: videos,
      age: age,
      from: from,
      color: color,
      hair: hair,
      height: height,
      weight: weight,
    );
  }
}

class StreamData {
  final Map<String, dynamic> streamUrls;
  final String keywords;

  StreamData({
    required this.streamUrls,
    required this.keywords,
  });
  // static List<StreamData> fromDocument(html.Document document) {
  //   final elements = document.querySelectorAll('#container');

  //   return elements.map((element) => StreamData.fromElement(element)).toList();
  // }

  factory StreamData.fromElement(html.Element element) {
    final watchingLink =
        element.querySelector('script[type="text/javascript"]')!.innerHtml;

    log('watchingLink is ${watchingLink.toString()}');
    if (watchingLink != null) {
      final match =
          RegExp(r'var stream_data = ({.*?});').firstMatch(watchingLink);
      final match2 =
          RegExp(r"var live_keywords = '(.*?)';").firstMatch(watchingLink);

      if (match != null && match2 != null) {
        final jsonString = match[1]!.replaceAll("'", '"');
        final streamDataJson = json.decode(jsonString);

        // final streamDataJson = match.group(1)?.replaceAll("'", '"') ?? '';
        final streamUrls = Map<String, dynamic>.from(streamDataJson);
        final keywords = match2.group(1) ?? '';

        return StreamData(streamUrls: streamUrls, keywords: keywords);
      }
    }

    return StreamData(streamUrls: {}, keywords: '');
  }
}

class Spankbang {
  List parseVideoItems(html.Document document) {
    final elements = document.querySelectorAll('.video-list > .video-item');

    return elements.map((element) => VideoItem.fromElement(element)).toList();
  }

  List<Category> parseCategories(html.Document document) {
    final elements =
        document.querySelectorAll('#container > #browse > .categories > a');

    return elements.map((element) => Category.fromElement(element)).toList();
  }

  List<Channel> parseChannels(html.Document document) {
    final elements = document.querySelectorAll('.results > li');

    return elements.map((element) => Channel.fromElement(element)).toList();
  }

  List<ChannelDetails> parseChannelDetails(html.Document document) {
    final elements =
        document.querySelectorAll('.video-list-with-ads > .video-item');

    return elements
        .map((element) => ChannelDetails.fromElement(element))
        .toList();
  }

  List<Star> parseStars(html.Document document) {
    final elements = document.querySelectorAll('#pornstars > .results > li');

    return elements.map((element) => Star.fromElement(element)).toList();
  }

  List<StarDetail> parseStarDetails(html.Document document) {
    final elements = document.querySelectorAll('body');

    return elements.map((element) => StarDetail.fromElement(element)).toList();
  }

  List<StreamData> parseStreamData(html.Document document) {
    final elements = document.querySelectorAll('#container');

    return elements.map((element) => StreamData.fromElement(element)).toList();
  }
}

class SpankbangBaseUrls {
  String buildUrl(String baseUrl, String params, int pageNo,
      String newParamForStarAndChannel, String queryParams, String id) {
    if (id != '') {
      return buildUrlWithId(
          baseUrl, params, pageNo, newParamForStarAndChannel, queryParams);
    } else if (params == "popular_videos") {
      return buildUrlForPopularVideos(baseUrl, params, pageNo, queryParams);
    } else if (params.contains('similar')) {
      return buildUrlForSimilar(baseUrl, params);
    } else {
      return buildUrlForDefault(baseUrl, params, pageNo, queryParams);
    }
  }

  String buildUrlWithId(String baseUrl, String params, int pageNo,
      String newParamForStarAndChannel, String queryParams) {
    return '$baseUrl$params${pageNo != 1 ? '$pageNo' : ''}?$newParamForStarAndChannel$queryParams';
  }

  String buildUrlForPopularVideos(
      String baseUrl, String params, int pageNo, String queryParams) {
    return '$baseUrl/$params${pageNo != 1 ? '/$pageNo' : ''}$queryParams';
  }

  String buildUrlForSimilar(String baseUrl, String params) {
    return '$baseUrl/${params.replaceAll('similar/', '')}';
  }

  String buildUrlForDefault(
      String baseUrl, String params, int pageNo, String queryParams) {
    return '$baseUrl/$params${pageNo != 1 ? '/$pageNo' : ''}$queryParams';
  }
}
