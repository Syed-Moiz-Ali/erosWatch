import 'package:flutter/foundation.dart';

class BottomNavigatorProvider extends ChangeNotifier {
  int pageIndex = 0;

  setPageIndex(val) {
    pageIndex = val;
    notifyListeners();
  }

  int mainPageIndex = 0;

  setmainPageIndex(val) {
    pageIndex = val;
    notifyListeners();
  }
}
