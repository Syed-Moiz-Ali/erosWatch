// // ignore_for_file: library_private_types_in_public_api

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

// class DoubleTap extends StatefulWidget {
//   final VideoPlayerController videoPlayerController;

//   const DoubleTap({
//     super.key,
//     required this.videoPlayerController,
//   });
//   @override
//   _DoubeTapState createState() => _DoubeTapState();
// }

// class _DoubeTapState extends State<DoubleTap> with TickerProviderStateMixin {
//   late bool _showLeftBackground = false;
//   late bool _showRightBackground = false;
//   bool _showIcon = false;
//   Timer? _iconTimer;

//   void _toggleBackgroundAndIconVisibility(text) {
//     setState(() {
//       if (text == 'left') {
//         _showLeftBackground = true;
//       } else {
//         _showRightBackground = true;
//       }
//       _showIcon = true;
//     });

//     _iconTimer?.cancel(); // Cancel any previous timer
//     _iconTimer = Timer(const Duration(seconds: 2), () {
//       setState(() {
//         if (text == 'left') {
//           _showLeftBackground = false;
//         } else {
//           _showRightBackground = false;
//         }
//         _showIcon = !_showIcon;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _iconTimer?.cancel(); // Cancel the timer when the widget is disposed
//     super.dispose();
//   }

//   gestureWidget(toggleBackgroundAndIconVisibility, text, seek, screenHeight,
//       screenWidth) {
//     return GestureDetector(
//       onDoubleTap: () {
//         toggleBackgroundAndIconVisibility(text);
//         seek(10);
//       },
//       child: AnimatedOpacity(
//         opacity: _showLeftBackground && _showRightBackground ? 1.0 : 0.0,
//         duration: const Duration(milliseconds: 300),
//         child: Container(
//           height: screenHeight,
//           width: screenWidth / 2 - 30,
//           color: Colors.black45, // Your background color
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;

//     return Positioned(
//       child: Container(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             // GestureDetector(
//             //   onDoubleTap: () {
//             //     _toggleBackgroundAndIconVisibility();
//             //     _seekBackward(10);
//             //   },
//             //   child: AnimatedOpacity(
//             //     opacity: _showBackground ? 1.0 : 0.0,
//             //     duration: const Duration(milliseconds: 300),
//             //     child: Container(
//             //       height: screenHeight,
//             //       width: screenWidth / 2 - 30,
//             //       color: Colors.black45, // Your background color
//             //     ),
//             //   ),
//             // ),
//             gestureWidget(_toggleBackgroundAndIconVisibility, 'left',
//                 _seekBackward, screenHeight, screenWidth),
//             gestureWidget(_toggleBackgroundAndIconVisibility, 'right',
//                 _seekForward, screenHeight, screenWidth),
//             // GestureDetector(
//             //   onDoubleTap: () {
//             //     _toggleBackgroundAndIconVisibility();
//             //     _seekForward(10);
//             //   },
//             //   child: AnimatedOpacity(
//             //     opacity: _showBackground ? 1.0 : 0.0,
//             //     duration: const Duration(milliseconds: 300),
//             //     child: Container(
//             //       height: screenHeight,
//             //       width: screenWidth / 2 - 30,
//             //       color: Colors.black45, // Your background color
//             //     ),
//             //   ),
//             // ),
//             // if (_showIcon)
//             //   const Icon(
//             //     Icons.play_arrow,
//             //     size: 30,
//             //     color: Colors.white,
//             //   ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _seekForward(int value) {
//     final newPosition =
//         widget.videoPlayerController.value.position + Duration(seconds: value);
//     AnimationController controller = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     Animation<double> positionAnimation = Tween<double>(
//       begin:
//           widget.videoPlayerController.value.position.inMilliseconds.toDouble(),
//       end: newPosition.inMilliseconds.toDouble(),
//     ).animate(controller);

//     // Start the animation
//     controller.forward();

//     // Update the video player's position when the animation changes
//     controller.addListener(() {
//       Duration newDuration = Duration(
//         milliseconds: positionAnimation.value.toInt(),
//       );
//       widget.videoPlayerController.seekTo(newDuration);
//     });

//     // Clean up resources when the animation is done
//     controller.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         controller.dispose();
//       }
//     });

//     // _videoPlayerController.seekTo(newPosition);
//   }

//   void _seekBackward(int value) {
//     AnimationController controller = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     final newPosition =
//         widget.videoPlayerController.value.position - Duration(seconds: value);
//     Animation<double> positionAnimation = Tween<double>(
//       begin:
//           widget.videoPlayerController.value.position.inMilliseconds.toDouble(),
//       end: newPosition.inMilliseconds.toDouble(),
//     ).animate(controller);

//     // Start the animation
//     controller.forward();

//     // Update the video player's position when the animation changes
//     controller.addListener(() {
//       Duration newDuration = Duration(
//         milliseconds: positionAnimation.value.toInt(),
//       );
//       widget.videoPlayerController.seekTo(newDuration);
//     });

//     // Clean up resources when the animation is done
//     controller.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         controller.dispose();
//       }
//     });
//   }
// }
