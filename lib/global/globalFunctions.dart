// ignore_for_file: file_names

import 'package:flutter/material.dart';

import 'api_helper.dart';
import 'constants.dart';

class ApiService {
  static const String baseUrl = 'https://lucious-api.vercel.app/api';

  static Future<dynamic> fetchData(
      BuildContext context, String endpoint) async {
    final response = await ApiHelper().getTypeGet(context, endpoint);
    // final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    return response;
  }
}

class SMA {
  static Future<dynamic> navigateTo(BuildContext context, dynamic page) {
    return Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => page,
      ),
    );
  }

  static Future<dynamic> forcedNavigateTo(BuildContext context, dynamic page) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => page,
      ),
    );
  }

  static void navigateBack(BuildContext context) {
    return Navigator.pop(context);
  }

  static void showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget appBar(
    String title,
  ) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: tWhite,
      foregroundColor: tPrimaryColor,
      shape: CustomShapeBorder(),
    );
  }
}

class CustomShapeBorder extends ContinuousRectangleBorder {
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    const double radius = 14.0;
    final Path path = Path();
    path.lineTo(0, rect.height - radius);
    path.quadraticBezierTo(0, rect.height, radius, rect.height);
    path.lineTo(rect.width - radius, rect.height);
    path.quadraticBezierTo(
        rect.width, rect.height, rect.width, rect.height - radius);
    path.lineTo(rect.width, 0);

    path.close();
    return path;
  }
}
