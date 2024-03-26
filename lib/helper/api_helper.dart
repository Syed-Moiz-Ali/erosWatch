// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_typing_uninitialized_variables, library_prefixes, depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as htmlDom;

import '../global/globalFunctions.dart';

class ApiHelper {
  // static const String baseUrl = "https://hdqwalls.com/";

  // static Future<List<Map<String, dynamic>>> fetchData(String url) async {
  //   final response = await http.get(Uri.parse(url));
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body).cast<Map<String, dynamic>>();
  //   } else {
  //     throw Exception('Failed to load wallpapers');
  //   }
  // }
  static Future<T> fetchData<T>(
      String url, T Function(htmlDom.Document) model) async {
    final response = await http.get(Uri.parse(url));
    // print('response is ${response.body}');
    if (response.statusCode == 200) {
      final document = htmlParser.parse(response.body);
      return model(document);
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }

  getTypeGet(BuildContext context, String uri) async {
    var client = http.Client();
    var jsonMap;
    try {
      var response = await client.get(Uri.parse(uri));
      print(response.statusCode);
      print(uri);
      if (response.statusCode == 200) {
        var jsonString = response.body;
        // print(jsonString);
        jsonMap = json.decode(jsonString);

        return jsonMap;
      } else {
        SMA.showAlert(context, response.body.toString());
        print(uri);
      }
    } on SocketException {
      print("error");
      throw ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Check Internet'),
      ));
    } catch (e) {
      print(e);
      return jsonMap;
    }
  }
}
