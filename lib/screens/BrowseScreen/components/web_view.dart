// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';

import '../../../global/globalFunctions.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({super.key, required this.url, required this.title});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool isLoading = false;
  late WebViewController controller = WebViewController()
    ..loadRequest(Uri.parse(widget.url))
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(Colors.white)
    ..setNavigationDelegate(NavigationDelegate(
      onPageFinished: (_) async {
        setState(
          () {
            isLoading = false;
          },
        );
        await removeAds();
      },
      onPageStarted: (_) async {
        setState(
          () {
            isLoading = true;
          },
        );
        await removeAds();
      },
      onNavigationRequest: (NavigationRequest request) {
        if (request.url.contains(widget.url)) {
          return NavigationDecision.navigate;
        } else {
          return NavigationDecision.prevent;
        }
      },
    ));

  Future<void> removeAds() async {
    await controller.runJavaScript('''

    var adClasses = ['ad-class', 'another-ad-class'];
    adClasses.forEach(function(className) {
      var ads = document.getElementsByClassName(className);
      for (var i = 0; i < ads.length; i++) {
        ads[i].style.display = 'none';
      }
    });


    var adIds = ['ad-id', 'another-ad-id'];
    adIds.forEach(function(id) {
      var ad = document.getElementById(id);
      if (ad != null) {
        ad.style.display = 'none';
      }
    });
  ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SMA().appBar(widget.title),
      body: WillPopScope(
        onWillPop: () async {
          if (await controller.canGoBack()) {
            // If there's a previous page, go back
            controller.goBack();
            return false; // Do not navigate back in Flutter stack
          }
          return true; // Allow navigating back in Flutter stack if no previous page
        },
        child: Stack(
          children: [
            WebViewWidget(
              controller: controller,
            ),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(), // Loader widget
              ),
          ],
        ),
      ),
    );
  }
}
