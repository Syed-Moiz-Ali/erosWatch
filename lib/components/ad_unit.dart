import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:url_launcher/url_launcher.dart';

final Uri _url = Uri.parse(
    'https://alterassumeaggravate.com/k7idg1w309?key=4fd88d34214c0b3f55a623c70791caaa');

class AdCard extends StatelessWidget {
  AdCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Automatically open the ad link as soon as the widget is built

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Advertisement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomWebView(
                        url:
                            'https://alterassumeaggravate.com/k7idg1w309?key=4fd88d34214c0b3f55a623c70791caaa'),
                  ),
                );
              },
              child: const Text('Open Ad Link'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _launchUrl() async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}

class CustomWebView extends StatelessWidget {
  final String url;

  CustomWebView({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Web View'),
      ),
      body: Center(
        child: Container(
          width: 300,
          height: 300,
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: Uri.parse(url)),
          ),
        ),
      ),
    );
  }
}
