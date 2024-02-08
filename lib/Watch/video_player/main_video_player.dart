// ignore_for_file: must_be_immutable, library_private_types_in_public_api, depend_on_referenced_packages, use_build_context_synchronously, avoid_print

import 'dart:async';
import 'dart:io';
import 'package:eroswatch/helper/videos.dart';
import 'package:eroswatch/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eroswatch/Watch/smiliar.dart';
import 'package:eroswatch/Watch/video_player/video_player_controls.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
// import 'package:volume_controller/volume_controller.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:auto_orientation/auto_orientation.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen(
      {super.key,
      required this.videoUrls,
      required this.id,
      required this.title});

  final String id;
  final String title;
  final VideoUrls videoUrls;

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

enum SeekDirection {
  none,
  forward,
  backward,
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with TickerProviderStateMixin {
  final ChromeSafariBrowser browser = ChromeSafariBrowser();
  // double _initialVolumeDrag = 0; // Initial position of vertical drag
  // double _initialVolume = 0; // Initial volume value
  double currentVolume = 0;
  String gifUrl = '';

  int currentHeightFactorIndex = 0;
  int currentWidthFactorIndex = 0;
  List<double> heightFactorValues = [
    1.0,
    1.2,
  ];

  List<double> widthFactorValues = [
    1.0,
    1.2,
  ];
  bool isSliderVisible = false; // Initial visibility state
  double maxSpeed = 3.0;
  String nonLinearClickThroughUrl = '';
  late double playbackSpeed;
  late String? selectedLink;
  late String selectedDownloadableLink = '';
  late String selectedQuality = '480p';
  bool showAd = true;
  bool showBackward = false;
  bool showForward = false;
  TextEditingController speedController = TextEditingController(text: '1.0');
  double steps = 0.05;

  Duration _currentPosition = Duration.zero;
  Timer? _hideControlsTimer;
  bool _isFullscreen = false;
  bool _showControls = true;
  Timer? _sliderTimer; // Timer to hide the slider after a delay
  late VideoPlayerController _videoPlayerController;
  // Initialize the FlutterLocalNotificationsPlugin outside the widget.
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkAndResetShowAd();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _hideControlsTimer?.cancel();

    _sliderTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    playbackSpeed = 1.0;
    selectedLink = widget.videoUrls.main;
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(selectedLink!),
    );
    _videoPlayerController.initialize().then((_) {
      setState(() {});
    });
    fetchAndParseVastXml();
    _videoPlayerController.addListener(() {
      setState(() {
        _currentPosition = _videoPlayerController.value.position;
      });
    });
    _videoPlayerController.play();
    _videoPlayerController.videoPlayerOptions?.webOptions?.controls;
    // VolumeController().listener((volume) {
    //   setState(() => _initialVolume = volume);
    // });

