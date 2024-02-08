import 'package:flutter/foundation.dart';

class BottomNavigatorProvider extends ChangeNotifier {
  int pageIndex = 0;

  setPageIndex(val) {
    pageIndex = val;
    notifyListeners();
  }

  int mainPageIndex = 0;

  setmainPageIndex(val) {
    mainPageIndex = val;
    notifyListeners();
  }

  List mainPreviousPagesHistory = [];
  setMainPreviousPagesHistory(val) {
    mainPreviousPagesHistory.add(val);
    notifyListeners();
  }

  List previousPagesHistory = [];
  setPreviousPagesHistory(val) {
    previousPagesHistory.add(val);
    notifyListeners();
  }
}
