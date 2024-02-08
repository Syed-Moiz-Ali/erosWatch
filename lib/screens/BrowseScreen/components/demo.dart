// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:eroswatch/global/globalFunctions.dart';
import 'package:eroswatch/model/mainScreen/mainScreen.dart';
import 'package:eroswatch/providers/bottom_navigator_provider.dart';
import 'package:eroswatch/providers/cardProvider.dart';
import 'package:eroswatch/screens/BrowseScreen/browse_screen.dart';
import 'package:eroswatch/screens/BrowseScreen/components/web_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as htmlDom;

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List extractedData = [];
  String htmlContent = '';
  String url = '';
  String title = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var provider = Provider.of<CardProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      url = prefs.getString('baseUrl')!;
      title = prefs.getString('title')!;
    });

    try {
      extractedData.clear();
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = htmlParser.parse(response.body);

        // Extract the entire HTML content
        String html = document.outerHtml;

        setState(() {
          extractedData.add(html);
          htmlContent = html;
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<CardProvider>(context, listen: false);
    var bottomProvider =
        Provider.of<BottomNavigatorProvider>(context, listen: false);
    print('the url is ${provider.url}');
    return Scaffold(
      body: WebViewScreen(url: url, title: title),
      // SingleChildScrollView(
      //   child: Padding(
      //     padding: const EdgeInsets.all(8.0),
      //     child: Html(
      //       data: htmlContent,
      //       onLinkTap: (url, attributes, element) async {
      //         String link =
      //             url!.contains(provider.url) ? url : '${provider.url}$url';
      //         if (link.contains('://')) {
      //           setState(() {
      //             link = link.replaceAll('${provider.url}/', provider.url);
      //           });
      //         }
      //         await provider.setUrl(link);
      //         await bottomProvider.setmainPageIndex(2);
      //         await SMA.forcedNavigateTo(context, MainScreen());
      //       },
      //       style: {
      //         'body': Style(
      //           fontSize: FontSize(16.0),
      //           fontFamily: 'Arial',
      //           color: Colors.black,
      //         ),
      //         'a': Style(
      //           textDecoration: TextDecoration.underline,
      //           color: Colors.black,
      //         ),
      //         'h1': Style(
      //           fontSize: FontSize(24.0),
      //           fontWeight: FontWeight.bold,
      //           color: Colors.black,
      //         ),
      //         'h2': Style(
      //           fontSize: FontSize(20.0),
      //           fontWeight: FontWeight.bold,
      //           color: Colors.black,
      //         ),
      //         'div': Style(
      //           margin: Margins.symmetric(vertical: 8.0),
      //         ),
      //         // Add more custom styles for other tags as needed

      //         // Add more custom styles as needed
      //       },
      //     ),
      //   ),
      // ),
    );
  }
}
