import 'dart:convert';

class Videos {
  final String id;
  final String image;
  final String title;
  final String preview;
  final String duration;
  final String quality;
  final String time;

  Videos({
    required this.id,
    required this.image,
    required this.title,
    required this.preview,
    required this.duration,
    required this.quality,
    required this.time,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'preview': preview,
      'duration': duration,
      'quality': quality,
      'time': time,
    };
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

  Map<String, dynamic> toMap() {
    return {
      'id': id.toString(),
      'image': image.toString(),
      'title': title.toString(),
      'preview': preview.toString(),
      'duration': duration.toString(),
      'quality': quality.toString(),
      'time': time.toString(),
    };
  }

  factory Videos.fromMap(Map<String, dynamic> map) {
    return Videos(
      id: map['id'],
      image: map['image'],
      title: map['title'],
      preview: map['preview'],
      duration: map['duration'],
      quality: map['quality'],
      time: map['time'],
    );
  }
  factory Videos.fromJson(Map<String, dynamic> json) {
    return Videos(
      id: json['id'] ?? "",
      image: json['image'] ?? "",
      title: json['title'] ?? "",
      preview: json['preview'] ?? "",
      duration: json['duration'] ?? "",
      quality: json['quality'] ?? "",
      time: json['time'] ?? "",
    );
  }
}

class Episode {
  final String keywords;
  final Map<String, dynamic> streamUrls;

  Episode({required this.keywords, required this.streamUrls});

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      keywords: json['keywords'] ?? '',
      streamUrls: Map<String, dynamic>.from(json['streamUrls'] ?? {}),
    );
  }
}

class VideoTags {
  final String tagId;
  final String tagTitle;

  VideoTags({
    required this.tagId,
    required this.tagTitle,
  });

  factory VideoTags.fromJson(Map<String, dynamic> json) {
    return VideoTags(
      tagId: json['tagId'] ?? '',
      tagTitle: json['tagTitle'] ?? '',
    );
  }
}

class Stars {
  final String id;
  final String starName;
  final String image;
  final String views;
  final String videos;

  Stars({
    required this.id,
    required this.starName,
    required this.image,
    required this.views,
    required this.videos,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'starName': starName,
      'image': image,
      'views': views,
      'videos': videos,
    };
  }

  String toJsonString() {
    final Map<String, dynamic> jsonData = {
      'id': id,
      'starName': starName,
      'image': image,
      'views': views,
      'videos': videos,
    };

    return jsonEncode(jsonData);
  }

  factory Stars.fromJson(Map<String, dynamic> json) {
    return Stars(
      id: json['id'] ?? '',
      starName: json['starName'] ?? '',
      image: json['image'] ?? '',
      views: json['views'] ?? '',
      videos: json['videos'] ?? '',
    );
  }
}

class StarsDetails {
  final String starTitle;
  final String starImg;
  final String starViews;
  final String starVideos;
  final String starAge;
  final String starColor;
  final String starFrom;
  final String starHair;
  final String starHeight;
  final String starWeight;

  StarsDetails({
    required this.starTitle,
    required this.starImg,
    required this.starViews,
    required this.starVideos,
    required this.starAge,
    required this.starFrom,
    required this.starColor,
    required this.starHair,
    required this.starHeight,
    required this.starWeight,
  });

  factory StarsDetails.fromJson(Map<String, dynamic> json) {
    return StarsDetails(
      starTitle: json['starTitle'] ?? '',
      starImg: json['starImg'] ?? '',
      starViews: json['starViews'] ?? '',
      starVideos: json['starVideos'] ?? '',
      starAge: json['starAge'] ?? '',
      starFrom: json['starFrom'] ?? '',
      starColor: json['starColor'] ?? '',
      starHair: json['starHair'] ?? '',
      starHeight: json['starHeight'] ?? '',
      starWeight: json['starWeight'] ?? '',
    );
  }
}

class Channels {
  final String id;
  final String title;
  final String image;

  Channels({
    required this.id,
    required this.title,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
    };
  }

  String toJsonString() {
    final Map<String, dynamic> jsonData = {
      'id': id,
      'title': title,
      'image': image,
    };

    return jsonEncode(jsonData);
  }

  factory Channels.fromJson(Map<String, dynamic> json) {
    return Channels(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class Categories {
  final String id;
  final String starName;
  final String image;
  final String views;
  final String videos;

  Categories({
    required this.id,
    required this.starName,
    required this.image,
    required this.views,
    required this.videos,
  });

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      id: json['id'] ?? '',
      starName: json['starName'] ?? '',
      image: json['image'] ?? '',
      views: json['views'] ?? '',
      videos: json['videos'] ?? '',
    );
  }
}

class Tags {
  final String id;
  final String title;

  Tags({
    required this.id,
    required this.title,
  });

  factory Tags.fromJson(Map<String, dynamic> json) {
    return Tags(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
    );
  }
}

class ImageData {
  final String imageUrl;
  final String title;

  ImageData({required this.imageUrl, required this.title});
}

class VideoUrls {
  final String thumbnail;
  final String keywords;
  final String link240p;
  final String link360p;
  final String link480p;
  final String link720p;
  final String link1080p;
  final String fourk;
  final String main;
  final String m3u8;

  VideoUrls({
    required this.thumbnail,
    required this.keywords,
    required this.link240p,
    required this.link360p,
    required this.link480p,
    required this.link720p,
    required this.link1080p,
    required this.fourk,
    required this.main,
    required this.m3u8,
  });
}
