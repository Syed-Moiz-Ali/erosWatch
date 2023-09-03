// ignore_for_file: must_be_immutable, library_private_types_in_public_api, depend_on_referenced_packages

import 'dart:async';

import 'dart:math';
import 'package:eroswatch/util/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eroswatch/Watch/smiliar.dart';
import 'package:eroswatch/video_player/video_player_controls.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String id;
  final String title;

  const VideoPlayerScreen(
      {super.key,
      required this.videoUrl,
      required this.id,
      required this.title});

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
  late VideoPlayerController _videoPlayerController;
  final ChromeSafariBrowser browser = ChromeSafariBrowser();
  bool _showControls = true;
  Timer? _hideControlsTimer;
  bool _isFullscreen = false;
  String gifUrl = '';
  String nonLinearClickThroughUrl = '';
  bool showAd = true;
  bool showForward = false;
  bool showBackward = false;

  List<double> widthFactorValues = [
    1.0,
    1.2,
  ];
  List<double> heightFactorValues = [
    1.0,
    1.2,
  ];
  int currentWidthFactorIndex = 0;
  int currentHeightFactorIndex = 0;

  double get widthFactor => widthFactorValues[currentWidthFactorIndex];
  double get heightFactor => heightFactorValues[currentHeightFactorIndex];
  // double _initialVolumeDrag = 0; // Initial position of vertical drag
  // double _initialVolume = 0; // Initial volume value
  double currentVolume = 0;
  bool isSliderVisible = false; // Initial visibility state
  Timer? _sliderTimer; // Timer to hide the slider after a delay

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    _videoPlayerController.initialize().then((_) {
      setState(() {});
    });
    fetchAndParseVastXml();
    _videoPlayerController.addListener(() {
      setState(() {});
    });
    _videoPlayerController.play();
    _videoPlayerController.videoPlayerOptions?.webOptions?.controls;
    // VolumeController().listener((volume) {
    //   setState(() => _initialVolume = volume);
    // });

    // VolumeController().getVolume().then((volume) => currentVolume = volume);
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

  // void _onVerticalVolumeDragStart(DragStartDetails details) async {
  //   _initialVolumeDrag = details.localPosition.dy;
  //   _initialVolume = await VolumeController().getVolume();
  // }

  // void _onVerticalVolumeDragUpdate(DragUpdateDetails details) {
  //   setState(() {
  //     isSliderVisible = true;
  //   });
  //   _sliderTimer?.cancel();
  //   _sliderTimer = Timer(const Duration(seconds: 2), () {
  //     setState(() {
  //       isSliderVisible = false;
  //     });
  //   });
  //   double deltaY = details.localPosition.dy - _initialVolumeDrag;
  //   double maxDeltaY =
  //       3000.0; // Adjust this value based on desired sensitivity (higher value for less sensitivity)

  //   // Limit deltaY to a maximum value to control sensitivity
  //   deltaY = deltaY.clamp(-maxDeltaY, maxDeltaY);

  //   double volumeIncrement =
  //       -0.7; // Adjust this value for smoother adjustment (smaller value for smoother)

  //   double deltaVolume = deltaY / maxDeltaY * volumeIncrement;

  //   double newVolume = _initialVolume + deltaVolume;
  //   newVolume = newVolume.clamp(0, 1); // Clamp volume between 0 and 1

  //   setState(() {
  //     currentVolume = newVolume;
  //     VolumeController().setVolume(currentVolume);
  //   });
  // }

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _hideControlsAfterDelay();
    setState(() {
      _isFullscreen = true;
    });
    _animateFullscreenEntry();
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

  slider(double currentVolume) {
    return Transform.rotate(
      angle: -90 * (pi / 180),
      child: Opacity(
        opacity: 0.8,
        child:
            // SliderTheme(
            //   data: SliderThemeData(
            //     activeTrackColor: Colors.blue,
            //     inactiveTrackColor: Colors.grey,
            //     overlayColor: Colors.blue.withOpacity(0.3),
            //     overlayShape: const RoundSliderOverlayShape(overlayRadius: 5.0),
            //     thumbShape: const RoundSliderThumbShape(
            //       enabledThumbRadius: 5.0,
            //       disabledThumbRadius: 5.0,
            //     ),
            //     trackShape: const RoundedRectSliderTrackShape(),
            //     rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
            //     valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
            //     trackHeight: 6.0,
            //   ),
            //   child: Slider(
            //     onChanged: (double value) {
            //       setState(() {
            //         currentVolume = value;
            //         VolumeController().setVolume(currentVolume);
            //       });
            //     },
            //     value: currentVolume,
            //     min: 0,
            //     max: 1,
            //   ),
            // ),
            Center(
          child: SizedBox(
            width: 160,
            height: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2000),
              child: LinearProgressIndicator(
                value: currentVolume,
                minHeight: 45.0,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                backgroundColor: Colors.grey, // Set the background color
              ),
            ),
          ),
        ),
        //     Center(
        //   child: Container(
        //       width: 50,
        //       height: 50,
        //       child: CircularProgressIndicator(value: currentVolume)),
        // ),
      ),
    );
  }

  Widget customVolumeControl(double currentVolume) {
    return Align(
      child: Container(
        width: 100, // Adjust the width as needed
        height: 200, // Adjust the height as needed
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5), // Background color
          borderRadius: BorderRadius.circular(20.0), // Rounded corners
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.volume_up, // Volume icon
              color: Colors.white,
              size: 40.0,
            ),
            // const SizedBox(height: 20.0),
            slider(currentVolume),
          ],
        ),
      ),
    );
  }

  void handleClickButton(
      BuildContext context, String nonLinearClickThroughUrl) {
    // launchUrl(
    //   Uri.parse(nonLinearClickThroughUrl.trim()),
    // );
    inVideoAddLaunch(context, browser, nonLinearClickThroughUrl);

    setState(() {
      if (_videoPlayerController.value.isPlaying) {
        _videoPlayerController.pause();
      }
      showAd = false; // Set showAd to false when the button is clicked
    });
    // Start a timer to reset showAd to true after 5 minutes
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
                            videoUrl: widget.videoUrl,
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
                            size: 70,
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
                            size: 70,
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

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _hideControlsTimer?.cancel();
    VolumeController().removeListener();
    _sliderTimer?.cancel();
    super.dispose();
  }
}
