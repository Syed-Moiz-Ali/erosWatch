// ignore_for_file: library_private_types_in_public_api, must_be_immutable, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String videoUrl;
  bool isShown;

  CustomVideoPlayer({Key? key, required this.videoUrl, required this.isShown})
      : super(key: key);

  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _controller;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    checkIsShown();
  }

  void checkIsShown() {
    print('videoUrl is ${widget.videoUrl}');
    if (widget.isShown == true) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      )..initialize().then((_) {
          setState(() {
            isPlaying = true;
          });
          _controller.play();
          _controller.setVolume(0.0);

          // _controller.setLooping(true);
          _controller.addListener(() {
            if (_controller.value.position >= _controller.value.duration) {
              // Video playback complete
              setState(() {
                isPlaying = false;
              });
            }
          });
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.value.isInitialized) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                    height: _controller.value.size.height,
                    width: _controller.value.size.width,
                    child: VideoPlayer(_controller)),
              ),
            ),
          ),
          if (isPlaying == true)
            const SizedBox.shrink()
          else
            Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: isPlaying == false
                      ? Colors.black.withOpacity(0.7)
                      : Colors.white,
                ),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _controller.play();
                      _controller.addListener(() {
                        setState(() {
                          isPlaying = true;
                        });
                      });
                    },
                    child: const Icon(
                      Icons.replay_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ))
        ],
      );
    } else {
      return const Center(
        child: SizedBox(
          height: 30,
          width: 30,
          child: CupertinoActivityIndicator(),
        ),
      );
    }
  }
}
