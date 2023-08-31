import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class VideoPlayerWithAdsScreen extends StatefulWidget {
  const VideoPlayerWithAdsScreen({super.key});

  @override
  _VideoPlayerWithAdsScreenState createState() =>
      _VideoPlayerWithAdsScreenState();
}

class _VideoPlayerWithAdsScreenState extends State<VideoPlayerWithAdsScreen> {
  late VideoPlayerController _videoController;
  bool _showAdOverlay = false;
  late String vastAdTagUri;

  Future<void> _fetchAndParseVastXml() async {
    // Fetch VAST XML using http package
    final response = await http.get(Uri.parse(vastAdTagUri));

    if (response.statusCode == 200) {
      final xmlDocument = xml.XmlDocument.parse(response.body);

      // Parse XML and extract ad information
      // For simplicity, assume you have a function to extract ad information
      final adInfo = extractAdInfoFromXml(xmlDocument);

      if (adInfo != null) {
        setState(() {
          _showAdOverlay = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.network('YOUR_VIDEO_URL_HERE')
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();
        _fetchAndParseVastXml(); // Fetch and parse VAST XML when video initializes
      });

    vastAdTagUri =
        'https://go.xlivrdr.com/smartpop/165aea9bcdd7aabac45f72d02f58fd24b8416bc57cfc540b1b4409ac823564af?userId=1f2ad638bb163e0f21b19d6cbbcd5805b56eb7b1ef21117b6157eaf2a11915c9&memberId=ooc7sGzqpa7KLKXWT1S011Wulc6aet1Mzp3UyuldK6V1FFc1091bpp6qbLbXTT13W00OldM6V0rpXSumdK6V0znOlc5zpXSuldK6V0rpXSuldNXdRTZPNNU4PsA-&sourceId=5067374&p1=5085118&skipOffset=00:00:05';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player with Ads'),
      ),
      body: Column(
        children: [
          // Video player widget
          _videoController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                )
              : CircularProgressIndicator(),
          // Ad overlay widget
          if (_showAdOverlay) AdOverlayWidget(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }
}

class AdOverlayWidget extends StatelessWidget {
  const AdOverlayWidget({super.key});

  // Implement the ad overlay widget
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Text(
          'Ad Overlay',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

// Replace this with your actual ad parsing logic
Map<String, dynamic>? extractAdInfoFromXml(xml.XmlDocument xmlDocument) {
  // Implement the extraction logic based on the XML structure
  return null;
}
