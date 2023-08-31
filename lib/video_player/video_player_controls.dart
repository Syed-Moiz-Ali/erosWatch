// ignore_for_file: must_be_immutable, library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

class VideoPlayerControls extends StatefulWidget {
  final bool isPlaying;
  final bool isBuffering;
  final VoidCallback togglePlayPause;
  final Function(int) seekForward;
  final Function(int) seekBackward;
  final Duration duration;
  final Duration position;
  final VideoPlayerController videoPlayerController;
  final bool isFullscreen;
  final VoidCallback onButtonClick;
  final VoidCallback enterFullscreen;
  final VoidCallback exitFullscreen;
  late bool showControls;
  late String title;
  late String videoUrl;

  VideoPlayerControls({
    Key? key,
    required this.isPlaying,
    required this.isBuffering,
    required this.togglePlayPause,
    required this.seekForward,
    required this.seekBackward,
    required this.duration,
    required this.position,
    required this.videoPlayerController,
    required this.isFullscreen,
    required this.onButtonClick,
    required this.enterFullscreen,
    required this.exitFullscreen,
    required this.showControls,
    required this.title,
    required this.videoUrl,
  }) : super(key: key);

  @override
  _VideoPlayerControlsState createState() => _VideoPlayerControlsState();
}

class _VideoPlayerControlsState extends State<VideoPlayerControls> {
  bool _controlsVisible = true; // Controls visibility flag
  bool fullscreen = false; // Controls visibility flag
  bool text = false;
  // Method to toggle controls visibility with a delay
  void _toggleControlsVisibility() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });

    // Show controls for a while and then hide again
    if (_controlsVisible) {
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          _controlsVisible = false;
        });
      });
    }
  }

  void toggleFullscreen() {
    if (fullscreen == false) {
      setState(() {
        fullscreen = true; // Set fullscreen to true
      });
      widget.enterFullscreen();
    } else {
      setState(() {
        fullscreen = false; // Set fullscreen to false
      });
      widget.exitFullscreen();
    }
  }

  Widget button(VoidCallback onPressed, IconData icon, double size) {
    return IconButton(
      icon: Icon(icon, size: size, color: Colors.white),
      onPressed: _controlsVisible ? onPressed : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight =
        widget.isFullscreen ? MediaQuery.of(context).size.height : 310;
    double size = screenWidth < 600 ? 30.0 : 40.0;
    Duration remainingDuration = widget.duration - widget.position;
    int remainingMinutes = remainingDuration.inMinutes;
    int remainingSeconds = remainingDuration.inSeconds % 60;

    // print(_controlsVisible);
    return GestureDetector(
      onTap: _toggleControlsVisibility, // Toggle controls on tap
      child: AnimatedOpacity(
        opacity: _controlsVisible ? 1.0 : 0.0, // Animate opacity
        duration: const Duration(milliseconds: 300),
        child: Container(
          height: screenHeight,
          color: Colors.black.withOpacity(0.4),
          child: SizedBox(
            height: screenHeight,
            child: Column(
              mainAxisAlignment: screenWidth > 600
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.end,
              children: [
                if (screenWidth > 600)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28.0, vertical: 5.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 30,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          widget.exitFullscreen();
                          // Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Text(
                              "${widget.position.inMinutes}:${(widget.position.inSeconds % 60).toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                          VideoProgressBar(
                            duration: widget.duration,
                            position: widget.position,
                            videoPlayerController: widget.videoPlayerController,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  text = !text;
                                });
                              },
                              child: Text(
                                text
                                    ? "$remainingMinutes:${remainingSeconds.toString().padLeft(2, '0')}"
                                    : "${widget.duration.inMinutes}:${(widget.duration.inSeconds % 60).toString().padLeft(2, '0')}",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10, vertical: screenWidth < 600 ? 5 : 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    // screenWidth < 600
                                    //     ? MainAxisAlignment.spaceAround
                                    //     :
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: widget.isBuffering
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          )
                                        // const SizedBox.shrink()
                                        : Icon(
                                            widget.isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            size: size,
                                            color: Colors.white,
                                          ),
                                    onPressed: _controlsVisible
                                        ? widget.togglePlayPause
                                        : null,
                                  ),
                                  SizedBox(width: screenWidth < 600 ? 10 : 20),
                                  // if (screenWidth > 600)
                                  //   button(() => widget.seekBackward(30),
                                  //       Icons.replay_30_rounded, size),
                                  button(() => widget.seekBackward(10),
                                      Icons.replay_10_rounded, size),

                                  button(() => widget.seekForward(10),
                                      Icons.forward_10_rounded, size),
                                  // if (screenWidth > 600)
                                  //   button(() => widget.seekForward(30),
                                  //       Icons.forward_30_rounded, size),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.fit_screen_outlined,
                                  size: size - 5,
                                  color: Colors.white,
                                ),
                                onPressed: _controlsVisible
                                    ? widget.onButtonClick
                                    : null,
                              ),
                              SizedBox(width: screenWidth < 600 ? 10 : 20),
                              IconButton(
                                icon: Icon(
                                  Icons.fullscreen,
                                  size: size - 5,
                                  color: Colors.white,
                                ),
                                onPressed:
                                    _controlsVisible ? toggleFullscreen : null,
                              ),
                            ],
                          ),

                          // VideoDownloadScreen(
                          //   videoUrl: widget.videoUrl,
                          //   title: widget.title,
                          // ),
                        ],
                      ),
                    ),
                    // if (screenWidth < 600) const SizedBox(height: 40),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VideoProgressBar extends StatelessWidget {
  final VideoPlayerController videoPlayerController;
  final Duration duration;
  final Duration position;

  const VideoProgressBar({
    Key? key,
    required this.videoPlayerController,
    required this.duration,
    required this.position,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      width: screenWidth < 600 ? screenWidth * 0.80 : screenWidth * 0.90,
      child: AnimatedBuilder(
        animation: videoPlayerController,
        builder: (context, child) {
          return SliderTheme(
            data: SliderThemeData(
              thumbColor: Colors.white,
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.grey,
              trackHeight: 4.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
              overlayColor: Colors.white.withOpacity(0.3),
            ),
            child: Slider(
              value: progress,
              onChanged: (newValue) {
                final newPosition = Duration(
                  milliseconds: (newValue * duration.inMilliseconds).toInt(),
                );
                videoPlayerController.seekTo(newPosition);
              },
              onChangeEnd: (newValue) {
                final newPosition = Duration(
                  milliseconds: (newValue * duration.inMilliseconds).toInt(),
                );
                videoPlayerController.seekTo(newPosition);
              },
            ),
          );
        },
      ),
    );
  }
}
