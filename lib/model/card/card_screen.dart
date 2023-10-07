// import 'dart:html';
// ignore_for_file: must_be_immutable, library_private_types_in_public_api

import 'package:appwrite/appwrite.dart';
import 'package:eroswatch/components/smallComponents/image_compoenent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:eroswatch/helper/videos.dart';
import 'package:eroswatch/Watch/video_player/mini_video_player.dart';

import '../../util/utils.dart';
import '../detail/detail_screen.dart';

class CardScreen extends StatefulWidget {
  final List<Videos> content;
  bool fav;

  CardScreen({
    Key? key,
    required this.content,
    this.fav = false,
  }) : super(key: key);

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  final ChromeSafariBrowser browser = ChromeSafariBrowser();
  List<Videos> favorites = [];
  bool changeOnTap = true;
  // final Map<int, bool> _isPlayingMap =
  late RealtimeSubscription subscribtion;
  int _currentPlayingIndex = -1;
  final database = ErosWatchDatabase(storageKey: 'videos');
  //     {};

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  text(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: Colors.black),
      ),
    );
  }

  late final String adLink1 =
      'https://alterassumeaggravate.com/vxzhm5ur2?key=67878f8f4b7b02dba995a675709106f1';

  @override
  Widget build(BuildContext context) {
    final filteredContent = widget.content
        .where((videos) => videos.title != '' && videos.title.isNotEmpty)
        .toList();
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: filteredContent.asMap().entries.map((entry) {
              final index = entry.key;
              final videos = entry.value;
              final isPlaying = index == _currentPlayingIndex;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          // AdCard()
                          DetailScreen(id: videos.id, title: videos.title),
                    ),
                  );
                  loadFavorites();
                },
                onHorizontalDragStart: (details) {
                  setState(() {
                    _currentPlayingIndex = index;
                  });
                },
                onHorizontalDragEnd: (details) {
                  _currentPlayingIndex = index;
                },
                child: SizedBox(
                  width: screenWidth <= 600 ? screenWidth : 250,
                  height: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(1.0),
                            child: Container(
                              height: 240,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 2.0),
                              width: screenWidth <= 600 ? screenWidth : 250,
                              child: videos.image.contains(adLink1)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: WebViewWidget(videos: videos),
                                    )
                                  : isPlaying
                                      ? CustomVideoPlayer(
                                          videoUrl: videos.preview,
                                          isShown: isPlaying ? true : false,
                                        )
                                      : ImageComponent(
                                          imagePath: videos.image,
                                          title: videos.title,
                                          time: videos.time,
                                          duration: videos.duration,
                                        ),
                            ),
                          ),
                          if (!videos.image.contains(adLink1))
                            Positioned(
                              bottom: 20,
                              right: 20,
                              child: GestureDetector(
                                onTap: () {
                                  toggleFavorite(videos);
                                },
                                child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(50000),
                                      color: Colors.black45,
                                    ),
                                    child: favorites
                                            .any((fav) => fav.id == videos.id)
                                        ? const Icon(
                                            Icons.favorite,
                                            color: Colors.red,
                                          )
                                        : const Icon(
                                            Icons.favorite,
                                            color: Colors.white,
                                          )),
                              ),
                            )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          text(videos.duration),
                          text(videos.time),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        child: Text(
                          videos.title,
                          style: const TextStyle(color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // void loadFavorites() async {
  //   final jsonStringList = await wallpaperStorage.getDataList();
  //   await wallpaperStorage.restoreData();
  //   setState(() {
  //     favorites = jsonStringList;
  //   });
  // }

  // Future<void> addToFavorites(Videos item) async {
  //   Videos videos = item;
  //   favorites.add(item);
  //   await wallpaperStorage.storeData(videos, context).then(
  //         (_) => loadFavorites(),
  //       );
  // }

  // Future<void> removeFromFavorites(id) async {
  //   await wallpaperStorage.removeData(id, context).then(
  //         (_) => loadFavorites(),
  //       );
  // }

  // void showRemoveDialog(BuildContext context, Videos item) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20.0),
  //         ),
  //         title:
  //             const Text("Warning..!!", style: TextStyle(color: Colors.blue)),
  //         content: const Text("Are you sure you want to remove this item?"),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               // Perform the remove action
  //               removeFromFavorites(item.id).then(
  //                 (_) => loadFavorites(),
  //               );
  //               Navigator.of(context)
  //                   .pop(true); // Return true to indicate remove
  //             },
  //             child: const Text("Remove", style: TextStyle(fontSize: 16.0)),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               // Cancel the remove action
  //               Navigator.of(context)
  //                   .pop(false); // Return false to indicate cancel
  //             },
  //             child: const Text("Cancel", style: TextStyle(fontSize: 16.0)),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void toggleFavorite(Videos item) {
  //   if (favorites.any((fav) => fav.id == item.id)) {
  //     // removeFromFavorites(image);
  //     showRemoveDialog(context, item);
  //     if (kDebugMode) {
  //       print("removed from favs");
  //     }
  //   } else {
  //     addToFavorites(item).then(
  //       (_) => loadFavorites(),
  //     );
  //     if (kDebugMode) {
  //       print("added to favs");
  //     }
  //   }
  // }
  void toggleFavorite(Videos item) {
    if (favorites.any((fav) => fav.id == item.id)) {
      showRemoveDialog(context, item);
      if (kDebugMode) {
        print("removed from favs");
      }
    } else {
      addToFavorites(item);
      if (kDebugMode) {
        print("added to favs");
      }
    }
  }

  void loadFavorites() async {
    try {
      final favoritesList = await database.getAllVideos();
      setState(() {
        favorites = favoritesList;
      });
    } catch (e) {
      // Handle the error, e.g., show an error message
      if (kDebugMode) {
        print("Error loading favorites: $e");
      }
    }
  }

  Future<void> addToFavorites(Videos item) async {
    try {
      await database.insertVideo(item).then((_) => loadFavorites());
      loadFavorites();
    } catch (e) {
      // Handle the error, e.g., show an error message
      if (kDebugMode) {
        print("Error adding to favorites: $e");
      }
    }
  }

  Future<void> removeFromFavorites(Videos item) async {
    try {
      await database.deleteVideo(item).then((_) => loadFavorites());
    } catch (e) {
      // Handle the error, e.g., show an error message
      if (kDebugMode) {
        print("Error removing from favorites: $e");
      }
    }
  }

  void showRemoveDialog(BuildContext context, Videos item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title:
              const Text("Warning..!!", style: TextStyle(color: Colors.blue)),
          content: const Text("Are you sure you want to remove this item?"),
          actions: [
            TextButton(
              onPressed: () {
                // Perform the remove action
                removeFromFavorites(item);
                Navigator.of(context)
                    .pop(true); // Return true to indicate remove
              },
              child: const Text("Remove", style: TextStyle(fontSize: 16.0)),
            ),
            TextButton(
              onPressed: () {
                // Cancel the remove action
                Navigator.of(context)
                    .pop(false); // Return false to indicate cancel
              },
              child: const Text("Cancel", style: TextStyle(fontSize: 16.0)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class WebViewWidget extends StatelessWidget {
  const WebViewWidget({
    super.key,
    required this.videos,
  });

  final Videos videos;

  @override
  Widget build(BuildContext context) {
    return const MyWebViewScreen();
//         InAppWebView(
//       initialUrlRequest: URLRequest(
//         url: Uri.parse(videos.image),
//         headers: {
//           'User-Agent ':
//               'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3',
//           'Accept': 'application/json',
//           'Accept-Encoding': 'gzip, deflate',
//         },
//         iosAllowsCellularAccess: true,
//         iosAllowsConstrainedNetworkAccess: true,
//         iosAllowsExpensiveNetworkAccess: true,
//         iosHttpShouldHandleCookies: true,
//       ),
// //
//       initialOptions: InAppWebViewGroupOptions(
//         crossPlatform: InAppWebViewOptions(
//           useOnDownloadStart: true,
//           javaScriptCanOpenWindowsAutomatically: true,
//         ),
//       ),
//     );
  }
}

class MyWebViewScreen extends StatefulWidget {
  const MyWebViewScreen({super.key});

  @override
  _MyWebViewScreenState createState() => _MyWebViewScreenState();
}

class _MyWebViewScreenState extends State<MyWebViewScreen> {
  InAppWebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    // String url = 'https://a.magsrv.com/iframe.php?idzone=5068348&size=300x250';
    return Scaffold(
      body: Container(
        color: Colors.black, // Set the background color to black
        child:
            // nextBool
            //     ? InAppWebView(
            //         initialUrlRequest: URLRequest(url: Uri.parse(url)),
            //         initialOptions: InAppWebViewGroupOptions(
            //           crossPlatform: InAppWebViewOptions(
            //             javaScriptEnabled: true,
            //           ),
            //         ),
            //         onLoadStop: (controller, url) {
            //           // Inject JavaScript to adjust the WebView size
            //           const script = '''
            //     var viewport = document.querySelector("meta[name=viewport]");
            //     if (!viewport) {
            //       viewport = document.createElement('meta');
            //       viewport.name = "viewport";
            //       document.head.appendChild(viewport);
            //     }
            //       viewport.content = "width=device-width, initial-scale=1.0";
            //   ''';
            //           controller.evaluateJavascript(source: script);
            //         },
            //       )
            //     :
            InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse('about:blank')),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              javaScriptEnabled: true,
            ),
          ),
          onLoadError: (controller, url, index, error) {
            if (kDebugMode) {
              print("Error loading $url: $error");
            }
          },
          // onLoadStart: (controller, url) {
          //   _webViewController = controller;
          //   _loadPopupAdCode();
          // },
          // onLoadStop: (controller, url) {
          //   _webViewController = controller;
          //   _loadPopupAdCode();
          // },
          onWebViewCreated: (controller) {
            _webViewController = controller;
            _loadPopupAdCode();
          },
        ),
      ),
    );
  }

  void _loadPopupAdCode() {
    const popupAdCode1 = '''

  <script type="application/javascript" src="https://a.magsrv.com/video-slider.js"></script>
<script type="application/javascript">
var adConfig = {
    "idzone": 5068084,
    "frequency_period": 1440,
    "close_after": 4,
    "on_complete": "repeat",
    "screen_density": 30,
    "cta_enabled": 1
};
VideoSlider.init(adConfig);
</script>

<script async type="application/javascript" src="https://a.magsrv.com/ad-provider.js"></script> 
 <ins class="eas6a97888e" data-zoneid="5067006" data-keywords="keywords" data-sub="123450000"></ins> 
 <script>(AdProvider = window.AdProvider || []).push({"serve": {}});</script>

 <script async type="application/javascript" src="https://a.magsrv.com/ad-provider.js"></script> 
 <ins class="eas6a97888e" data-zoneid="5067090" data-keywords="keywords" data-sub="123450000"></ins> 
 <script>(AdProvider = window.AdProvider || []).push({"serve": {}});</script>

 <script async type="application/javascript" src="https://a.magsrv.com/ad-provider.js"></script> 
 <ins class="eas6a97888e" data-zoneid="5067098" data-keywords="keywords" data-sub="123450000"></ins> 
 <script>(AdProvider = window.AdProvider || []).push({"serve": {}});</script>
 
<script async type="application/javascript" src="https://a.magsrv.com/ad-provider.js"></script> 
 <ins class="eas6a97888e" data-zoneid="5067384"></ins> 
 <script>(AdProvider = window.AdProvider || []).push({"serve": {}});</script>
 
<script type="application/javascript" 
data-idzone="5067406"  data-ad_frequency_count="30"  data-ad_frequency_period="5"  data-type="mobile" 
data-browser_settings="1" 
data-ad_trigger_method="3" 

src="https://a.pemsrv.com/fp-interstitial.js"></script>
<script type="application/javascript" src="https://a.magsrv.com/video-slider.js"></script>
<script type="application/javascript">
var adConfig = {
    "idzone": 5068084,
    "frequency_period": 1440,
    "close_after": 4,
    "on_complete": "repeat",
    "screen_density": 30,
    "cta_enabled": 1
};
VideoSlider.init(adConfig);
</script>

    ''';
//     const popupAdCode2 = '''
//   <script async type="application/javascript" src="https://a.magsrv.com/ad-provider.js"></script>
//  <ins class="eas6a97888e" data-zoneid="5067098" data-keywords="keywords" data-sub="123450000"></ins>
//  <script>(AdProvider = window.AdProvider || []).push({"serve": {}});</script>
// <script async type="application/javascript" src="https://a.magsrv.com/ad-provider.js"></script>
//  <ins class="eas6a97888e" data-zoneid="5067006" data-keywords="keywords" data-sub="123450000"></ins>
//  <script>(AdProvider = window.AdProvider || []).push({"serve": {}});</script>
//  <script async type="application/javascript" src="https://a.magsrv.com/ad-provider.js"></script>
//  <ins class="eas6a97888e" data-zoneid="5067090" data-keywords="keywords" data-sub="123450000"></ins>
//  <script>(AdProvider = window.AdProvider || []).push({"serve": {}});</script>
//     ''';
//     const popupAdCode3 = '''

// <script type="application/javascript"
// data-idzone="5067406"  data-ad_frequency_count="30"  data-ad_frequency_period="5"  data-type="mobile"
// data-browser_settings="1"
// data-ad_trigger_method="3"

// src="https://a.pemsrv.com/fp-interstitial.js"></script>
// <script async type="application/javascript" src="https://a.magsrv.com/ad-provider.js"></script>
//  <ins class="eas6a97888e" data-zoneid="5067006" data-keywords="keywords" data-sub="123450000"></ins>
//  <script>(AdProvider = window.AdProvider || []).push({"serve": {}});</script>
//  <script async type="application/javascript" src="https://a.magsrv.com/ad-provider.js"></script>
//  <ins class="eas6a97888e" data-zoneid="5067090" data-keywords="keywords" data-sub="123450000"></ins>
//  <script>(AdProvider = window.AdProvider || []).push({"serve": {}});</script>
//     ''';
//     const popupAdCode4 = '''

// <script type="application/javascript">
//     var ad_idzone = "5068082",
//     ad_popup_fallback = false,
//     ad_popup_force = true,
//     ad_chrome_enabled = true,
//     ad_new_tab = false,
//     ad_frequency_period = 5,
//     ad_frequency_count = 3,
//     ad_trigger_method = 3,
//     ad_trigger_delay = 0;
// </script>
// <script type="application/javascript" src="https://a.pemsrv.com/popunder1000.js"></script>
// <script async type="application/javascript" src="https://a.magsrv.com/ad-provider.js"></script>
//  <ins class="eas6a97888e" data-zoneid="5067006" data-keywords="keywords" data-sub="123450000"></ins>
//  <script>(AdProvider = window.AdProvider || []).push({"serve": {}});</script>
//  <script async type="application/javascript" src="https://a.magsrv.com/ad-provider.js"></script>
//  <ins class="eas6a97888e" data-zoneid="5067090" data-keywords="keywords" data-sub="123450000"></ins>
//  <script>(AdProvider = window.AdProvider || []).push({"serve": {}});</script>
//     ''';

    // final int randomIndex = Random().nextInt(5);
    // late String selectedPopupAdCode;
    // print(randomIndex);
    // switch (randomIndex) {
    //   case 0:
    //     setState(() {
    //       selectedPopupAdCode = popupAdCode1;
    //     });
    //     break;
    //   case 1:
    //     setState(() {
    //       selectedPopupAdCode = popupAdCode2;
    //     });
    //     break;
    //   case 3:
    //     setState(() {
    //       selectedPopupAdCode = popupAdCode3;
    //     });
    //     break;
    //   case 4:
    //     setState(() {
    //       selectedPopupAdCode = popupAdCode4;
    //     });
    //     break;
    //   default:
    //     setState(() {
    //       selectedPopupAdCode = popupAdCode1;
    //     });
    //     break;
    // }
    _webViewController?.loadData(
      data: popupAdCode1,
      mimeType: 'text/html',
      encoding: 'utf-8',
    );
  }
}

class MyObject {
  final String name;
  final int age;

  MyObject(this.name, this.age);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
    };
  }

  factory MyObject.fromJson(Map<String, dynamic> json) {
    return MyObject(
      json['name'],
      json['age'],
    );
  }
}
