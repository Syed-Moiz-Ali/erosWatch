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
  final String name;
  final String description;
  final String thumbnailUrl;
  final String image;
  final String embedUrl;
  final String contentUrl;
  final String keywords;

  Episode({
    required this.name,
    required this.description,
    required this.thumbnailUrl,
    required this.image,
    required this.embedUrl,
    required this.contentUrl,
    required this.keywords,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      image: json['image'] ?? '',
      embedUrl: json['embedUrl'] ?? '',
      contentUrl: json['contentUrl'] ?? '',
      keywords: json['keywords'] ?? '',
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