    // VolumeController().getVolume().then((volume) => currentVolume = volume);
    checkPrefs();
  }

  double get widthFactor => widthFactorValues[currentWidthFactorIndex];

  double get heightFactor => heightFactorValues[currentHeightFactorIndex];

  Future<void> checkPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('showAdTimestamp', DateTime.now().millisecondsSinceEpoch);
    double newSpeed = prefs.getDouble('speed') ?? 1.0;
    setState(() {
      playbackSpeed = newSpeed;
      speedController.text = newSpeed.toStringAsFixed(2);
      showAd = prefs.getBool('showAd') ?? true;
    });
    if (kDebugMode) {
      print('checkPrefsShowAd: $showAd');
    }
    _videoPlayerController.setPlaybackSpeed(newSpeed);
    // Save 'showAd' to shared preferences
  }

  Future<void> fetchAndParseVastXml() async {
    try {
      final response = await http
          .get(Uri.parse('https://s.magsrv.com/splash.php?idzone=5067482'));
      if (response.statusCode == 200) {
        final xmlString = response.body;
        final document = XmlDocument.parse(xmlString);

        final gifElement =
            document.findAllElements('StaticResource').firstWhere(
                  (element) =>
                      element.getAttribute('creativeType') == 'image/gif',
                );

        final nonLinearElement =
            document.findAllElements('NonLinearClickThrough').first;
        // nonLinearClickThroughUrl = nonLinearElement
        //     .findAllElements('NonLinearClickThrough')
        //     .first
        //     .innerText;

        setState(() {
          gifUrl = gifElement.innerText.trim();
          nonLinearClickThroughUrl = nonLinearElement.innerText.trim();
        });

        if (kDebugMode) {
          print('gifUrl; $gifUrl');
        }
        if (kDebugMode) {
          print('nonLinearClickThroughUrl; $nonLinearClickThroughUrl');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching and parsing VAST XML: $e');
      }
    }
  }

  Future<void> handleClickButton(
      BuildContext context, String nonLinearClickThroughUrl) async {
    // launchUrl(
    //   Uri.parse(nonLinearClickThroughUrl.trim()),
    // );
    final prefs = await SharedPreferences.getInstance();
    inVideoAddLaunch(context, browser, nonLinearClickThroughUrl);
    await prefs.setBool('showAd', false);
    setState(() {
      if (_videoPlayerController.value.isPlaying) {
        _videoPlayerController.pause();
      }
      showAd = prefs
          .getBool('showAd')!; // Set showAd to false when the button is clicked
    });
    // Start a timer to reset showAd to true after 5 minutes
    if (kDebugMode) {
      print('handleShowAd: $showAd');
    }
  }

  Future<void> checkAndResetShowAd() async {
    final prefs = await SharedPreferences.getInstance();
    final showAdTimestamp = prefs.getInt('showAdTimestamp') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (showAdTimestamp == 0 ||
        currentTime - showAdTimestamp >= (20 * 60 * 1000)) {
      await prefs.setBool('showAd', true);
      setState(() {
        showAd = true;
      });
      if (kDebugMode) {
        print('checkResetShowAd: $showAd');
      }
    }
  }

  Future<void> changeVideoQuality(String quality) async {
    switch (quality) {
      case '240p':
        setState(() {
          selectedLink = widget.videoUrls.link240p;
        });
        break;
      case '360p':
        setState(() {
          selectedLink = widget.videoUrls.link360p;
        });
        break;
      case '480p':
        setState(() {
          selectedLink = widget.videoUrls.link480p;
        });
        break;
      case '720p':
        setState(() {
          selectedLink = widget.videoUrls.link720p;
        });
        break;
      case '1080p':
        setState(() {
          selectedLink = widget.videoUrls.link1080p;
        });
        break;
      case '4k':
        setState(() {
          selectedLink = widget.videoUrls.fourk;
        });
        break;
    }

    if (selectedLink != null) {
      // Initialize the new controller with the selected quality URL
      final newController = VideoPlayerController.networkUrl(
        Uri.parse(selectedLink!),
      );
      final prefs = await SharedPreferences.getInstance();

      double newSpeed = prefs.getDouble('speed') ?? 1.0;
      // Initialize and seek to the stored playback position
      await newController.initialize();
      await newController.seekTo(_currentPosition);
      // newController.setLooping(true);
      await newController.setPlaybackSpeed(newSpeed);
      await newController.play();
      // newController.setPlaybackSpeed(speed)

      // Dispose the old controller
      await _videoPlayerController.dispose();
      setState(() {
        _videoPlayerController = newController;
        selectedQuality = quality;
      });
      // Update the selected quality and controller
      // print(selectedLink);
    }
  }

  Future<void> changeDownloadableVideoQuality(String quality) async {
    switch (quality) {
      case '240p':
        setState(() {
          selectedDownloadableLink = widget.videoUrls.link240p;
        });
        break;
      case '360p':
        setState(() {
          selectedDownloadableLink = widget.videoUrls.link360p;
        });
        break;
      case '480p':
        setState(() {
          selectedDownloadableLink = widget.videoUrls.link480p;
        });
        break;
      case '720p':
        setState(() {
          selectedDownloadableLink = widget.videoUrls.link720p;
        });
        break;
      case '1080p':
        setState(() {
          selectedDownloadableLink = widget.videoUrls.link1080p;
        });
        break;
      case '4k':
        setState(() {
          selectedDownloadableLink = widget.videoUrls.fourk;
        });
        break;
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoPlayerController.value.isPlaying) {
        _videoPlayerController.pause();
      } else {
        _videoPlayerController.play();
        _hideControlsAfterDelay();
      }
    });
  }

  void _seekForward(int value) {
    final newPosition =
        _videoPlayerController.value.position + Duration(seconds: value);
    AnimationController controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    Animation<double> positionAnimation = Tween<double>(
      begin: _videoPlayerController.value.position.inMilliseconds.toDouble(),
      end: newPosition.inMilliseconds.toDouble(),
    ).animate(controller);

    // Start the animation
    controller.forward();

    // Update the video player's position when the animation changes
    controller.addListener(() {
      Duration newDuration = Duration(
        milliseconds: positionAnimation.value.toInt(),
      );
      _videoPlayerController.seekTo(newDuration);
    });

    // Clean up resources when the animation is done
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });

    // _videoPlayerController.seekTo(newPosition);
  }

  void _seekBackward(int value) {
    AnimationController controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    final newPosition =
        _videoPlayerController.value.position - Duration(seconds: value);
    Animation<double> positionAnimation = Tween<double>(
      begin: _videoPlayerController.value.position.inMilliseconds.toDouble(),
      end: newPosition.inMilliseconds.toDouble(),
    ).animate(controller);

    // Start the animation
    controller.forward();

    // Update the video player's position when the animation changes
    controller.addListener(() {
      Duration newDuration = Duration(
        milliseconds: positionAnimation.value.toInt(),
      );
      _videoPlayerController.seekTo(newDuration);
    });

    // Clean up resources when the animation is done
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });
  }

  void _hideControlsAfterDelay() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        _showControls = false;
      });
    });
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    // ]);
    AutoOrientation.landscapeAutoMode(forceSensor: true);
    _hideControlsAfterDelay();
    setState(() {
      _isFullscreen = true;
    });
    _animateFullscreenEntry();

    // Update the VideoPlayerController's preferred orientations to match fullscreen
  }

  Future<bool> _exitFullscreen() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _hideControlsAfterDelay();
    setState(() {
      _isFullscreen = false;
    });
    _animateFullscreenEntry();
    return Future.value(true); // Allow the back button press
  }

  void _animateFullscreenEntry() {
    // Set up AnimationController for the entry animation
    AnimationController controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    controller.forward();

    // Update the UI when the animations change
    controller.addListener(() {
      setState(() {});
    });

    // Clean up resources when the animations are done
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });
  }

  void _onButtonClick() {
    setState(() {
      currentWidthFactorIndex =
          (currentWidthFactorIndex + 1) % widthFactorValues.length;
      currentHeightFactorIndex =
          (currentHeightFactorIndex + 1) % heightFactorValues.length;
    });
  }

  Future<void> showDownloadProgressNotification(
      int progress, String filename, BuildContext context) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'download_channel',
      'Download Channel',
      importance: Importance.max,
      priority: Priority.high,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Downloading $filename',
      progress.toString(),
      platformChannelSpecifics,
      payload: filename,
    );
  }

  List<Widget> buildQualityOptions(VideoUrls videoUrls) {
    List<Widget> options = [];

    if (videoUrls.link240p.isNotEmpty) {
      options.add(_buildQualityOption('240p', '📱', 'Low Quality'));
    }

    if (videoUrls.link360p.isNotEmpty) {
      options.add(_buildQualityOption('360p', '📺', 'Standard Quality'));
    }

    if (videoUrls.link480p.isNotEmpty) {
      options.add(_buildQualityOption('480p', '📺', 'High Quality'));
    }

    if (videoUrls.link720p.isNotEmpty) {
      options.add(_buildQualityOption('720p', '📺', 'HD Quality'));
    }

    if (videoUrls.link1080p.isNotEmpty) {
      options.add(_buildQualityOption('1080p', '📺', 'Full HD Quality'));
    }

    if (videoUrls.fourk.isNotEmpty) {
      options.add(_buildQualityOption('4k', '📺', '4K Quality'));
    }

    return options;
  }

  Future<void> _showQualityOptions(
      BuildContext context, bool isDownloadAble) async {
    if (kDebugMode) {
      print('Showing quality options');
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        List<Widget> qualityOptions = buildQualityOptions(widget.videoUrls);
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      isDownloadAble == true
                          ? Icons.download_outlined
                          : Icons.high_quality_rounded,
                      size: 24.0,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      isDownloadAble == true
                          ? 'Select Quality To Download'
                          : 'Select Quality',
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: isDownloadAble == true
                    ? [
                        _buildQualityDownloadOption(
                            '240p', '📱', 'Low Quality'),
                        _buildQualityDownloadOption(
                            '360p', '📺', 'Standard Quality'),
                        _buildQualityDownloadOption(
                            '480p', '📺', 'High Quality'),
                        _buildQualityDownloadOption('720p', '📺', 'HD Quality'),
                        _buildQualityDownloadOption(
                            '1080p', '📺', 'Full HD Quality'),
                        _buildQualityDownloadOption('4k', '📺', '4K Quality'),
                      ]
                    : qualityOptions,
              ),
            ],
          ),
        );
      },
    ).then((_) => Navigator.pop(context));
  }

  Widget _buildQualityOption(String quality, String emoji, String text) {
    return Container(
      decoration: BoxDecoration(
        border: selectedLink!.contains(quality)
            ? Border.all(
                color: Colors.blue,
                width: 2,
              )
            : null,
        color: selectedLink!.contains(quality) ? Colors.lightBlue[100] : null,
      ),
      child: ListTile(
        leading:
            Text(emoji, style: const TextStyle(fontSize: 20)), // Emoji or icon
        title: Text(
          text,
          style: const TextStyle(
            // color: selectedLink!.contains(quality) ? Colors.grey : Colors.black,
            fontSize: 16, // Adjust the font size
            fontWeight: FontWeight.bold, // Adjust the font weight
          ),
        ),

        onTap: () {
          changeVideoQuality(quality);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> downloadFile(
      String url, String filename, BuildContext context) async {
    print('the URl is $url');

    try {
      final response = await http.get(Uri.parse(url));
      print('the response code is ${response.statusCode}');
      if (response.statusCode == 200) {
        await showDownloadProgressNotification(0, filename, context);
        Navigator.pop(context);
        final Uint8List bytes = response.bodyBytes;
        print('the bytes $bytes');
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String downloadPath = '${appDocDir.path}/DownloadedVideos';
        File file = File('$downloadPath/$filename');

        final int totalBytes = bytes.length;
        int receivedBytes = 0;
        int progress = 0;

        print(
            'the receivedBytes is not less than $receivedBytes and $totalBytes');
        while (receivedBytes < totalBytes) {
          // Update the download progress every second
          await Future.delayed(const Duration(seconds: 1));

          // Calculate the current progress
          receivedBytes = await file.length();
          progress = ((receivedBytes / totalBytes) * 100).toInt();
          print('the progress is $progress');
          // Show/update the progress notification
          await showDownloadProgressNotification(progress, filename, context);
        }

        // Hide the progress notification when download is complete
        flutterLocalNotificationsPlugin.cancel(0);
        Navigator.pop(context);
      } else {
        print('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  ListTile _buildQualityDownloadOption(
      String quality, String emoji, String text) {
    return ListTile(
      leading:
          Text(emoji, style: const TextStyle(fontSize: 20)), // Emoji or icon
      title: Text(
        text,
        style: TextStyle(
          color: selectedLink!.contains(quality) ? Colors.grey : Colors.black,
          fontSize: 16, // Adjust the font size
          fontWeight: FontWeight.bold, // Adjust the font weight
        ),
      ),
      onTap: () async {
        await changeDownloadableVideoQuality(quality).then((_) async =>
            await downloadFile(
                selectedDownloadableLink, widget.title, context));

        flutterLocalNotificationsPlugin.cancel(0);
      },
    );
  }

  void _showSettingsOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSettingsOption(
                'Change Quality', '🎮', 'Change video quality'),
            _buildSettingsOption(
                'Playback Speed', '⏩', 'Change playback speed'),
            // _buildSettingsOption('Download', '⏩', 'Download'),
          ],
        );
      },
    );
  }

  ListTile _buildSettingsOption(
      String title, String emoji, String description) {
    return ListTile(
      leading: Text(
        emoji,
        style: const TextStyle(fontSize: 20), // Emoji or icon
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16, // Adjust the font size
          fontWeight: FontWeight.bold, // Adjust the font weight
        ),
      ),
      subtitle: Text(
        description,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14, // Adjust the font size
        ),
      ),
      onTap: () {
        _handleSettingsOption(title); // Implement your logic here
      },
    );
  }

  void _handleSettingsOption(String option) {
    // Implement your logic for handling the selected settings option
    if (option == 'Change Quality') {
      _showQualityOptions(context, false);
      // Handle change quality
    } else if (option == 'Playback Speed') {
      _showPlaybackSpeedBottomSheet();
      // Handle change playback speed
    } else if (option == 'Download') {
      _showQualityOptions(context, true);
      // Handle change playback speed
    }
  }

  setSpeed(double val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('speed', val);
    setState(() {
      playbackSpeed = prefs.getDouble('speed')!;
      speedController.text = prefs.getDouble('speed')!.toStringAsFixed(2);
      _videoPlayerController.setPlaybackSpeed(val);
    });
  }

  void _showPlaybackSpeedBottomSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Container(
          constraints: const BoxConstraints(minHeight: 150),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                child: const Row(
                  children: [
                    Icon(
                      Icons.speed,
                      size: 24.0,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'Set Playback Speed',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          double newSpeed = playbackSpeed - steps;
                          if (newSpeed < steps) {
                            newSpeed = steps;
                          } else if (newSpeed < 0.5) {
                            newSpeed = 0.5;
                          }
                          setSpeed(newSpeed);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.remove,
                            size: 24.0,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.blue.withOpacity(0.1),
                          ),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: speedController.text,
                              border: InputBorder.none,
                            ),
                            readOnly: true,
                            controller: speedController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () async {
                          double newSpeed = playbackSpeed + steps;
                          if (newSpeed > maxSpeed) {
                            setState(() {
                              newSpeed = maxSpeed;
                            });
                          } else {
                            setSpeed(newSpeed);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 24.0,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  setSpeed(1.0);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // Text color

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(0.0), // Button border radius
                  ),
                  elevation: 8, // Button shadow
                ),
                child: Container(
                  // padding: const EdgeInsets.symmetric(
                  //     horizontal: 24, vertical: 16), // Button padding
                  margin: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16), // Button padding
                  child: const Center(
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight =
        _isFullscreen == true ? MediaQuery.of(context).size.height : 300;

    return WillPopScope(
      onWillPop: _exitFullscreen,
      child: Column(
        children: [
          GestureDetector(
            onTap: _toggleControlsVisibility,
            child: Container(
              color: Colors.black,
              width: screenWidth,
              height: screenHeight,
              child: Stack(
                children: [
                  Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return FractionallySizedBox(
                          widthFactor: widthFactor,
                          heightFactor: heightFactor,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: screenWidth,
                              maxHeight: screenHeight,
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: AspectRatio(
                                    aspectRatio: _videoPlayerController
                                        .value.aspectRatio,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _showControls = !_showControls;
                                          if (_showControls) {
                                            _hideControlsAfterDelay();
                                          }
                                        });
                                      },
                                      child:
                                          VideoPlayer(_videoPlayerController),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_showControls)
                    AnimatedOpacity(
                      opacity: _showControls ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Visibility(
                        maintainState: true,
                        visible: _showControls,
                        child: IgnorePointer(
                          ignoring: !_showControls,
                          child: VideoPlayerControls(
                            isPlaying: _videoPlayerController.value.isPlaying,
                            isBuffering:
                                _videoPlayerController.value.isBuffering,
                            togglePlayPause: _togglePlayPause,
                            duration: _videoPlayerController.value.duration,
                            position: _videoPlayerController.value.position,
                            videoPlayerController: _videoPlayerController,
                            seekForward: _seekForward,
                            seekBackward: _seekBackward,
                            isFullscreen: _isFullscreen,
                            onButtonClick: _onButtonClick,
                            enterFullscreen: _enterFullscreen,
                            exitFullscreen: _exitFullscreen,
                            showControls: _showControls,
                            title: widget.title,
                            videoUrl: widget.videoUrls.main,
                            showSettingsOptions: _showSettingsOptions,
                          ),
                        ),
                      ),
                    ),
                  if (_videoPlayerController.value.isBuffering ||
                      !_videoPlayerController.value.isInitialized)
                    Positioned(
                      top: screenHeight / 2.6,
                      right: screenWidth / 2.1,
                      child: const Center(
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (showBackward)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: screenHeight,
                        width: screenWidth / 2 - 30,
                        // color: Colors.black45,
                        child: const Center(
                          child: Icon(
                            Icons.replay_10_rounded,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (showForward)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: screenHeight,
                        width: screenWidth / 2 - 30,
                        // color: Colors.black45,
                        child: const Center(
                          child: Icon(
                            Icons.forward_10_rounded,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: screenHeight - 85,
                          width: screenWidth / 2 - 30,
                          child: GestureDetector(
                            onDoubleTap: () {
                              _seekBackward(
                                  10); // Implement this function to handle rewind
                              setState(() {
                                showBackward = true;
                              });

                              Future.delayed(
                                const Duration(milliseconds: 500),
                                () {
                                  setState(() {
                                    showBackward = false;
                                    if (kDebugMode) {
                                      print("showBackward: $showBackward");
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: screenHeight - 85,
                          width: screenWidth / 2 - 30,
                          child: GestureDetector(
                            onDoubleTap: () {
                              _seekForward(
                                  10); // Implement this function to handle rewind
                              setState(() {
                                showForward = true;
                              });

                              Future.delayed(
                                const Duration(milliseconds: 500),
                                () {
                                  setState(() {
                                    showForward = false;
                                    if (kDebugMode) {
                                      print("showForward: $showForward");
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showAd && gifUrl != '')
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              handleClickButton(
                                  context, nonLinearClickThroughUrl);
                            },
                            child: Container(
                              width: screenWidth / 2.1,
                              height: screenHeight / 2.1,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  gifUrl,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          // Positioned(
                          //   top: 5,
                          //   right: 5,
                          //   child: Container(
                          //     color: Colors.black54,
                          //     width: 30,
                          //     height: 30,
                          //     child: Align(
                          //       alignment:
                          //           Alignment.center, // Center the IconButton
                          //       child: IconButton(
                          //         icon: const Icon(
                          //           Icons.close,
                          //           size: 18,
                          //           color: Colors.white,
                          //         ),
                          //         onPressed: () {
                          //           setState(() {
                          //             showAd = false;
                          //           });
                          //         },
                          //       ),
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                    )
                ],
              ),
            ),
          ),
          if (!_isFullscreen)
            SizedBox(
              height: MediaQuery.of(context).size.height - 250,
              // color: Colors.black.withOpacity(0.4),
              child: SimilarScreen(
                id: widget.id,
                isFullScreen: _isFullscreen,
              ),
            )
          else
            const SizedBox.shrink()
        ],
      ),
    );
  }
}
