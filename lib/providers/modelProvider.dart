import 'package:flutter/material.dart';
import 'package:html/dom.dart' as htmlDom;

class ModelProvider<T> extends ChangeNotifier {
  String baseUrl = '';
  late T model;

  setServer({
    required T model,
    required String baseUrl,
  }) {
    this.baseUrl = baseUrl;
    this.model = model;
    notifyListeners();
  }

  late List<T> Function(htmlDom.Document) innerFun;
  setServerInner({required List<T> Function(htmlDom.Document) innerFun}) {
    this.innerFun = innerFun;
    notifyListeners();
  }
}
