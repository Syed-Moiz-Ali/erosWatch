// ignore_for_file: must_be_immutable, library_private_types_in_public_api, depend_on_referenced_packages, use_build_context_synchronously

import 'dart:async';
import 'dart:math';
import 'package:eroswatch/helper/videos.dart';
import 'package:eroswatch/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eroswatch/Watch/smiliar.dart';
import 'package:eroswatch/Watch/video_player/video_player_controls.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';
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
  int currentHeightFactorIndex = 0;
  // double _initialVolumeDrag = 0; // Initial position of vertical drag
  // double _initialVolume = 0; // Initial volume value
  double currentVolume = 0;

  int currentWidthFactorIndex = 0;
  String gifUrl = '';
  List<double> heightFactorValues = [
    1.0,
    1.2,
  ];

  bool isSliderVisible = false; // Initial visibility state
  double maxSpeed = 2.5;
  String nonLinearClickThroughUrl = '';
  late double playbackSpeed;
  late String? selectedLink;
  late String selectedQuality = '480p';
  bool showAd = true;
  bool showBackward = false;
  bool showForward = false;
  TextEditingController speedController = TextEditingController();
  double steps = 0.25;
  List<double> widthFactorValues = [
    1.0,
    1.2,
  ];

  Duration _currentPosition = Duration.zero;
  Timer? _hideControlsTimer;
  bool _isFullscreen = false;
  bool _showControls = true;
  Timer? _sliderTimer; // Timer to hide the slider after a delay
  late VideoPlayerController _videoPlayerController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkAndResetShowAd();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _hideControlsTimer?.cancel();
    VolumeController().removeListener();
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
    setState(() {
      showAd = prefs.getBool('showAd') ?? true;
    });
    if (kDebugMode) {
      print('checkPrefsShowAd: $showAd');
    }
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
        selectedLink = widget.videoUrls.link240p;
        break;
      case '360p':
        selectedLink = widget.videoUrls.link360p;
        break;
      case '480p':
        selectedLink = widget.videoUrls.link480p;
        break;
      case '720p':
        selectedLink = widget.videoUrls.link720p;
        break;
      case '1080p':
        selectedLink = widget.videoUrls.link1080p;
        break;
      case '4k':
        selectedLink = widget.videoUrls.fourk;
        break;
    }

    if (selectedLink != null) {
      // Initialize the new controller with the selected quality URL
      final newController = VideoPlayerController.networkUrl(
        Uri.parse(selectedLink!),
      );

      // Initialize and seek to the stored playback position
      await newController.initialize();
      await newController.seekTo(_currentPosition);
      // newController.setLooping(true);
      newController.play();
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

  Future<void> _showQualityOptions(BuildContext context) async {
    if (kDebugMode) {
      print('Showing quality options');
    }
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQualityOption('240p', '📱', 'Low Quality'),
            _buildQualityOption('360p', '📺', 'Standard Quality'),
            _buildQualityOption('480p', '📺', 'High Quality'),
            _buildQualityOption('720p', '📺', 'HD Quality'),
            _buildQualityOption('1080p', '📺', 'Full HD Quality'),
            _buildQualityOption('4k', '📺', '4K Quality'),
          ],
        );
      },
    ).then((_) => Navigator.pop(context));
  }

  ListTile _buildQualityOption(String quality, String emoji, String text) {
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
      onTap: () {
        changeVideoQuality(quality);
        Navigator.pop(context);
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
      _showQualityOptions(context);
      // Handle change quality
    } else if (option == 'Playback Speed') {
      _showPlaybackSpeedBottomSheet();
      // Handle change playback speed
    }
  }

  void _showPlaybackSpeedBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        double newSpeed = playbackSpeed - steps;
                        if (newSpeed < steps) {
                          newSpeed = steps;
                        }
                        setState(() {
                          playbackSpeed = newSpeed;
                          speedController.text = newSpeed.toStringAsFixed(2);
                          _videoPlayerController.setPlaybackSpeed(newSpeed);
                        });
                      },
                      child: const Icon(
                        Icons.remove_circle_outline,
                        size: 32.0,
                        color: Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        width: 60.0,
                        child: TextField(
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
                    GestureDetector(
                      onTap: () {
                        double newSpeed = playbackSpeed + steps;
                        if (newSpeed > maxSpeed) {
                          newSpeed = maxSpeed;
                        }
                        setState(() {
                          playbackSpeed = newSpeed;
                          speedController.text = newSpeed.toStringAsFixed(2);
                          _videoPlayerController.setPlaybackSpeed(newSpeed);
                        });
                      },
                      child: const Icon(
                        Icons.add_circle_outline,
                        size: 32.0,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
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
                              showSettingsOptions: _showSettingsOptions),
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
              height: MediaQuery.of(context).size.height - 300,
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
