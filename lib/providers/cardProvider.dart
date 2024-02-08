// ignore_for_file: file_names

import 'package:flutter/foundation.dart';

class CardProvider extends ChangeNotifier {
  String url = '';
  setUrl(val) {
    url = val;
    notifyListeners();
  }

  String selectedScreenName = 'Trending';
  setSelectedScreenName(val) {
    selectedScreenName = val;
    notifyListeners();
  }

  String selectedChannelName = 'Popular';
  setSelectedChannelName(val) {
    selectedChannelName = val;
    notifyListeners();
  }

  dynamic videosLength;
  dynamic channelsLength;
  dynamic starsLength;
  String libraryType = '';
  bool isLoading = true;
  setTotalLength(val, String type) {
    libraryType = type;
    if (type.contains('video')) {
      videosLength = val;
    } else if (type.contains('channel')) {
      channelsLength = val;
    } else if (type.contains('star')) {
      starsLength = val;
    }
    isLoading = false;
    notifyListeners();
  }
}
