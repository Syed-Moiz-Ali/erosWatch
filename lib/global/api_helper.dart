// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'globalFunctions.dart';

class ApiHelper {
  //All Post type request will handle here

  //All Get type request will handle here
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
