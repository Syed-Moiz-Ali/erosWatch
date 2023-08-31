// ignore_for_file: must_be_immutable, library_private_types_in_public_api

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
  // double _swipeStartY = 0.0;
  // bool _isSwipingUp = false;
  // double _swipeStartX = 0.0;
  // bool _isSwipingHorizontal = false;

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
  double _initialVolumeDrag = 0; // Initial position of vertical drag
  double _initialVolume = 0; // Initial volume value
  double currentVolume = 0;
  bool isSliderVisible = false; // Initial visibility state
  Timer? _sliderTimer; // Timer to hide the slider after a delay
  // double _volumeListenerValue = 0;
  // double _initialBrightnessDrag = 0.0; // Initial position of vertical drag
  // double _initialBrightness = 0.0; // Initial brightness value
  // double _slidingBrightness = 0.0; // Tracking brightness while sliding

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
    VolumeController().listener((volume) {
      setState(() => _initialVolume = volume);
    });

    VolumeController().getVolume().then((volume) => currentVolume = volume);

    // _sliderTimer = Timer(Duration(seconds: 2), () {
    //   setState(() {
    //     isSliderVisible = false;
    //   });
    // });
    // isSliderVisible = false;
    // _enterFullscreen();
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

        final nonLinearElement = document
            .findAllElements('NonLinear')
            .firstWhere(
              (element) =>
                  element.findAllElements('NonLinearClickThrough').isNotEmpty,
            );
        // nonLinearClickThroughUrl = nonLinearElement
        //     .findAllElements('NonLinearClickThrough')
        //     .first
        //     .innerText;

        setState(() {
          gifUrl = gifElement.innerText;
          nonLinearClickThroughUrl = nonLinearElement.innerText;
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

  void _onVerticalVolumeDragStart(DragStartDetails details) async {
    _initialVolumeDrag = details.localPosition.dy;
    _initialVolume = await VolumeController().getVolume();
  }

  void _onVerticalVolumeDragUpdate(DragUpdateDetails details) {
    setState(() {
      isSliderVisible = true;
    });
    _sliderTimer?.cancel();
    _sliderTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        isSliderVisible = false;
      });
    });
    double deltaY = details.localPosition.dy - _initialVolumeDrag;
    double maxDeltaY = 500.0; // Adjust this value based on desired sensitivity

    // Limit deltaY to a maximum value to control sensitivity
    deltaY = deltaY.clamp(-maxDeltaY, maxDeltaY);

    double deltaVolume = deltaY / maxDeltaY;

    double newVolume = _initialVolume - deltaVolume;
    newVolume = newVolume.clamp(0, 1); // Clamp volume between 0 and 1

    setState(() {
      currentVolume = newVolume;
      VolumeController().setVolume(currentVolume);
    });
  }

// void _updateVolume(double newValue) {
//   setState(() {
//     currentVolume = newValue;
//     VolumeController().setVolume(currentVolume);
//   });
// }

//   Future<void> _setBrightness(double brightness) async {
//     try {
//       await ScreenBrightness().setScreenBrightness(brightness);
//     } catch (e) {
//       print("Error setting brightness: $e");
//     }
//   }

  // Future<void> _onVerticalBrightnessDragStart(DragStartDetails details) async {
  //   _initialBrightnessDrag = details.localPosition.dy;
  //   _initialBrightness = ScreenBrightness().current as double;
  //   _slidingBrightness =
  //       _initialBrightness; // Initialize with current brightness
  // }

  // void _onVerticalBrightnessDragUpdate(DragUpdateDetails details) {
  //   double deltaY = details.localPosition.dy - _initialBrightnessDrag;
  //   double deltaBrightness =
  //       deltaY / 200.0; // Adjust this value for sensitivity

  //   double newBrightness = _initialBrightness - deltaBrightness;
  //   newBrightness =
  //       newBrightness.clamp(0.0, 1.0); // Clamp brightness between 0 and 1

  //   setState(() {
  //     _slidingBrightness = newBrightness; // Update sliding brightness
  //     _setBrightness(newBrightness);
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

  // void _onVerticalSwipeStart(DragStartDetails details) {
  //   _swipeStartY = details.globalPosition.dy;
  // }

  // void _onVerticalUpdate(DragUpdateDetails details) {
  //   if (_isSwipingUp) {
  //     final currentY = details.globalPosition.dy;
  //     final deltaY = _swipeStartY - currentY;

  //     if (deltaY < -50) {
  //       // Threshold to consider as swiping down
  //       setState(() {
  //         _isSwipingUp = false;
  //       });
  //     }
  //   } else {
  //     final currentY = details.globalPosition.dy;
  //     final deltaY = _swipeStartY - currentY;

  //     if (deltaY > 50) {
  //       // Threshold to consider as swiping up
  //       setState(() {
  //         _isSwipingUp = true;
  //       });
  //     }
  //   }
  // }

  // void _onVerticalEnd(DragEndDetails details) {
  //   _swipeStartY = 0.0;
  //   _isSwipingUp = false;
  // }

  // void _onHorizontalSwipeStart(DragStartDetails details) {
  //   _swipeStartX = details.globalPosition.dx;
  //   _isSwipingHorizontal = true;
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   final tapPositionX = details.localPosition.dx;
  //   final middleX = screenWidth / 2;

  //   if (tapPositionX > middleX) {
  //     _seekDirection = SeekDirection.backward;
  //   } else {
  //     _seekDirection = SeekDirection.forward;
  //   }
  // }

  // void _onHorizontalUpdate(DragUpdateDetails details) {
  //   if (_isSwipingHorizontal) {
  //     final currentX = details.globalPosition.dx;
  //     final deltaX = currentX - _swipeStartX;
  //     final double screenWidth = MediaQuery.of(context).size.width;

  //     // Calculate the seek amount based on the screen width
  //     final seekAmount = deltaX / screenWidth;

  //     // Define the scaling factor for seek duration
  //     const double seekFactor =
  //         0.09; // Adjust this value as per your preference

  //     // Calculate the final seek duration with scaling
  //     final scaledSeekAmount = seekAmount * seekFactor;

  //     // Seek forward or backward based on the swipe direction
  //     if (seekAmount > 0) {
  //       _seekForwardDrag(scaledSeekAmount);
  //     } else {
  //       _seekBackwardDrag(-scaledSeekAmount);
  //     }
  //   }
  // }

  // void _onHorizontalEnd(DragEndDetails details) {
  //   _swipeStartX = 0.0;
  //   _isSwipingHorizontal = false;
  // }

  // void _seekForwardDrag(double seekAmount) {
  //   final newPosition = Duration(
  //     milliseconds: (_videoPlayerController.value.position.inMilliseconds +
  //             (seekAmount *
  //                 _videoPlayerController.value.duration.inMilliseconds))
  //         .toInt(),
  //   );

  //   AnimationController controller = AnimationController(
  //     duration: const Duration(milliseconds: 300),
  //     vsync: this,
  //   );
  //   Animation<double> positionAnimation = Tween<double>(
  //     begin: _videoPlayerController.value.position.inMilliseconds.toDouble(),
  //     end: newPosition.inMilliseconds.toDouble(),
  //   ).animate(controller);

  //   // Start the animation
  //   controller.forward();

  //   // Update the video player's position when the animation changes
  //   controller.addListener(() {
  //     Duration newDuration = Duration(
  //       milliseconds: positionAnimation.value.toInt(),
  //     );
  //     _videoPlayerController.seekTo(newDuration);
  //   });

  //   // Clean up resources when the animation is done
  //   controller.addStatusListener((status) {
  //     if (status == AnimationStatus.completed) {
  //       controller.dispose();
  //     }
  //   });
  // }

  // void _seekBackwardDrag(double seekAmount) {
  //   final newPosition = Duration(
  //     milliseconds: (_videoPlayerController.value.position.inMilliseconds -
  //             (seekAmount *
  //                 _videoPlayerController.value.duration.inMilliseconds))
  //         .toInt(),
  //   );
  //   AnimationController controller = AnimationController(
  //     duration: const Duration(milliseconds: 300),
  //     vsync: this,
  //   );
  //   Animation<double> positionAnimation = Tween<double>(
  //     begin: _videoPlayerController.value.position.inMilliseconds.toDouble(),
  //     end: newPosition.inMilliseconds.toDouble(),
  //   ).animate(controller);

  //   // Start the animation
  //   controller.forward();

  //   // Update the video player's position when the animation changes
  //   controller.addListener(() {
  //     Duration newDuration = Duration(
  //       milliseconds: positionAnimation.value.toInt(),
  //     );
  //     _videoPlayerController.seekTo(newDuration);
  //   });

  //   // Clean up resources when the animation is done
  //   controller.addStatusListener((status) {
  //     if (status == AnimationStatus.completed) {
  //       controller.dispose();
  //     }
  //   });
  // }

  // void _seekByDoubleTap() {
  //   const seekDuration = 10; // Seek duration in seconds
  //   final seekDirection = _seekDirection == SeekDirection.backward ? 1 : -1;
  //   final newPosition = _videoPlayerController.value.position +
  //       Duration(seconds: seekDuration * seekDirection);
  //   final seekPosition = newPosition.inSeconds
  //       .clamp(0, _videoPlayerController.value.duration.inSeconds);

  //   _videoPlayerController.seekTo(Duration(seconds: seekPosition));
  // }

  // void _clearSeekDirection() {
  //   setState(() {
  //     _seekDirection = SeekDirection.none;
  //   });
  // }

  // Method to handle the button click and change the factor value
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
        child: SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.blue,
            inactiveTrackColor: Colors.grey,
            overlayColor: Colors.blue.withOpacity(0.3),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 5.0),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 5.0,
              disabledThumbRadius: 5.0,
            ),
            trackShape: const RoundedRectSliderTrackShape(),
            rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
            valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
            trackHeight: 6.0,
          ),
          child: Slider(
            onChanged: (double value) {
              setState(() {
                currentVolume = value;
                VolumeController().setVolume(currentVolume);
              });
            },
            value: currentVolume,
            min: 0,
            max: 1,
          ),
        ),
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
            // onVerticalDragStart: _onVerticalSwipeStart,
            // onVerticalDragUpdate: _onVerticalUpdate,
            // onVerticalDragEnd: _onVerticalEnd,
            // onHorizontalDragStart: _onHorizontalSwipeStart,
            // onHorizontalDragUpdate: _onHorizontalUpdate,
            // onHorizontalDragEnd: _onHorizontalEnd,
            // onDoubleTap: _seekByDoubleTap,
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
                  Positioned(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Stack(
                          children: [
                            SizedBox(
                              height: screenHeight,
                              width: screenWidth / 2 - 30,
                              child: GestureDetector(
                                // onVerticalDragStart:
                                //     _onVerticalBrightnessDragStart,
                                // onVerticalDragUpdate:
                                //     _onVerticalBrightnessDragUpdate,
                                // onVerticalDragEnd: (_) {
                                //   setState(() {
                                //     _slidingBrightness =
                                //         _initialBrightness; // Reset sliding brightness
                                //   });
                                // },
                                onDoubleTap: () {
                                  _seekBackward(10);
                                },
                              ),
                            ),
                            Visibility(
                              visible: isSliderVisible,
                              child: slider(currentVolume),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: screenHeight,
                          width: screenWidth / 2 - 30,
                          child: GestureDetector(
                            onVerticalDragStart: _onVerticalVolumeDragStart,
                            onVerticalDragUpdate: _onVerticalVolumeDragUpdate,
                            onDoubleTap: () {
                              _seekForward(10);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // DoubleTap(
                  //   videoPlayerController: _videoPlayerController,
                  // ),
                  if (showAd && gifUrl != '')
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              inVideoAddLaunch(
                                  context, browser, nonLinearClickThroughUrl);
                            },
                            child: Container(
                              width: screenWidth / 2.1,
                              height: screenHeight / 2.1,
                              color: Colors.grey[400],
                              child: Image.network(
                                gifUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Container(
                              color: Colors.black54,
                              width: 30,
                              height: 30,
                              child: Align(
                                alignment:
                                    Alignment.center, // Center the IconButton
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      showAd = false;
                                    });
                                  },
                                ),
                              ),
                            ),
                          )
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
